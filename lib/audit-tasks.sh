#!/usr/bin/env bash
# audit-tasks.sh - Auto-task creation from audit issues
#
# Creates tasks automatically for critical and high severity audit issues.
# Integrates with ct-task-manager skill and metrics.db.

# Get script directory for relative paths
AUDIT_TASKS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load dependencies
source "${AUDIT_TASKS_LIB_DIR}/file-ops.sh" 2>/dev/null || true

# =============================================================================
# CONFIGURATION
# =============================================================================

# Severities that trigger auto-task creation
# ALL severities create tasks for full visibility
AUTO_TASK_SEVERITIES="critical high medium low"

# Task priority mapping from audit severity
declare -A SEVERITY_TO_PRIORITY
SEVERITY_TO_PRIORITY=(
    ["critical"]="critical"
    ["high"]="high"
    ["medium"]="medium"
    ["low"]="low"
)

# =============================================================================
# TASK CREATION
# =============================================================================

# Create a task from an audit issue
# Usage: create_task_from_issue <check_code> <category> <severity> <description> <fix_suggestion> <impact>
create_task_from_issue() {
    local check_code="$1"
    local category="$2"
    local severity="$3"
    local description="$4"
    local fix_suggestion="$5"
    local impact="$6"

    local data_dir="${CLEO_WEB_DATA_DIR:-.cleo-web}"
    local todo_file="${data_dir}/todo.json"

    # Check if task already exists for this check code
    if task_exists_for_check "$check_code"; then
        echo "Task already exists for ${check_code}" >&2
        return 1
    fi

    # Generate task ID
    local task_id
    task_id=$(generate_task_id "$todo_file")

    # Map severity to priority
    local priority="${SEVERITY_TO_PRIORITY[$severity]:-medium}"

    # Build task title from description (truncate if needed)
    local title
    title=$(echo "$description" | cut -c1-80)

    # Build active form (present continuous)
    local active_form
    active_form=$(convert_to_active_form "$title")

    # Create timestamp
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Build task JSON
    local task_json
    task_json=$(cat <<EOF
{
  "id": "${task_id}",
  "content": "${title}",
  "activeForm": "${active_form}",
  "status": "pending",
  "priority": "${priority}",
  "labels": ["audit", "${category}"],
  "source": "audit-site",
  "createdAt": "${timestamp}",
  "audit": {
    "checkCode": "${check_code}",
    "category": "${category}",
    "severity": "${severity}",
    "impact": "${impact}",
    "fixSuggestion": "${fix_suggestion}"
  }
}
EOF
)

    # Add task to todo.json
    if add_task_to_file "$todo_file" "$task_json"; then
        echo "${task_id}"
        return 0
    else
        echo "Failed to create task for ${check_code}" >&2
        return 1
    fi
}

# Check if a task already exists for a given check code
# Usage: task_exists_for_check <check_code>
task_exists_for_check() {
    local check_code="$1"
    local data_dir="${CLEO_WEB_DATA_DIR:-.cleo-web}"
    local todo_file="${data_dir}/todo.json"

    if [[ ! -f "$todo_file" ]]; then
        return 1
    fi

    # Check if any task has this check code in audit.checkCode
    local exists
    exists=$(jq -r --arg code "$check_code" '
        .tasks // [] |
        map(select(.audit.checkCode == $code and .status != "completed")) |
        length
    ' "$todo_file" 2>/dev/null)

    [[ "$exists" -gt 0 ]]
}

# Generate a new task ID
# Usage: generate_task_id <todo_file>
generate_task_id() {
    local todo_file="$1"

    if [[ ! -f "$todo_file" ]]; then
        echo "T001"
        return 0
    fi

    # Find highest existing task number
    local max_num
    max_num=$(jq -r '
        .tasks // [] |
        map(.id) |
        map(select(startswith("T"))) |
        map(ltrimstr("T") | tonumber) |
        max // 0
    ' "$todo_file" 2>/dev/null)

    # Increment and format
    local next_num=$((max_num + 1))
    printf "T%03d" "$next_num"
}

# Convert imperative title to active form (present continuous)
# Usage: convert_to_active_form <title>
convert_to_active_form() {
    local title="$1"

    # Common verb transformations
    local active
    active=$(echo "$title" | sed -E '
        s/^Add /Adding /;
        s/^Fix /Fixing /;
        s/^Update /Updating /;
        s/^Remove /Removing /;
        s/^Optimize /Optimizing /;
        s/^Implement /Implementing /;
        s/^Create /Creating /;
        s/^Enable /Enabling /;
        s/^Configure /Configuring /;
        s/^Set up /Setting up /;
        s/^Check /Checking /;
        s/^Verify /Verifying /;
        s/^Resolve /Resolving /;
        s/^Improve /Improving /;
        s/^Reduce /Reducing /;
        s/^Increase /Increasing /;
    ')

    # If no transformation happened, prepend "Working on"
    if [[ "$active" == "$title" ]]; then
        active="Working on ${title}"
    fi

    echo "$active"
}

# Add a task to the todo.json file
# Usage: add_task_to_file <todo_file> <task_json>
add_task_to_file() {
    local todo_file="$1"
    local task_json="$2"

    # Create file if it doesn't exist
    if [[ ! -f "$todo_file" ]]; then
        cat > "$todo_file" <<EOF
{
  "_meta": {
    "schemaVersion": "1.0.0",
    "generation": 0,
    "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  },
  "tasks": []
}
EOF
    fi

    # Add task to array using jq
    local tmp_file="${todo_file}.tmp.$$"

    if jq --argjson task "$task_json" '.tasks += [$task] | ._meta.generation += 1' "$todo_file" > "$tmp_file"; then
        mv "$tmp_file" "$todo_file"
        return 0
    else
        rm -f "$tmp_file"
        return 1
    fi
}

# =============================================================================
# BATCH OPERATIONS
# =============================================================================

# Process audit results and create tasks for critical/high issues
# Usage: create_tasks_from_audit_results <audit_id>
create_tasks_from_audit_results() {
    local audit_id="$1"
    local data_dir="${CLEO_WEB_DATA_DIR:-.cleo-web}"
    local db_file="${data_dir}/metrics.db"

    if [[ ! -f "$db_file" ]]; then
        echo "No metrics database found" >&2
        return 1
    fi

    local tasks_created=0

    # Query failing checks from database
    # Creates tasks for ALL severities (critical, high, medium, low)
    local checks
    checks=$(sqlite3 -json "$db_file" "
        SELECT
            ac.check_code,
            ac.category,
            cd.severity_if_fail as severity,
            cd.description,
            ac.fix_suggestion,
            cd.max_score || ' points' as impact
        FROM audit_checks ac
        JOIN check_definitions cd ON ac.check_code = cd.check_code
        WHERE ac.audit_id = ${audit_id}
          AND ac.status IN ('fail', 'warn')
        ORDER BY
            CASE cd.severity_if_fail
                WHEN 'critical' THEN 1
                WHEN 'high' THEN 2
                WHEN 'medium' THEN 3
                WHEN 'low' THEN 4
            END,
            cd.max_score DESC
    " 2>/dev/null)

    if [[ -z "$checks" || "$checks" == "[]" ]]; then
        echo "No critical or high issues found"
        return 0
    fi

    # Process each failing check
    echo "$checks" | jq -c '.[]' | while read -r check; do
        local check_code category severity description fix_suggestion impact
        check_code=$(echo "$check" | jq -r '.check_code')
        category=$(echo "$check" | jq -r '.category')
        severity=$(echo "$check" | jq -r '.severity')
        description=$(echo "$check" | jq -r '.description')
        fix_suggestion=$(echo "$check" | jq -r '.fix_suggestion // "See audit for details"')
        impact=$(echo "$check" | jq -r '.impact')

        local task_id
        task_id=$(create_task_from_issue "$check_code" "$category" "$severity" "$description" "$fix_suggestion" "$impact")

        if [[ $? -eq 0 ]]; then
            echo "Created task ${task_id}: ${description} [${severity}]"
            ((tasks_created++))
        fi
    done

    echo ""
    echo "Tasks created: ${tasks_created}"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Get summary of audit-generated tasks
# Usage: get_audit_task_summary
get_audit_task_summary() {
    local data_dir="${CLEO_WEB_DATA_DIR:-.cleo-web}"
    local todo_file="${data_dir}/todo.json"

    if [[ ! -f "$todo_file" ]]; then
        echo "No tasks found"
        return 0
    fi

    jq -r '
        .tasks // [] |
        map(select(.source == "audit-site")) |
        group_by(.status) |
        map({
            status: .[0].status,
            count: length
        }) |
        .[] |
        "\(.status): \(.count)"
    ' "$todo_file"
}

# List pending audit tasks by priority
# Usage: list_pending_audit_tasks
list_pending_audit_tasks() {
    local data_dir="${CLEO_WEB_DATA_DIR:-.cleo-web}"
    local todo_file="${data_dir}/todo.json"

    if [[ ! -f "$todo_file" ]]; then
        return 0
    fi

    jq -r '
        .tasks // [] |
        map(select(.source == "audit-site" and .status == "pending")) |
        sort_by(
            if .priority == "critical" then 0
            elif .priority == "high" then 1
            elif .priority == "medium" then 2
            else 3
            end
        ) |
        .[] |
        "\(.id): \(.content) [\(.priority)]"
    ' "$todo_file"
}

# Mark an audit task as completed
# Usage: complete_audit_task <task_id>
complete_audit_task() {
    local task_id="$1"
    local data_dir="${CLEO_WEB_DATA_DIR:-.cleo-web}"
    local todo_file="${data_dir}/todo.json"

    if [[ ! -f "$todo_file" ]]; then
        echo "No todo file found" >&2
        return 1
    fi

    local tmp_file="${todo_file}.tmp.$$"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if jq --arg id "$task_id" --arg ts "$timestamp" '
        .tasks = (.tasks | map(
            if .id == $id then
                .status = "completed" | .completedAt = $ts
            else
                .
            end
        )) |
        ._meta.generation += 1
    ' "$todo_file" > "$tmp_file"; then
        mv "$tmp_file" "$todo_file"
        echo "Task ${task_id} marked as completed"
        return 0
    else
        rm -f "$tmp_file"
        return 1
    fi
}

# =============================================================================
# EXPORTS
# =============================================================================

# Export functions for use by other scripts
export -f create_task_from_issue 2>/dev/null || true
export -f task_exists_for_check 2>/dev/null || true
export -f create_tasks_from_audit_results 2>/dev/null || true
export -f get_audit_task_summary 2>/dev/null || true
export -f list_pending_audit_tasks 2>/dev/null || true
export -f complete_audit_task 2>/dev/null || true
