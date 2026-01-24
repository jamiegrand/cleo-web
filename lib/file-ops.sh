#!/usr/bin/env bash
# file-ops.sh - Atomic file operations for cleo-web
#
# PROVIDES: atomic_write, save_json, load_json, backup_file, restore_backup,
#           lock_file, unlock_file
#
# Design: All operations use temp files for atomicity with automatic backup rotation
# Multi-Agent: Uses flock for file locking to support concurrent agent access

#=== SOURCE GUARD ================================================
[[ -n "${_CLEO_WEB_FILE_OPS_LOADED:-}" ]] && return 0
declare -r _CLEO_WEB_FILE_OPS_LOADED=1

# Note: We do NOT set -euo pipefail here because this is a library meant to be sourced.
# Setting these globally would affect the caller's shell. Instead, individual functions
# handle errors explicitly and return appropriate exit codes.

# ============================================================================
# CONFIGURATION
# ============================================================================

CLEO_WEB_DIR="${CLEO_WEB_DIR:-.cleo-web}"
BACKUP_DIR="backups"
TEMP_SUFFIX=".tmp"
LOCK_SUFFIX=".lock"
MAX_BACKUPS="${MAX_BACKUPS:-5}"
LOCK_TIMEOUT="${LOCK_TIMEOUT:-30}"

# Exit codes
EXIT_SUCCESS=0
EXIT_INVALID_ARGS=1
EXIT_FILE_NOT_FOUND=2
EXIT_WRITE_FAILED=3
EXIT_BACKUP_FAILED=4
EXIT_JSON_PARSE_FAILED=5
EXIT_LOCK_FAILED=6

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if jq is available
_check_jq() {
    if ! command -v jq &>/dev/null; then
        echo "ERROR: jq is required but not installed" >&2
        echo "Install: brew install jq (macOS) or apt-get install jq (Linux)" >&2
        return 1
    fi
    return 0
}

# Sanitize file path for safe shell usage
sanitize_path() {
    local path="$1"

    if [[ -z "$path" ]]; then
        echo "ERROR: Empty path provided" >&2
        return $EXIT_INVALID_ARGS
    fi

    # Check for shell metacharacters
    if [[ "$path" == *'$'* ]] || [[ "$path" == *'`'* ]] || [[ "$path" == *';'* ]] || \
       [[ "$path" == *'|'* ]] || [[ "$path" == *'&'* ]] || [[ "$path" == *'<'* ]] || \
       [[ "$path" == *'>'* ]] || [[ "$path" == *"'"* ]] || [[ "$path" == *'"'* ]]; then
        echo "ERROR: Path contains shell metacharacters" >&2
        return $EXIT_INVALID_ARGS
    fi

    printf '%s' "$path"
    return $EXIT_SUCCESS
}

# ============================================================================
# FILE LOCKING (Multi-Agent Support)
# ============================================================================

# Check if flock is available
# Linux: built-in, macOS: install via `brew install discoteq/discoteq/flock`
_has_flock() {
    command -v flock &>/dev/null
}

# Warn once if flock is not available (mkdir fallback is slower)
_warn_no_flock() {
    if [[ -z "${_FLOCK_WARNED:-}" ]] && ! _has_flock; then
        echo "NOTE: flock not found, using mkdir fallback (slower)" >&2
        echo "Install for better performance: brew install discoteq/discoteq/flock" >&2
        export _FLOCK_WARNED=1
    fi
}

# Acquire file lock with timeout
# Uses flock when available, falls back to mkdir-based locking on macOS
# mkdir is atomic on POSIX and commonly used as a portable mutex
lock_file() {
    local file="$1"
    local fd_var="${2:-LOCK_FD}"
    local timeout="${3:-$LOCK_TIMEOUT}"

    if [[ -z "$file" ]]; then
        echo "ERROR: File path required for locking" >&2
        return $EXIT_INVALID_ARGS
    fi

    # Validate fd_var contains only valid variable name characters
    if [[ ! "$fd_var" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "ERROR: Invalid file descriptor variable name" >&2
        return $EXIT_INVALID_ARGS
    fi

    # Ensure parent directory exists
    local file_dir
    file_dir="$(dirname "$file")"
    if [[ ! -d "$file_dir" ]]; then
        if ! mkdir -p "$file_dir" 2>/dev/null; then
            echo "ERROR: Failed to create directory for lock: $file_dir" >&2
            return $EXIT_LOCK_FAILED
        fi
    fi

    local lock_path="${file}${LOCK_SUFFIX}"

    if _has_flock; then
        # Use flock (preferred, available on Linux and via brew on macOS)
        _lock_file_flock "$file" "$fd_var" "$timeout" "$lock_path"
    else
        # Fallback to mkdir-based locking (portable, works on macOS)
        _warn_no_flock
        _lock_file_mkdir "$file" "$fd_var" "$timeout" "$lock_path"
    fi
}

# flock-based locking (Linux, or macOS with util-linux installed)
_lock_file_flock() {
    local file="$1"
    local fd_var="$2"
    local timeout="$3"
    local lock_path="$4"

    # Touch lock file to ensure it exists
    touch "$lock_path" 2>/dev/null || {
        echo "ERROR: Failed to create lock file: $lock_path" >&2
        return $EXIT_LOCK_FAILED
    }

    # Find available file descriptor (200-210)
    local fd
    for fd in {200..210}; do
        if ! { true >&"$fd"; } 2>/dev/null; then
            # FD is available, open it
            if ! eval "exec $fd>'$lock_path'" 2>/dev/null; then
                continue
            fi

            # Try to acquire lock with timeout
            if flock -w "$timeout" "$fd" 2>/dev/null; then
                eval "$fd_var=$fd"
                return $EXIT_SUCCESS
            else
                eval "exec $fd>&-" 2>/dev/null || true
                echo "ERROR: Failed to acquire lock on $file (timeout after ${timeout}s)" >&2
                echo "Another agent may be accessing this file." >&2
                return $EXIT_LOCK_FAILED
            fi
        fi
    done

    echo "ERROR: No available file descriptors for locking" >&2
    return $EXIT_LOCK_FAILED
}

# mkdir-based locking (portable fallback for macOS)
# Uses a directory as a mutex - mkdir is atomic on POSIX
_lock_file_mkdir() {
    local file="$1"
    local fd_var="$2"
    local timeout="$3"
    local lock_path="$4"

    local lock_dir="${lock_path}.d"
    local start_time
    start_time=$(date +%s)

    while true; do
        # Try to create lock directory (atomic operation)
        if mkdir "$lock_dir" 2>/dev/null; then
            # Store PID in lock for debugging
            echo $$ > "$lock_dir/pid" 2>/dev/null || true
            # Store a marker value (we don't have a real FD, use -1)
            eval "$fd_var=-1"
            return $EXIT_SUCCESS
        fi

        # Check for stale lock (process that created it is gone)
        if [[ -f "$lock_dir/pid" ]]; then
            local lock_pid
            lock_pid=$(cat "$lock_dir/pid" 2>/dev/null)
            if [[ -n "$lock_pid" ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
                # Process is gone, remove stale lock
                rm -rf "$lock_dir" 2>/dev/null
                continue
            fi
        fi

        # Check timeout
        local elapsed
        elapsed=$(( $(date +%s) - start_time ))
        if [[ $elapsed -ge $timeout ]]; then
            echo "ERROR: Failed to acquire lock on $file (timeout after ${timeout}s)" >&2
            echo "Another agent may be accessing this file." >&2
            return $EXIT_LOCK_FAILED
        fi

        # Wait a bit before retrying
        sleep 0.1
    done
}

# Release file lock
# Safe to call even if no lock is held
unlock_file() {
    local fd="${1:-${LOCK_FD:-}}"

    if [[ -z "$fd" ]]; then
        return $EXIT_SUCCESS
    fi

    if [[ "$fd" == "-1" ]]; then
        # mkdir-based lock - we need to find and remove the lock directory
        # This is called with the FD, but we stored -1 for mkdir locks
        # The caller should clean up the lock directory
        return $EXIT_SUCCESS
    fi

    # Validate fd is a valid file descriptor number
    if [[ ! "$fd" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Invalid file descriptor (must be numeric): $fd" >&2
        return $EXIT_INVALID_ARGS
    fi

    # Release flock and close file descriptor
    if _has_flock; then
        flock -u "$fd" 2>/dev/null || true
    fi
    eval "exec $fd>&-" 2>/dev/null || true

    return $EXIT_SUCCESS
}

# Clean up mkdir-based lock directory
# Call this after unlock_file when using mkdir locking
_cleanup_mkdir_lock() {
    local file="$1"
    local lock_dir="${file}${LOCK_SUFFIX}.d"
    rm -rf "$lock_dir" 2>/dev/null || true
}

# Check file-ops prerequisites and report status
# Returns 0 if all required tools available, 1 if degraded
check_file_ops_prereqs() {
    local status=0

    # jq is required
    if ! command -v jq &>/dev/null; then
        echo "ERROR: jq is required but not installed" >&2
        echo "  Install: brew install jq" >&2
        status=1
    fi

    # flock is recommended (not required due to mkdir fallback)
    if ! _has_flock; then
        echo "WARNING: flock not found (using slower mkdir fallback)" >&2
        echo "  Recommended: brew install discoteq/discoteq/flock" >&2
        export _FLOCK_WARNED=1  # Prevent duplicate warnings at runtime
    fi

    return $status
}

# ============================================================================
# DIRECTORY OPERATIONS
# ============================================================================

# Ensure directory exists
ensure_directory() {
    local dir="$1"

    if [[ -z "$dir" ]]; then
        echo "ERROR: Directory path required" >&2
        return $EXIT_INVALID_ARGS
    fi

    if [[ ! -d "$dir" ]]; then
        if ! mkdir -p "$dir" 2>/dev/null; then
            echo "ERROR: Failed to create directory: $dir" >&2
            return $EXIT_WRITE_FAILED
        fi
        chmod 755 "$dir" 2>/dev/null || true
    fi

    return $EXIT_SUCCESS
}

# ============================================================================
# BACKUP OPERATIONS
# ============================================================================

# Create versioned backup of file
backup_file() {
    local file="$1"

    if [[ -z "$file" ]]; then
        echo "ERROR: File path required for backup" >&2
        return $EXIT_INVALID_ARGS
    fi

    if [[ ! -f "$file" ]]; then
        # No file to backup - this is OK for new files
        return $EXIT_SUCCESS
    fi

    local file_dir
    file_dir="$(dirname "$file")"
    local basename
    basename="$(basename "$file")"
    local backup_dir="$file_dir/$BACKUP_DIR"

    # Ensure backup directory exists
    ensure_directory "$backup_dir" || return $EXIT_BACKUP_FAILED

    # Find next available backup number
    local backup_num=1
    local backup_file="$backup_dir/${basename}.${backup_num}"

    while [[ -f "$backup_file" ]]; do
        backup_num=$((backup_num + 1))
        backup_file="$backup_dir/${basename}.${backup_num}"
    done

    # Copy file to backup
    if ! cp -p "$file" "$backup_file" 2>/dev/null; then
        echo "ERROR: Failed to create backup: $backup_file" >&2
        return $EXIT_BACKUP_FAILED
    fi

    chmod 600 "$backup_file" 2>/dev/null || true

    # Rotate old backups
    _rotate_backups "$backup_dir" "$basename"

    echo "$backup_file"
    return $EXIT_SUCCESS
}

# Rotate numbered backups
_rotate_backups() {
    local backup_dir="$1"
    local basename="$2"

    [[ ! -d "$backup_dir" ]] && return 0

    local backup_pattern="${basename}.[0-9]*"
    local backup_count
    backup_count=$(find "$backup_dir" -maxdepth 1 -name "$backup_pattern" -type f 2>/dev/null | wc -l | tr -d ' ')

    if [[ $backup_count -le $MAX_BACKUPS ]]; then
        return 0
    fi

    local delete_count=$((backup_count - MAX_BACKUPS))

    # Delete oldest backups
    find "$backup_dir" -maxdepth 1 -name "$backup_pattern" -type f -print0 2>/dev/null \
        | xargs -0 ls -t 2>/dev/null \
        | tail -n "$delete_count" \
        | xargs rm -f 2>/dev/null || true

    return 0
}

# Restore file from backup
restore_backup() {
    local file="$1"
    local backup_num="${2:-}"

    if [[ -z "$file" ]]; then
        echo "ERROR: File path required" >&2
        return $EXIT_INVALID_ARGS
    fi

    local file_dir
    file_dir="$(dirname "$file")"
    local basename
    basename="$(basename "$file")"
    local backup_dir="$file_dir/$BACKUP_DIR"

    if [[ ! -d "$backup_dir" ]]; then
        echo "ERROR: Backup directory not found: $backup_dir" >&2
        return $EXIT_FILE_NOT_FOUND
    fi

    local backup_file

    if [[ -n "$backup_num" ]]; then
        backup_file="$backup_dir/${basename}.${backup_num}"
        if [[ ! -f "$backup_file" ]]; then
            echo "ERROR: Backup not found: $backup_file" >&2
            return $EXIT_FILE_NOT_FOUND
        fi
    else
        # Find most recent backup
        backup_file=$(find "$backup_dir" -maxdepth 1 -name "${basename}.*" -type f -print0 2>/dev/null \
            | xargs -0 ls -t 2>/dev/null \
            | head -n 1)

        if [[ -z "$backup_file" ]]; then
            echo "ERROR: No backups found for: $basename" >&2
            return $EXIT_FILE_NOT_FOUND
        fi
    fi

    if ! cp "$backup_file" "$file" 2>/dev/null; then
        echo "ERROR: Failed to restore from backup: $backup_file" >&2
        return $EXIT_WRITE_FAILED
    fi

    chmod 644 "$file" 2>/dev/null || true
    echo "Restored from backup: $backup_file" >&2
    return $EXIT_SUCCESS
}

# ============================================================================
# ATOMIC WRITE OPERATIONS
# ============================================================================

# Atomic write operation with backup and file locking
atomic_write() {
    local file="$1"
    local content="${2:-}"

    if [[ -z "$file" ]]; then
        echo "ERROR: File path required" >&2
        return $EXIT_INVALID_ARGS
    fi

    # Sanitize path
    if ! sanitize_path "$file" >/dev/null; then
        return $EXIT_INVALID_ARGS
    fi

    # Read content from stdin if not provided
    if [[ -z "$content" ]]; then
        content=$(cat)
    fi

    if [[ -z "$content" ]]; then
        echo "ERROR: Content is empty" >&2
        return $EXIT_INVALID_ARGS
    fi

    # Ensure parent directory exists
    local file_dir
    file_dir="$(dirname "$file")"
    ensure_directory "$file_dir" || return $EXIT_WRITE_FAILED

    # Acquire file lock for multi-agent safety
    local lock_fd
    if ! lock_file "$file" lock_fd "$LOCK_TIMEOUT"; then
        return $EXIT_LOCK_FAILED
    fi

    # Helper function to release lock (handles both flock and mkdir modes)
    _release_lock() {
        unlock_file "$lock_fd"
        _cleanup_mkdir_lock "$file"
    }

    # Set up cleanup trap
    trap "_release_lock; rm -f '${file}${TEMP_SUFFIX}' 2>/dev/null || true" EXIT ERR INT TERM

    # Create temp file
    local temp_file="${file}${TEMP_SUFFIX}"

    # Write to temp file
    if ! printf '%s' "$content" > "$temp_file" 2>/dev/null; then
        echo "ERROR: Failed to write temp file: $temp_file" >&2
        _release_lock
        rm -f "$temp_file" 2>/dev/null || true
        trap - EXIT ERR INT TERM
        return $EXIT_WRITE_FAILED
    fi

    # Create backup of original (if exists)
    if [[ -f "$file" ]]; then
        if ! backup_file "$file" >/dev/null; then
            _release_lock
            rm -f "$temp_file" 2>/dev/null || true
            trap - EXIT ERR INT TERM
            return $EXIT_BACKUP_FAILED
        fi
    fi

    # Atomic move
    if ! mv "$temp_file" "$file" 2>/dev/null; then
        echo "ERROR: Atomic move failed" >&2
        _release_lock
        rm -f "$temp_file" 2>/dev/null || true
        trap - EXIT ERR INT TERM
        return $EXIT_WRITE_FAILED
    fi

    # Release lock and clean up
    _release_lock
    trap - EXIT ERR INT TERM

    chmod 644 "$file" 2>/dev/null || true
    return $EXIT_SUCCESS
}

# ============================================================================
# JSON OPERATIONS
# ============================================================================

# Load and parse JSON file
load_json() {
    local file="$1"

    _check_jq || return $EXIT_JSON_PARSE_FAILED

    if [[ -z "$file" ]]; then
        echo "ERROR: File path required" >&2
        return $EXIT_INVALID_ARGS
    fi

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return $EXIT_FILE_NOT_FOUND
    fi

    # Validate JSON syntax
    if ! jq empty "$file" 2>/dev/null; then
        echo "ERROR: Invalid JSON in file: $file" >&2
        return $EXIT_JSON_PARSE_FAILED
    fi

    cat "$file"
    return $EXIT_SUCCESS
}

# Save JSON with pretty-printing and atomic write
save_json() {
    local file="$1"
    local json="${2:-}"

    _check_jq || return $EXIT_JSON_PARSE_FAILED

    if [[ -z "$file" ]]; then
        echo "ERROR: File path required" >&2
        return $EXIT_INVALID_ARGS
    fi

    # Read from stdin if no JSON provided
    if [[ -z "$json" ]]; then
        json=$(cat)
    fi

    # Validate JSON syntax
    if ! echo "$json" | jq empty 2>/dev/null; then
        echo "ERROR: Invalid JSON content" >&2
        return $EXIT_JSON_PARSE_FAILED
    fi

    # Increment generation counter for todo.json
    if [[ "$file" == *"/todo.json" ]]; then
        local gen
        gen=$(echo "$json" | jq -r '._meta.generation // 0')
        local new_gen=$((gen + 1))
        json=$(echo "$json" | jq --argjson g "$new_gen" '._meta.generation = $g')
    fi

    # Pretty-print and write atomically
    local pretty_json
    pretty_json=$(echo "$json" | jq '.')

    if ! atomic_write "$file" "$pretty_json"; then
        echo "ERROR: Failed to save JSON to: $file" >&2
        return $EXIT_WRITE_FAILED
    fi

    return $EXIT_SUCCESS
}

# List available backups
list_backups() {
    local file="$1"

    if [[ -z "$file" ]]; then
        echo "ERROR: File path required" >&2
        return $EXIT_INVALID_ARGS
    fi

    local file_dir
    file_dir="$(dirname "$file")"
    local basename
    basename="$(basename "$file")"
    local backup_dir="$file_dir/$BACKUP_DIR"

    if [[ ! -d "$backup_dir" ]]; then
        echo "No backups found" >&2
        return $EXIT_SUCCESS
    fi

    echo "Backups for $basename:"
    find "$backup_dir" -maxdepth 1 -name "${basename}.*" -type f -exec ls -lh {} \; 2>/dev/null | \
        awk '{print "  " $NF " (" $5 ", " $6 " " $7 " " $8 ")"}'

    return $EXIT_SUCCESS
}

# Export functions
export -f sanitize_path
export -f ensure_directory
export -f lock_file
export -f unlock_file
export -f backup_file
export -f restore_backup
export -f atomic_write
export -f load_json
export -f save_json
export -f list_backups
export -f check_file_ops_prereqs
