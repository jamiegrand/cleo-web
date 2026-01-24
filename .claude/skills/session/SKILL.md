---
name: session
description: Session management - pause, resume, end, status
disable-model-invocation: true
argument-hint: [pause|resume|end|status|history]
---

# Session Management Command

Usage: `/session <subcommand>`

## Subcommands

### `/session pause` - Pause Session
Save current session state for later:

1. Record current timestamp
2. Save session context to `.cleo-web/session.json`:
   - Active task IDs
   - Current focus area
   - Notes/progress
3. Display pause confirmation with resume instructions

### `/session resume` - Resume Session
Continue from where you left off:

1. Read `.cleo-web/session.json`
2. Display session context:
   - Time since pause
   - Active tasks
   - Last focus area
3. Offer to continue with specific task

### `/session end` - End Session
Complete the session with summary:

1. Generate session summary:
   - Tasks completed this session
   - Time worked (if tracked)
   - Changes to site health score
2. Archive session data
3. Clear active session state

### `/session status` - Current Status
Show current session information:

1. Check if session is active
2. Display:
   - Session start time
   - Tasks worked on
   - Current focus
   - MCP connection status

### `/session history` - View Past Sessions
List previous sessions:

1. Query `.cleo-web/metrics.db` for session records
2. Show recent sessions with:
   - Date/time
   - Duration
   - Tasks completed
   - Notes

## Session Data
Stored in `.cleo-web/session.json`:
```json
{
  "active": true,
  "startedAt": "2024-01-01T09:00:00Z",
  "pausedAt": null,
  "focus": "Schema optimization",
  "tasksWorked": ["T015", "T018"],
  "notes": "Working on blog schema markup"
}
```

## Arguments
$ARGUMENTS
