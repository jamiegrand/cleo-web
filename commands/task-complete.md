---
description: Mark task as complete
parent: task
type: implementation
---

# /task complete

Mark a task as completed.

## Usage

```
/task complete ID
/task complete T015
/task complete T015 --note "Optimized all 12 blog post meta descriptions"
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `ID` | Yes | Task ID to complete (e.g., T015) |
| `--note` | No | Completion note for context |

## Process

1. Validate task exists in `.cleo-web/todo.json`
2. Check task is not already completed
3. Update task:
   - Set `status` to `completed`
   - Add `completedAt` timestamp
   - Add completion note if provided
4. Save with atomic write
5. Update session statistics if session active
6. Display confirmation

## Output

```
Completed task T015: "Optimize meta descriptions for blog posts"
  Duration: 2h 15m (started 14:30)
  Note: Optimized all 12 blog post meta descriptions

Session Progress:
  Tasks completed this session: 4
  Remaining pending: 4
```

## Error Cases

```
ERROR: Task T099 not found
Available tasks: T001-T019

ERROR: Task T012 already completed
Completed at: 2026-01-25 10:30
```

## Bulk Completion

Complete multiple tasks:

```
/task complete T015 T016 T017
```

Output:
```
Completed 3 tasks:
  ✓ T015: Optimize meta descriptions
  ✓ T016: Add internal links
  ✓ T017: Update statistics

Session Progress: 7 tasks completed
```

## Data Storage

Updates `.cleo-web/todo.json` with atomic write operations.
Session statistics updated in `.cleo-web/sessions.json`.
