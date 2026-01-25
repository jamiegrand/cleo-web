# ct-session-manager

Session management skill for tracking work across multiple days with context persistence.

## Purpose

Provides session lifecycle management including:
- Session start/pause/resume/end
- Work context persistence across sessions
- Time tracking for work sessions
- Session-based task grouping
- Historical session browsing

## Dispatch Triggers

- "start session", "begin session"
- "pause session", "take a break"
- "resume session", "continue session"
- "end session", "finish session"
- "session status", "current session"
- "session history", "past sessions"

## Data Model

### Session Object

```json
{
  "id": "sess_20260124_001",
  "status": "active",
  "startedAt": "2026-01-24T09:00:00Z",
  "pausedAt": null,
  "endedAt": null,
  "totalActiveTime": 7200,
  "context": {
    "siteUrl": "https://example.com",
    "framework": "astro",
    "siteHealthScore": 72,
    "lastAuditAt": "2026-01-24T09:01:30Z"
  },
  "tasksCompleted": ["T001", "T002"],
  "tasksCreated": ["T003"],
  "auditsRun": 3,
  "notes": "Focused on schema fixes today"
}
```

### Session States

| State | Description |
|-------|-------------|
| `active` | Session in progress |
| `paused` | Session paused (break, context switch) |
| `completed` | Session ended normally |
| `abandoned` | Session ended without explicit close |

## Commands

### /session start

Begin a new session. Called automatically by `/start` if no active session.

```
SESSION STARTED
════════════════════════════════════════════════════════════════

Session ID: sess_20260124_001
Started: 2026-01-24 09:00:00

Previous Session (yesterday):
  Duration: 2h 15m
  Tasks completed: 4
  Site health: 69 → 72 (+3)

Resuming context from last session...
  Site: https://example.com
  Framework: Astro 5.0
  Active tasks: 3
```

### /session pause

Pause current session for a break or context switch.

```
SESSION PAUSED
════════════════════════════════════════════════════════════════

Session: sess_20260124_001
Active time: 1h 30m
Tasks completed: 2

In-progress work:
  T003: Optimize homepage LCP (50% complete)
  Last action: Identified hero image as bottleneck

Handoff document saved: .cleo-web/HANDOFF.md

Session saved. Run /session resume to continue.
```

### /session resume

Resume a paused session with full context from HANDOFF.md.

```
SESSION RESUMED
════════════════════════════════════════════════════════════════

Session: sess_20260124_001
Paused for: 45 minutes

Loading handoff document...

Context restored:
  Site health: 72/100 (unchanged)
  Active tasks: 3 (T003 in_progress)
  Last action: Identified hero image as bottleneck

In-progress work:
  T003: Optimize homepage LCP
  Next step: Implement responsive images

Open questions from last session:
  • Need to decide: Use WebP or AVIF for hero image?

Suggested next steps:
  1. Complete T003 (LCP optimization)
  2. Run /seo impact to measure improvement

Ready to continue.
```

### /session end [--note "message"]

End the current session with optional summary note.

```
SESSION ENDED
════════════════════════════════════════════════════════════════

Session: sess_20260124_001
Duration: 2h 45m (active time)

Work Summary:
  Tasks completed: 4
  Tasks created: 2
  Audits run: 3
  Site health: 72 → 78 (+6)

Note: "Completed all schema fixes, started on performance"

See you next time!
```

### /session status

Show current session status.

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

Time breakdown:
  Active: 2h 00m
  Paused: 15m (1 break)
```

### /session history [--limit N]

Browse past sessions.

```
SESSION HISTORY
════════════════════════════════════════════════════════════════

Last 5 sessions:

Jan 24, 2026 (today)
  Duration: 2h 15m | Tasks: 3 | Health: +4
  Note: "Schema fixes"

Jan 23, 2026
  Duration: 1h 45m | Tasks: 2 | Health: +3
  Note: "Quick wins from GSC"

Jan 22, 2026
  Duration: 3h 00m | Tasks: 5 | Health: +8
  Note: "Initial audit and fixes"

Jan 20, 2026
  Duration: 45m | Tasks: 1 | Health: 0
  Note: "Setup and first audit"

Total this week: 7h 45m | 11 tasks completed
```

## Storage

Sessions stored in `.cleo-web/sessions.json`:

```json
{
  "_meta": {
    "schemaVersion": "1.0.0",
    "lastUpdated": "2026-01-24T11:15:00Z"
  },
  "currentSession": "sess_20260124_001",
  "sessions": [
    {
      "id": "sess_20260124_001",
      "status": "active",
      ...
    }
  ]
}
```

## Integration Points

### With /start

`/start` automatically:
1. Checks for active/paused session
2. If paused < 4 hours, offers to resume
3. If no session or paused > 4 hours, starts new session
4. Loads session context into site health check

### With Tasks

Sessions track:
- Tasks completed during session
- Tasks created during session
- Task status changes

### With Audits

Sessions track:
- Number of audits run
- Site health score at start/end
- Issues fixed during session

## Execution Flow

### Starting a Session

1. Check for existing active session
   - If active: Show warning, offer to continue
   - If paused: Check pause duration, offer resume
2. Create new session record
3. Load previous session context (if exists)
4. Initialize session timers
5. Store in sessions.json

### Pausing a Session

1. Record pause timestamp
2. Calculate active time so far
3. Save current context snapshot
4. Generate HANDOFF.md document
5. Update sessions.json

### Resuming a Session

1. Verify session exists and is paused
2. Calculate pause duration
3. Restore context
4. Clear pause timestamp
5. Continue timers

### Ending a Session

1. Record end timestamp
2. Calculate total active time
3. Summarize work done
4. Mark session as completed
5. Clear currentSession
6. Update sessions.json

## Error Handling

### No Active Session

```
No active session found.
Run /start to begin a new session.
```

### Session Already Active

```
Session already active: sess_20260124_001
Started: 2h ago

Options:
  /session status  - View current session
  /session end     - End current session
```

### Stale Paused Session

```
Found paused session from 2 days ago.

Options:
  1. Resume session (context may be stale)
  2. Abandon and start new session

Select option:
```

## HANDOFF.md Generation

When a session is paused, a HANDOFF.md file is generated at `.cleo-web/HANDOFF.md` to provide rich context for resumption.

### HANDOFF.md Structure

```markdown
# Session Handoff

## Session Info
- **Session ID**: sess_20260124_001
- **Paused At**: 2026-01-24 14:30:00
- **Active Time**: 1h 30m

## Current State

### In-Progress Task
- **T003**: Optimize homepage LCP
  - Status: 50% complete
  - Last action: Identified hero image as bottleneck
  - Next step: Implement responsive images

### Site Health
- Score: 72/100 (Fair)
- Change this session: +4 points

## Work Summary
- Tasks completed: 2 (T001, T002)
- Tasks created: 1 (T004)
- Audits run: 1

## Open Questions / Blockers
- Need to decide: Use WebP or AVIF for hero image?
- Waiting on: Client approval for new color scheme

## Context for Resumption
- Working in: /src/pages/index.astro
- Related files: /src/components/Hero.astro
- Relevant audit: Site audit from 2026-01-24

## Suggested Next Steps
1. Complete T003 (LCP optimization)
2. Run /seo impact to measure improvement
3. Start on T004 (Add FAQ schema)
```

### When HANDOFF.md is Generated

- **On `/session pause`**: Always generated
- **On `/session end`**: Not generated (session complete)
- **On auto-pause** (timeout): Generated with stale warning

### When HANDOFF.md is Read

- **On `/session resume`**: Loaded and displayed
- **On `/start`** (with paused session): Shown in resume offer

### HANDOFF.md vs sessions.json

| Aspect | sessions.json | HANDOFF.md |
|--------|--------------|------------|
| Format | JSON (machine) | Markdown (human) |
| Purpose | State persistence | Context restoration |
| Content | Minimal data | Rich narrative |
| Audience | System | Agent + User |

## Dependencies

- `ct-task-manager` - Task tracking integration
- `ct-metrics-store` - Audit history for context
- `lib/file-ops.sh` - Atomic file operations

## MCP Requirements

None required. Session management is local-only.
