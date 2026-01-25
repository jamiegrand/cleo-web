---
description: Show current project and session status
---

# /status

Display current project state, session status, and pending work summary.

## Output

```
PROJECT STATUS: cleo-web
────────────────────────────────────────

Framework: astro
Data Directory: .cleo-web/

SESSION:
  Status: Active
  Started: 2026-01-25 09:30
  Duration: 1h 45m
  Tasks Completed: 3

TASKS:
  Pending:     5
  In Progress: 1
  Completed:   12

RECENT ACTIVITY:
  • Completed: Fix meta descriptions (T012)
  • Completed: Add schema markup (T011)
  • In Progress: Audit homepage E-E-A-T (T013)

MCP STATUS:
  ✓ gsc - Connected
  ✓ dataforseo - Connected
  ✗ scraperapi - Not configured

NEXT RECOMMENDED:
  1. Complete T013 (in progress)
  2. Run /seo wins for quick optimizations
  3. Audit 3 pending blog posts
```

## Data Sources

- Session data from `.cleo-web/sessions.json`
- Task data from `.cleo-web/todo.json`
- MCP status via runtime check

## Related Commands

- `/start` - Begin a new session
- `/task list` - Detailed task listing
- `/session` - Session management
