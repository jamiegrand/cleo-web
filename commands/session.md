---
description: Manage work sessions with context persistence
---

# /session

Manage work sessions for tracking progress across multiple days.

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `/session start` | Begin a new session |
| `/session pause` | Pause current session |
| `/session resume` | Resume paused session |
| `/session end` | End current session |
| `/session status` | Show current session status |
| `/session history` | Browse past sessions |

## /session start

Begin a new work session. Automatically called by `/start`.

```
/session start
```

**Output:**
```
SESSION STARTED
════════════════════════════════════════════════════════════════

Session ID: sess_20260124_001
Started: 2026-01-24 09:00:00

Previous Session (yesterday):
  Duration: 2h 15m
  Tasks completed: 4
  Site health: 69 → 72 (+3)

Ready to work.
```

## /session pause

Pause current session for a break or context switch.

```
/session pause
```

**Output:**
```
SESSION PAUSED
════════════════════════════════════════════════════════════════

Session: sess_20260124_001
Active time: 1h 30m
Tasks completed this session: 2

Context saved. Run /session resume to continue.
```

## /session resume

Resume a paused session with full context restoration.

```
/session resume
```

**Output:**
```
SESSION RESUMED
════════════════════════════════════════════════════════════════

Session: sess_20260124_001
Paused for: 45 minutes

Context restored:
  Site health: 72/100
  Active tasks: 3
  Last action: Completed T002

Ready to continue.
```

## /session end

End the current session with an optional note.

```
/session end
/session end --note "Completed schema fixes"
```

**Output:**
```
SESSION ENDED
════════════════════════════════════════════════════════════════

Session: sess_20260124_001
Duration: 2h 45m

Work Summary:
  Tasks completed: 4
  Tasks created: 2
  Audits run: 3
  Site health: 72 → 78 (+6)

See you next time!
```

## /session status

Show current session status and progress.

```
/session status
```

**Output:**
```
CURRENT SESSION
════════════════════════════════════════════════════════════════

Session: sess_20260124_001
Status: active
Started: 2h 15m ago

Progress:
  Tasks completed: 3
  Tasks in progress: 1 (T004)
  Site health change: +4 points

Time:
  Active: 2h 00m
  Paused: 15m (1 break)
```

## /session history

Browse past sessions.

```
/session history
/session history --limit 10
```

**Output:**
```
SESSION HISTORY
════════════════════════════════════════════════════════════════

Last 5 sessions:

Jan 24, 2026 (today) - ACTIVE
  Duration: 2h 15m | Tasks: 3 | Health: +4

Jan 23, 2026
  Duration: 1h 45m | Tasks: 2 | Health: +3
  Note: "Quick wins from GSC"

Jan 22, 2026
  Duration: 3h 00m | Tasks: 5 | Health: +8
  Note: "Initial audit and fixes"

Jan 20, 2026
  Duration: 45m | Tasks: 1 | Health: 0
  Note: "Setup and first audit"

────────────────────────────────────────────────────────────────
Total this week: 7h 45m | 11 tasks completed
Average session: 1h 56m
```

## Session States

| State | Description |
|-------|-------------|
| `active` | Session in progress |
| `paused` | Session paused |
| `completed` | Session ended normally |
| `abandoned` | Session closed without explicit end |

## Integration with /start

When running `/start`:

1. Check for active session
   - If active and recent: Continue session
   - If paused < 4 hours: Offer to resume

2. Check for paused session
   - If paused > 4 hours: Mark as abandoned, start new

3. Start new session if needed
   - Load previous session context
   - Show previous session summary

## Data Storage

Sessions stored in `.cleo-web/sessions.json`:

```json
{
  "_meta": {
    "schemaVersion": "1.0.0"
  },
  "currentSession": "sess_20260124_001",
  "sessions": [...]
}
```

## Session Context

Each session tracks:
- Site URL and framework
- Site health score at start/end
- Tasks completed during session
- Tasks created during session
- Audits run
- User notes

## Notes

- Sessions persist across Claude Code restarts
- Paused sessions automatically marked abandoned after 24 hours
- Session history kept for 30 days
- Use notes to document what you worked on
