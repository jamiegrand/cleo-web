# AGENTS.md
> cleo-web Architecture Guide for AI Agents

You operate within a **3-Layer Architecture** that separates concerns to maximize reliability. LLMs are probabilistic; business logic is deterministic. This system bridges that gap through disciplined separation of intent, intelligence, and execution.

---

## Table of Contents

1. [The 3-Layer Architecture](#the-3-layer-architecture)
2. [Operating Principles](#operating-principles)
3. [Agent Personas](#agent-personas)
4. [Command System](#command-system)
5. [Skills System](#skills-system)
6. [Framework Adapters](#framework-adapters)
7. [Tool Use & MCPs](#tool-use--mcps)
8. [Memory & Storage](#memory--storage)
9. [Error Handling](#error-handling)
10. [Workflow Patterns](#workflow-patterns)
11. [File Organization](#file-organization)

---

## The 3-Layer Architecture

### Why This Architecture?

If you do everything yourself, errors compound exponentially:
- 90% accuracy per step = **59% success** over 5 steps
- 80% accuracy per step = **33% success** over 5 steps

The solution: **push deterministic complexity into code, keep probabilistic decision-making in the LLM**.

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: DIRECTIVE (What to do)                            │
│  ├── Commands in /commands/*.md                             │
│  ├── Skills in /skills/*/SKILL.md                           │
│  ├── Adapters in /adapters/*/ADAPTER.md                     │
│  └── Natural language instructions with YAML frontmatter    │
├─────────────────────────────────────────────────────────────┤
│  LAYER 2: ORCHESTRATION (Decision making) ← YOU ARE HERE    │
│  ├── Intelligent routing between commands                   │
│  ├── Read directives, call execution tools                  │
│  ├── Handle errors, self-heal when possible                 │
│  └── Ask for clarification when uncertain                   │
├─────────────────────────────────────────────────────────────┤
│  LAYER 3: EXECUTION (Doing the work)                        │
│  ├── Bash libraries in /lib/*.sh                            │
│  ├── SQLite database in .cleo-web/metrics.db                │
│  ├── JSON storage with atomic operations                    │
│  └── MCP servers for external data                          │
└─────────────────────────────────────────────────────────────┘
```

### Layer 1: Directive (The "What")

Directives are markdown files that define what to do:

**Commands** (`/commands/*.md`):
```markdown
---
description: What this command does
requires: [list, of, mcps]
---
# /command-name

Step-by-step instructions for the agent to follow.
```

**Skills** (`/skills/*/SKILL.md`):
```markdown
---
name: skill-name
capabilities: [list, of, capabilities]
dispatch_triggers: ["phrases that activate this skill"]
---
# Skill Name

Detailed capability documentation with inputs, outputs, and examples.
```

**Adapters** (`/adapters/*/ADAPTER.md`):
```markdown
---
name: framework-adapter
detects: [config.files, to.detect]
requires: [framework-specific, mcps]
---
# Framework Adapter

Framework-specific behaviors and enhancements.
```

### Layer 2: Orchestration (The "How" - Your Role)

You are the intelligent glue between human intent and deterministic execution:

1. **Parse Intent**: Understand what the user actually wants
2. **Select Command**: Find the appropriate command or skill
3. **Verify Prerequisites**: Check MCP availability before proceeding
4. **Execute Steps**: Follow command instructions methodically
5. **Handle Results**: Process outputs, create tasks for issues
6. **Report Back**: Summarize results clearly to the user

**Key principle**: Don't reinvent the wheel—use existing commands, skills, and libraries.

### Layer 3: Execution (The "Do")

Execution happens through:

**Bash Libraries** (`/lib/*.sh`):
- `file-ops.sh` - Atomic writes, file locking, backups
- `mcp-check.sh` - MCP verification with fail-fast
- `audit-tasks.sh` - Auto-task creation from audit findings
- `schema-validator.sh` - JSON-LD validation
- `validation.sh` - Input validation utilities

**Data Storage**:
- `.cleo-web/todo.json` - Task management (atomic operations)
- `.cleo-web/sessions.json` - Session tracking
- `.cleo-web/config.json` - Project configuration
- `.cleo-web/metrics.db` - SQLite for time-series data

**MCP Servers**:
- `gsc` - Google Search Console data
- `dataforseo` - Keyword research and SERP data
- `scraperapi` - HTML fetching and analysis
- `astro-docs` - Astro documentation (when using Astro)
- `astro-mcp` - Astro project integration (when using Astro)

---

## Operating Principles

### 1. Check for Existing Tools First

Before doing anything:
1. Check if a command exists for this task (`/commands/`)
2. Check if a skill provides this capability (`/skills/`)
3. Check if an MCP server can help (`plugin.json`)
4. Only write new code if nothing exists

### 2. Fail Fast with MCPs

Commands specify required MCPs in their frontmatter:
```yaml
requires: [gsc, dataforseo]
```

**Before executing any command that requires MCPs:**
1. Verify each MCP is available
2. If missing, show setup instructions from `/docs/mcp-setup.md`
3. Do NOT proceed with partial functionality

### 3. Use Atomic Operations

All file writes go through `lib/file-ops.sh`:
- Write to temp file first
- Atomic move to final location
- Auto-backup before overwrite (5 backups retained)
- File locking for multi-agent safety

**Never** write directly to JSON files—always use the atomic patterns.

### 4. Self-Heal When Things Break

The **Self-Healing Loop**:
```
Error Occurs
    ↓
Read error message + context
    ↓
Diagnose root cause
    ↓
Can you fix it safely?
    ├── YES → Fix, test, continue
    └── NO → Report to user with clear explanation
    ↓
Learn from the error (update docs if needed)
```

### 5. Create Tasks for Issues

When audits or analysis find issues:
- **Critical/High severity** → Auto-create task
- **Medium/Low severity** → Report but don't auto-create
- Tasks include source metadata (check code, category, impact)

### 6. Prefer Simplicity

From Anthropic's research: "The most successful implementations use simple, composable patterns rather than complex frameworks."

- Start with the simplest solution
- Add complexity only when proven necessary
- A good command beats a complex agent workflow

---

## Agent Personas

cleo-web uses three specialized agent personas. Each has distinct expertise and tools.

### Astro Maintainer

**Expertise**: Astro framework, configuration, deployment

**When to use**:
- Astro-specific questions or issues
- Pre-deployment validation
- Config optimization
- Migration and upgrade guidance

**Tools**: `astro-mcp`, `astro-docs`

**File**: `agents/astro-maintainer.md`

### Content Strategist

**Expertise**: E-E-A-T, AI optimization, content lifecycle

**When to use**:
- Content auditing and scoring
- E-E-A-T analysis
- AI Overview optimization
- Content refresh decisions

**Tools**: `dataforseo`, `scraperapi`

**File**: `agents/content-strategist.md`

### SEO Analyst

**Expertise**: GSC data, rankings, opportunities

**When to use**:
- Quick wins analysis
- Content gap discovery
- ROI projections
- Ranking trend analysis

**Tools**: `gsc`, `dataforseo`

**File**: `agents/seo-analyst.md`

---

## Command System

### Command Types

| Type | Description | Example |
|------|-------------|---------|
| **Router** | Routes to subcommands | `/seo`, `/audit`, `/task` |
| **Implementation** | Executes specific action | `/seo-wins`, `/audit-content` |

### Router Pattern

Top-level commands route to implementations:
```
/seo wins      → /seo-wins
/seo gaps      → /seo-gaps
/audit content → /audit-content
/task add      → /task-add
```

### Command Categories

| Category | Commands | Purpose |
|----------|----------|---------|
| **Session** | start, status, session | Manage work sessions |
| **Tasks** | task (add/list/complete) | Task management |
| **SEO** | seo (wins/gaps/roi/refresh/impact/keywords) | SEO analysis |
| **Quality** | audit (content/quick/eeat/batch/site) | Content auditing |
| **Meta** | setup, help | Configuration |

### Command Execution Flow

1. User invokes command (e.g., `/seo wins`)
2. Router identifies implementation (`/seo-wins`)
3. Check `requires:` MCPs are available
4. Execute command steps
5. Store results in metrics.db if applicable
6. Create tasks for critical/high issues
7. Display formatted output

---

## Skills System

Skills are reusable capabilities that commands invoke.

### Available Skills

| Skill | Capabilities | Triggers |
|-------|--------------|----------|
| `ct-task-manager` | CRUD operations on tasks | "create task", "list tasks" |
| `ct-seo-auditor` | Content auditing, 0-100 scoring | "audit content", "eeat analysis" |
| `ct-gsc-analyst` | GSC analysis, quick wins | "quick wins", "ranking analysis" |
| `ct-content-strategist` | Keyword research, topic planning | "keyword research", "content strategy" |
| `ct-metrics-store` | SQLite storage, history | "store audit", "get history" |
| `ct-session-manager` | Session lifecycle | "start session", "pause session" |

### Skill Dispatch

Skills can be triggered by:
1. **Explicit command**: `/audit content /page "keyword"`
2. **Natural language**: "audit the homepage for SEO"
3. **Dispatch trigger**: Matches phrases in `dispatch_triggers`

### Skill Integration

Skills work together:
```
User: "Audit /blog/my-post for 'react hooks'"
    ↓
ct-seo-auditor (runs audit)
    ↓
ct-metrics-store (saves results)
    ↓
ct-task-manager (creates tasks for issues)
```

---

## Framework Adapters

Adapters provide framework-specific intelligence.

### Astro Adapter (Active)

**Detection**: `astro.config.mjs`, `astro.config.js`, `astro.config.ts`

**Capabilities**:
- Route enumeration via `astro-mcp`
- Content collection discovery
- Config validation
- Best practice checks (client directives, image optimization)

**Required MCPs**: `astro-docs`, `astro-mcp`

### Next.js Adapter (Planned)

**Detection**: `next.config.js`, `next.config.mjs`

**Status**: Not yet implemented

### Nuxt Adapter (Planned)

**Detection**: `nuxt.config.js`, `nuxt.config.ts`

**Status**: Not yet implemented

---

## Tool Use & MCPs

### MCP Configuration

MCPs are configured in `plugin.json`:

```json
{
  "mcp": {
    "servers": {
      "gsc": {
        "description": "Google Search Console API",
        "required": true,
        "requiredFor": ["seo-wins", "seo-gaps", "seo-roi"]
      },
      "dataforseo": {
        "description": "Keyword research, SERP data",
        "required": true,
        "requiredFor": ["seo-keywords", "audit-content"]
      }
    }
  }
}
```

### MCP Verification

Before any command requiring MCPs:

```
┌─────────────────────────────────────────┐
│         MCP Verification Flow           │
├─────────────────────────────────────────┤
│ 1. Read command's requires: field       │
│ 2. Check each MCP is available          │
│ 3. If missing:                          │
│    - Show which MCP is missing          │
│    - Display setup instructions         │
│    - STOP execution                     │
│ 4. If all present:                      │
│    - Proceed with command               │
└─────────────────────────────────────────┘
```

### Available MCPs

| MCP | Purpose | Required For |
|-----|---------|--------------|
| `gsc` | Rankings, impressions, CTR | seo-wins, seo-gaps, seo-roi, seo-refresh, seo-impact |
| `dataforseo` | Keywords, volume, difficulty | seo-keywords, audit-content, seo-gaps |
| `scraperapi` | HTML fetching, headers | audit-site, audit-content |
| `astro-docs` | Astro documentation | astro-check (when using Astro) |
| `astro-mcp` | Astro project state | astro-check, status (when using Astro) |

---

## Memory & Storage

### Short-Term Memory

**Sessions** (`.cleo-web/sessions.json`):
```json
{
  "currentSession": "sess_20260125_001",
  "sessions": [{
    "id": "sess_20260125_001",
    "status": "active",
    "startedAt": "2026-01-25T09:00:00Z",
    "tasksCompleted": ["T001", "T002"],
    "context": {
      "siteUrl": "https://example.com",
      "framework": "astro",
      "siteHealthScore": 72
    }
  }]
}
```

### Long-Term Memory

**SQLite Database** (`.cleo-web/metrics.db`):

| Table | Purpose |
|-------|---------|
| `audits` | Page-level audit scores (0-100) |
| `audit_issues` | Individual issues with severity |
| `site_audits` | Site-wide audit results |
| `keywords` | Cached keyword research |
| `paa_questions` | People Also Ask data |
| `gsc_snapshots` | GSC metrics over time |
| `lighthouse_snapshots` | Core Web Vitals history |

**Views for Common Queries**:
- `latest_audits` - Most recent score per page
- `pages_needing_attention` - Low-scoring pages
- `score_trends` - Audit changes over time
- `open_issues` - Unfixed issues by severity

### Task Storage

**Tasks** (`.cleo-web/todo.json`):
```json
{
  "_meta": {
    "schemaVersion": "1.0.0"
  },
  "tasks": [{
    "id": "T001",
    "content": "Add Organization schema",
    "status": "pending",
    "priority": "critical",
    "labels": ["audit", "schema"],
    "source": "audit-site",
    "audit": {
      "check_code": "SCHEMA001",
      "category": "schema",
      "impact": "+15 points"
    }
  }]
}
```

---

## Error Handling

### Error Classification

```
┌─────────────────────────────────────────────────────────────────┐
│                     ERROR TAXONOMY                               │
├─────────────────────────────────────────────────────────────────┤
│ MCP ERRORS (Fail fast, show setup)                              │
│ ├── MCP not configured                                          │
│ ├── MCP server not running                                      │
│ └── MCP authentication failed                                   │
├─────────────────────────────────────────────────────────────────┤
│ VALIDATION ERRORS (Report and stop)                             │
│ ├── Invalid input format                                        │
│ ├── Missing required parameters                                 │
│ └── File not found                                              │
├─────────────────────────────────────────────────────────────────┤
│ EXECUTION ERRORS (Attempt recovery)                             │
│ ├── API rate limits → Retry with backoff                        │
│ ├── Temporary failures → Retry once                             │
│ └── Partial success → Report what worked                        │
├─────────────────────────────────────────────────────────────────┤
│ FATAL ERRORS (Escalate to user)                                 │
│ ├── Data corruption                                             │
│ ├── Permission denied                                           │
│ └── Unknown/unexpected errors                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Error Messages

Good error messages include:
1. **What failed**: Clear description
2. **Why it failed**: Root cause if known
3. **How to fix it**: Actionable steps

Example:
```
ERROR: GSC MCP required for /seo wins

The Google Search Console MCP is not available.

Setup instructions:
1. Install: npm install -g gsc-mcp-server
2. Add to Claude Code settings
3. Configure credentials (see docs/mcp-setup.md)
4. Restart Claude Code

Run /start to verify setup.
```

---

## Workflow Patterns

### Daily SEO Workflow

```
/start
    ↓
Session starts, MCP verification, site health check
    ↓
/seo wins
    ↓
Identify quick wins (positions 4-15)
    ↓
/audit content /page "keyword"
    ↓
Score content, create tasks for issues
    ↓
Fix issues (tasks auto-created)
    ↓
/seo impact /page
    ↓
Measure improvement
    ↓
/session end
```

### Site Audit Workflow

```
/audit site
    ↓
Run 8-category audit (60+ checks)
    ↓
Auto-create tasks for critical/high issues
    ↓
/task list --status pending
    ↓
Work through tasks by priority
    ↓
/audit site --category=fixed-category
    ↓
Verify improvements
```

### Content Refresh Workflow

```
/seo refresh
    ↓
Find declining pages (position drops, traffic decline)
    ↓
/audit content /declining-page "keyword"
    ↓
Identify specific issues
    ↓
Update content
    ↓
/seo impact /page 30 30
    ↓
Compare 30 days before vs after
```

---

## File Organization

```
cleo-web/
├── AGENTS.md               # This file - architecture guide
├── plugin.json             # Plugin manifest and configuration
├── install.sh              # Installation script
├── README.md               # User documentation
│
├── agents/                 # Agent persona definitions
│   ├── astro-maintainer.md
│   ├── content-strategist.md
│   └── seo-analyst.md
│
├── commands/               # Layer 1: Command directives
│   ├── start.md
│   ├── session.md
│   ├── task.md
│   ├── seo.md
│   ├── audit.md
│   ├── audit-site.md
│   └── ...
│
├── skills/                 # Reusable capability modules
│   ├── manifest.json
│   ├── ct-task-manager/
│   ├── ct-seo-auditor/
│   ├── ct-gsc-analyst/
│   ├── ct-content-strategist/
│   ├── ct-metrics-store/
│   └── ct-session-manager/
│
├── lib/                    # Layer 3: Execution scripts
│   ├── file-ops.sh         # Atomic writes, locking
│   ├── mcp-check.sh        # MCP verification
│   ├── audit-tasks.sh      # Auto-task creation
│   ├── schema-validator.sh # JSON-LD validation
│   └── validation.sh       # Input validation
│
├── adapters/               # Framework-specific adapters
│   └── astro/
│       └── ADAPTER.md
│
├── scripts/                # Database migrations
│   ├── init-db.sql
│   └── migrate-*.sql
│
├── docs/                   # Documentation
│   ├── GETTING-STARTED.md
│   ├── USER-GUIDE.md
│   └── mcp-setup.md
│
└── .cleo-web/              # Runtime data (created by install)
    ├── todo.json
    ├── sessions.json
    ├── config.json
    ├── metrics.db
    └── backups/
```

---

## Quick Reference

### Command Cheat Sheet

| Command | Purpose |
|---------|---------|
| `/start` | Begin session, verify MCPs |
| `/session pause` | Pause with context save |
| `/session resume` | Resume with context restore |
| `/task add "title"` | Create task |
| `/task list` | View tasks |
| `/seo wins` | Find quick wins |
| `/seo gaps` | Find content gaps |
| `/seo roi /page` | ROI projection |
| `/audit content /page "kw"` | Full content audit |
| `/audit site` | Site-wide audit |
| `/audit site --fix` | Auto-fix issues |

### Decision Flow

```
User Request Received
        ↓
Does a command exist for this?
    ├── YES → Execute command
    └── NO → Can a skill handle it?
        ├── YES → Invoke skill
        └── NO → Ask for clarification
        ↓
Are required MCPs available?
    ├── YES → Proceed
    └── NO → Show setup instructions, STOP
        ↓
Execute with error handling
        ↓
Store results, create tasks if needed
        ↓
Report to user
```

---

**Remember**: You orchestrate, tools execute. Keep it simple, fail fast, self-heal when possible.
