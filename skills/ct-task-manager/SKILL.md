---
name: ct-task-manager
version: 1.0.0
description: Core task management skill for CRUD operations with hierarchy support
tags: [task-management, core]
status: active
---

# Task Manager

Core task management skill for CRUD operations. Handles task creation, updates, completion, and listing with epic/hierarchy support.

## Capabilities

- **Create Task** (`task-create`): Add new tasks with optional epic association
- **Update Task** (`task-update`): Modify task details, status, or priority
- **Complete Task** (`task-complete`): Mark tasks as done with completion notes
- **List Tasks** (`task-list`): Query tasks with filters and sorting

## Data Model

### Task Structure

```json
{
  "id": "task-001",
  "title": "Fix meta description on /blog/post",
  "description": "Expand meta description to 150-160 characters",
  "status": "pending",
  "priority": "high",
  "epic_id": "epic-seo",
  "labels": ["audit", "onpage"],
  "created_at": "2026-01-24T10:00:00Z",
  "updated_at": "2026-01-24T10:00:00Z",
  "completed_at": null,
  "source": "audit"
}
```

### Task Statuses

| Status | Description |
|--------|-------------|
| `pending` | Not yet started |
| `in_progress` | Currently being worked on |
| `blocked` | Waiting on dependency |
| `completed` | Done |
| `cancelled` | No longer needed |

### Priority Levels

| Priority | Description |
|----------|-------------|
| `critical` | Must be done immediately |
| `high` | Should be done soon |
| `medium` | Normal priority |
| `low` | Can wait |

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `TASK_ID` | For update/complete | Unique task identifier |
| `TASK_TITLE` | For create | Task title/summary |
| `TASK_DESCRIPTION` | No | Detailed task description |
| `EPIC_ID` | No | Parent epic for grouping |
| `PRIORITY` | No | Task priority level |
| `LABELS` | No | Tags for categorization |

## Outputs

### Task List Response

```json
{
  "tasks": [...],
  "total": 15,
  "filtered": 5,
  "filters_applied": {
    "status": "pending",
    "epic_id": "epic-seo"
  }
}
```

### Manifest Entry

When tasks are created, they can be added to MANIFEST.md:

```markdown
## Pending Tasks

- [ ] [task-001] Fix meta description on /blog/post (high)
- [ ] [task-002] Add internal links to homepage (medium)
```

## Storage

Tasks are stored in `.cleo-web/todo.json` with atomic write operations to prevent corruption.

### File Operations

Uses `lib/file-ops.sh` for:
- Atomic writes (write to temp, then rename)
- Backup before modifications
- JSON validation

## Example Usage

### Create Task
```
/task add "Fix meta description" --epic SEO --priority high
```

### List Tasks
```
/task list --status pending --epic SEO
```

### Complete Task
```
/task complete task-001
```

### Update Task
```
/task update task-001 --priority critical --labels "urgent,seo"
```

## Integration

### With ct-seo-auditor

Audits automatically create tasks for issues:
```
Audit found: Meta description too short
→ Creates: task-XXX "Fix meta description on /path" --epic SEO
```

### With ct-session-manager

Sessions track which tasks were worked on:
```
Session started → Links to pending tasks
Task completed → Records in session summary
```

## Dependencies

- None (core skill)
