# cleo-web

Task management + SEO workflows for web developers. A Claude Code plugin combining CLEO's task tracking with framework-agnostic SEO auditing.

## Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/GETTING-STARTED.md) | Installation and setup guide |
| [User Guide](docs/USER-GUIDE.md) | Complete feature documentation |
| [MCP Setup](docs/mcp-setup.md) | MCP server configuration |

## Features

### Task Management (from CLEO)
- Epic/Task/Subtask hierarchy
- **Session tracking** with pause/resume and context persistence
- Atomic file operations with automatic backups
- JSON Schema validation

### SEO Workflows (from Astro SEO Agency)
- **Site-wide auditing** with 60+ checks across 8 categories
- Content auditing with 0-100 scoring
- **JSON-LD schema validation** with rich results eligibility checking
- GSC quick wins analysis
- E-E-A-T deep dives
- Keyword research caching
- SQLite metrics storage for trend analysis
- Auto-task creation for critical issues
- Optional visual testing with Playwright

### Framework Adapters
- **Astro** - Full support with route detection
- **Next.js** - Coming soon
- **Nuxt** - Coming soon

## Installation

```bash
# Clone the repository
git clone https://github.com/jamiegrand/cleo-web.git

# Install in your project
cd your-project
/path/to/cleo-web/install.sh
```

## Quick Start

```bash
# Start a session (verifies MCPs, shows priorities)
/start

# Add a task
/task add "Optimize homepage meta description"

# Run an SEO audit
/audit content /blog/my-post "target keyword"

# Find quick wins from GSC
/seo wins
```

## Required MCP Servers

cleo-web uses a **fail-fast** approach - commands that need MCPs will fail early with clear setup instructions.

### Core MCPs (Required)

| MCP | Purpose | Setup |
|-----|---------|-------|
| **gsc** | Google Search Console data | [GSC MCP Setup](docs/mcp-setup.md#gsc) |
| **dataforseo** | Keyword research, Lighthouse, backlinks | [DataForSEO Setup](docs/mcp-setup.md#dataforseo) |
| **scraperapi** | HTML fetching, header analysis | [ScraperAPI Setup](docs/mcp-setup.md#scraperapi) |

### Framework MCPs (When Adapter Active)

| MCP | Framework | Purpose |
|-----|-----------|---------|
| **astro-docs** | Astro | Documentation search |
| **astro-mcp** | Astro | Project integration |

## Commands

### Session
| Command | Description |
|---------|-------------|
| `/start` | Begin session with MCP verification + site health check |
| `/session pause` | Pause current session |
| `/session resume` | Resume paused session |
| `/session end` | End session with summary |
| `/session status` | Show current session status |
| `/session history` | Browse past sessions |

### Tasks
| Command | Description |
|---------|-------------|
| `/task add "title"` | Create a task |
| `/task list` | List tasks |
| `/task complete ID` | Mark task done |

### SEO (Requires MCPs)
| Command | Description |
|---------|-------------|
| `/seo wins` | Quick wins from GSC |
| `/seo gaps` | Content opportunities |
| `/seo roi` | Performance analysis |
| `/seo refresh` | Declining pages |

### Site Auditing (Requires all MCPs)
| Command | Description |
|---------|-------------|
| `/audit site` | Site-wide audit (60+ checks) |
| `/audit site --full` | Detailed full report |
| `/audit site --category=NAME` | Category-specific audit |
| `/audit site --fix` | Auto-fix supported issues |

### Content Auditing
| Command | Description |
|---------|-------------|
| `/audit content /path` | Full 0-100 page audit |
| `/audit quick /path` | 10-point check |
| `/audit eeat /path` | E-E-A-T deep dive |
| `/audit batch collection` | Batch audit pages |

## Data Storage

### JSON Files (Atomic Operations)
```
.cleo-web/
├── todo.json        # Task state
├── config.json      # Configuration
└── backups/         # Automatic backups
```

### SQLite Database (Time-Series)
```
.cleo-web/metrics.db
├── site_audits          # Site-wide audit scores
├── audit_checks         # Individual check results
├── check_definitions    # Check metadata
├── lighthouse_snapshots # Core Web Vitals history
├── backlink_snapshots   # Backlink profile history
├── audits               # Page-level audit history
├── keywords             # Keyword cache
├── gsc_snapshots        # GSC performance
└── audit_issues         # Issue tracking
```

## Architecture

```
cleo-web/
├── plugin.json      # Plugin manifest
├── commands/        # Markdown command definitions
├── skills/          # CLEO-style skills
├── adapters/        # Framework adapters
├── lib/             # Bash libraries
├── schemas/         # JSON Schema definitions
└── scripts/         # SQLite scripts
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT
