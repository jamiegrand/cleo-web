---
description: List tasks with filters
parent: task
type: implementation
---

# /task list

Display tasks grouped by status with optional filtering.

## Usage

```
/task list
/task list --status pending
/task list --epic SEO
/task list --priority high
/task list --labels audit
```

## Arguments

| Argument | Description |
|----------|-------------|
| `--status` | Filter by status: pending, in_progress, completed, blocked |
| `--epic` | Filter by epic/group |
| `--priority` | Filter by priority: critical, high, medium, low |
| `--labels` | Filter by label (comma-separated for multiple) |
| `--limit` | Maximum tasks to show (default: all) |

## Output Format

```
TASKS
────────────────────────────────────────

PENDING (5)
  [HIGH] T015: Optimize meta descriptions for blog posts
         Epic: SEO | Labels: audit, content
  [MED]  T016: Add internal links to homepage
         Epic: Content
  [MED]  T017: Update outdated statistics in /blog/stats
  [LOW]  T018: Research new keyword opportunities
  [LOW]  T019: Fix minor typos in about page

IN PROGRESS (1)
  [HIGH] T013: Audit homepage E-E-A-T signals
         Started: 2h ago

COMPLETED TODAY (3)
  [DONE] T012: Fix meta descriptions
  [DONE] T011: Add schema markup
  [DONE] T010: Optimize hero image

Total: 9 tasks (5 pending, 1 in progress, 3 completed)
```

## Filtered Output

When using `--status pending`:

```
PENDING TASKS (5)
────────────────────────────────────────

[HIGH] T015: Optimize meta descriptions for blog posts
[MED]  T016: Add internal links to homepage
[MED]  T017: Update outdated statistics
[LOW]  T018: Research new keyword opportunities
[LOW]  T019: Fix minor typos

Showing: 5 of 9 total tasks
```

## Data Source

Tasks loaded from `.cleo-web/todo.json`
