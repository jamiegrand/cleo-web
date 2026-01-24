#!/usr/bin/env bash
# validation.sh - JSON Schema validation for cleo-web
#
# PROVIDES: validate_json_syntax, validate_todo, validate_task, check_duplicates
#
# Design: Simplified validation focused on essential checks for SEO workflow tasks

#=== SOURCE GUARD ================================================
[[ -n "${_CLEO_WEB_VALIDATION_LOADED:-}" ]] && return 0
declare -r _CLEO_WEB_VALIDATION_LOADED=1

# Note: We do NOT set -euo pipefail here because this is a library meant to be sourced.

# ============================================================================
# CONFIGURATION
# ============================================================================

# Valid task statuses
VALID_STATUSES="pending in_progress completed"

# Exit codes
VAL_SUCCESS=0
VAL_SYNTAX_ERROR=1
VAL_SCHEMA_ERROR=2
VAL_SEMANTIC_ERROR=3

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if jq is available
_check_jq() {
    if ! command -v jq &>/dev/null; then
        echo "ERROR: jq is required for validation" >&2
        return 1
    fi
    return 0
}

# ============================================================================
# JSON SYNTAX VALIDATION
# ============================================================================

# Validate JSON syntax
# Args: $1 = file path or JSON string, $2 = "file" or "string" (default: file)
# Returns: 0 if valid, 1 if invalid
validate_json_syntax() {
    local input="$1"
    local mode="${2:-file}"

    _check_jq || return $VAL_SYNTAX_ERROR

    if [[ "$mode" == "file" ]]; then
        if [[ ! -f "$input" ]]; then
            echo "ERROR: File not found: $input" >&2
            return $VAL_SYNTAX_ERROR
        fi

        if ! jq empty "$input" 2>/dev/null; then
            echo "ERROR: Invalid JSON syntax in file: $input" >&2
            jq empty "$input" 2>&1 | head -5 >&2
            return $VAL_SYNTAX_ERROR
        fi
    else
        if ! echo "$input" | jq empty 2>/dev/null; then
            echo "ERROR: Invalid JSON syntax" >&2
            return $VAL_SYNTAX_ERROR
        fi
    fi

    return $VAL_SUCCESS
}

# ============================================================================
# TASK VALIDATION
# ============================================================================

# Validate a single task object
# Args: $1 = task JSON string
# Returns: 0 if valid, 1 if invalid
validate_task() {
    local task_json="$1"
    local errors=0

    _check_jq || return $VAL_SCHEMA_ERROR

    # Check required fields
    local content status activeForm

    content=$(echo "$task_json" | jq -r '.content // empty')
    status=$(echo "$task_json" | jq -r '.status // empty')
    activeForm=$(echo "$task_json" | jq -r '.activeForm // empty')

    if [[ -z "$content" ]]; then
        echo "ERROR: Task missing 'content' field" >&2
        ((errors++))
    fi

    if [[ -z "$status" ]]; then
        echo "ERROR: Task missing 'status' field" >&2
        ((errors++))
    fi

    if [[ -z "$activeForm" ]]; then
        echo "ERROR: Task missing 'activeForm' field" >&2
        ((errors++))
    fi

    # Validate status is valid enum
    if [[ -n "$status" ]]; then
        local valid=false
        for s in $VALID_STATUSES; do
            if [[ "$status" == "$s" ]]; then
                valid=true
                break
            fi
        done

        if [[ "$valid" == "false" ]]; then
            echo "ERROR: Invalid status '$status'. Must be one of: $VALID_STATUSES" >&2
            ((errors++))
        fi
    fi

    # Check content and activeForm are different
    if [[ -n "$content" && -n "$activeForm" && "$content" == "$activeForm" ]]; then
        echo "WARNING: content and activeForm are identical (activeForm should be present continuous)" >&2
    fi

    [[ $errors -eq 0 ]]
}

# ============================================================================
# TODO.JSON VALIDATION
# ============================================================================

# Validate todo.json structure
# Args: $1 = file path
# Returns: 0 if valid, non-zero if invalid
validate_todo() {
    local file="$1"
    local errors=0

    _check_jq || return $VAL_SCHEMA_ERROR

    # Check file exists
    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return $VAL_SYNTAX_ERROR
    fi

    # Check JSON syntax
    if ! validate_json_syntax "$file"; then
        return $VAL_SYNTAX_ERROR
    fi

    # Check _meta exists
    if ! jq -e '._meta' "$file" >/dev/null 2>&1; then
        echo "ERROR: Missing '_meta' object" >&2
        ((errors++))
    else
        # Check _meta.schemaVersion
        if ! jq -e '._meta.schemaVersion' "$file" >/dev/null 2>&1; then
            echo "WARNING: Missing '_meta.schemaVersion'" >&2
        fi

        # Check _meta.generation
        if ! jq -e '._meta.generation' "$file" >/dev/null 2>&1; then
            echo "WARNING: Missing '_meta.generation'" >&2
        fi
    fi

    # Check tasks array exists
    if ! jq -e '.tasks | type == "array"' "$file" >/dev/null 2>&1; then
        echo "ERROR: Missing or invalid 'tasks' array" >&2
        ((errors++))
    else
        # Validate each task
        local task_count
        task_count=$(jq '.tasks | length' "$file")

        for ((i=0; i<task_count; i++)); do
            local task_json
            task_json=$(jq ".tasks[$i]" "$file")

            if ! validate_task "$task_json" 2>/dev/null; then
                echo "ERROR: Task at index $i failed validation:" >&2
                validate_task "$task_json"
                ((errors++))
            fi
        done
    fi

    if [[ $errors -gt 0 ]]; then
        return $VAL_SCHEMA_ERROR
    fi

    return $VAL_SUCCESS
}

# ============================================================================
# DUPLICATE DETECTION
# ============================================================================

# Check for duplicate task content
# Args: $1 = file path
# Returns: 0 if no duplicates, 1 if duplicates found
check_duplicates() {
    local file="$1"

    _check_jq || return 1

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file" >&2
        return 1
    fi

    local duplicates
    duplicates=$(jq -r '.tasks[].content' "$file" 2>/dev/null | sort | uniq -d)

    if [[ -n "$duplicates" ]]; then
        echo "WARNING: Duplicate task content found:" >&2
        echo "$duplicates" | while read -r line; do
            echo "  - $line" >&2
        done
        return 1
    fi

    return 0
}

# ============================================================================
# COMPREHENSIVE VALIDATION
# ============================================================================

# Run all validations on a todo file
# Args: $1 = file path
# Returns: 0 if all pass, non-zero if any fail
validate_all() {
    local file="$1"
    local errors=0

    echo "Validating: $file"
    echo "────────────────────────────────────────"

    # 1. JSON Syntax
    echo -n "[1/3] JSON Syntax... "
    if validate_json_syntax "$file" 2>/dev/null; then
        echo "✓ PASS"
    else
        echo "✗ FAIL"
        ((errors++))
    fi

    # 2. Schema/Structure
    echo -n "[2/3] Schema... "
    if validate_todo "$file" 2>/dev/null; then
        echo "✓ PASS"
    else
        echo "✗ FAIL"
        ((errors++))
    fi

    # 3. Duplicates
    echo -n "[3/3] Duplicates... "
    if check_duplicates "$file" 2>/dev/null; then
        echo "✓ PASS"
    else
        echo "⚠ WARNING (duplicates found)"
    fi

    echo "────────────────────────────────────────"

    if [[ $errors -eq 0 ]]; then
        echo "Result: All validations passed"
        return $VAL_SUCCESS
    else
        echo "Result: $errors validation(s) failed"
        return $VAL_SCHEMA_ERROR
    fi
}

# ============================================================================
# EXPORTS
# ============================================================================

export -f validate_json_syntax
export -f validate_task
export -f validate_todo
export -f check_duplicates
export -f validate_all
