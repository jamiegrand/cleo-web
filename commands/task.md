---
description: Task management for SEO workflows
---

# /task

Manage tasks in your cleo-web project.

## Subcommands

### /task add "title"

Create a new task.

```
/task add "Optimize meta descriptions for blog posts"
/task add "Fix broken internal links on /services"
```

**Process:**
1. Generate unique task ID
2. Create task object with status `pending`
3. Save to `.cleo-web/todo.json` using atomic write
4. Display confirmation

### /task list

Show all tasks grouped by status.

```
/task list
/task list --status pending
/task list --status in_progress
```

**Output Format:**
```
PENDING (3)
  T001: Optimize meta descriptions for blog posts
  T002: Add structured data to product pages
  T003: Fix Core Web Vitals on mobile

IN PROGRESS (1)
  T004: Audit homepage E-E-A-T signals

COMPLETED (5)
  ...
```

### /task complete ID

Mark a task as completed.

```
/task complete T001
```

**Process:**
1. Validate task exists and is not already completed
2. Update status to `completed`
3. Add `completedAt` timestamp
4. Save with atomic write

### /task update ID --field value

Update task fields.

```
/task update T001 --status in_progress
/task update T001 --priority high
/task update T001 --labels "seo,technical"
```

### /task delete ID

Remove a task (with confirmation).

```
/task delete T001
```

## Task Schema

```json
{
  "id": "T001",
  "content": "Optimize meta descriptions for blog posts",
  "activeForm": "Optimizing meta descriptions",
  "status": "pending",
  "priority": "medium",
  "labels": ["seo", "content"],
  "createdAt": "2025-01-24T10:00:00Z",
  "completedAt": null,
  "audit": {
    "pageUrl": "/blog",
    "score": 72
  }
}
```

## Integration with SEO Workflows

Tasks can be auto-created from:
- `/audit content` - Creates tasks for issues found
- `/seo wins` - Creates tasks for quick win opportunities
- `/seo gaps` - Creates tasks for content gaps

## Data Storage

Tasks stored in `.cleo-web/todo.json` with:
- Atomic write operations (backup before save)
- Generation counter for conflict detection
- File locking for multi-agent safety
