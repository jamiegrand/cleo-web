# cleo-web

Task management + SEO workflows for web developers. A Claude Code plugin combining CLEO's task tracking with framework-agnostic SEO auditing.

## Documentation

| Document                                   | Description                    |
| ------------------------------------------ | ------------------------------ |
| [Getting Started](docs/GETTING-STARTED.md) | Installation and setup guide   |
| [User Guide](docs/USER-GUIDE.md)           | Complete feature documentation |
| [MCP Setup](docs/mcp-setup.md)             | MCP server configuration       |

## Features

### Task Management (from CLEO)

- Epic/Task/Subtask hierarchy
- **Session tracking** with pause/resume and context persistence
- Atomic file operations with automatic backups
- JSON Schema validation

### SEO Workflows

- **Site-wide auditing** with 113+ checks across 12 categories
- Content auditing with 0-100 scoring
- **Mobile-specific audits** - Core Web Vitals, viewport, tap targets
- **International SEO** - hreflang validation, geo-targeting
- **Social meta audits** - Open Graph, Twitter Cards
- **User behavior audits** - GA4 engagement, bounce rate, conversions
- **Performance budgets** - Set and track thresholds
- **Competitor benchmarking** - Domain comparison, keyword gaps
- **JSON-LD schema validation** with rich results eligibility checking
- GSC quick wins analysis
- **GA4 engagement analysis** - Organic traffic quality, ROI insights
- E-E-A-T deep dives
- Keyword research caching
- SQLite metrics storage for trend analysis
- **Auto-task creation for ALL issues** (critical, high, medium, low)
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

## Updating

To update an existing installation (preserves your data):

```bash
# Pull latest changes
cd /path/to/cleo-web
git pull

# Update your project
cd your-project
/path/to/cleo-web/update.sh
```

Or use the `/update` command within Claude Code for guidance.

**What gets updated:**
- Skills (overwritten with latest)
- Database schema (migrations applied)

**What's preserved:**
- `.cleo-web/todo.json` (your tasks)
- `.cleo-web/config.json` (your configuration)
- `.cleo-web/metrics.db` (all audit history)

## Quick Start

```bash
# Initialize configuration from .env
/init

# Start a session (verifies MCPs, shows real-time analytics)
/start

# Add a task
/task add "Optimize homepage meta description"

# Run a full site audit (113+ checks, 12 categories)
/audit site

# Run an SEO audit on a specific page
/audit content /blog/my-post "target keyword"

# Find quick wins from GSC
/seo wins

# Analyze engagement from organic traffic
/seo engagement

# Set performance budgets
/budget set lcp 2500

# Track competitors
/competitor add competitor.com --type=direct
```

## Required MCP Servers

cleo-web uses a **fail-fast** approach - commands that need MCPs will fail early with clear setup instructions.

### Core MCPs (Required)

| MCP            | Purpose                                                      | Setup                                            |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------ |
| **gsc**        | Google Search Console data                                   | [GSC MCP Setup](docs/mcp-setup.md#gsc)           |
| **dataforseo** | Keyword research, Lighthouse, backlinks, competitor analysis | [DataForSEO Setup](docs/mcp-setup.md#dataforseo) |
| **scraperapi** | HTML fetching, header analysis, meta tag parsing             | [ScraperAPI Setup](docs/mcp-setup.md#scraperapi) |

### Optional MCPs

| MCP               | Purpose                                           | Setup                                                  |
| ----------------- | ------------------------------------------------- | ------------------------------------------------------ |
| **analytics-mcp** | GA4 real-time traffic, engagement, conversions    | [Analytics MCP Setup](docs/mcp-setup.md#analytics-mcp) |

### Framework MCPs (When Adapter Active)

| MCP            | Framework | Purpose              |
| -------------- | --------- | -------------------- |
| **astro-docs** | Astro     | Documentation search |
| **astro-mcp**  | Astro     | Project integration  |

## Commands

### Setup & Session

| Command            | Description                                             |
| ------------------ | ------------------------------------------------------- |
| `/init`            | Initialize config from .env (SITE_URL, GA_PROPERTY_ID)  |
| `/start`           | Begin session with MCP verification + site health check |
| `/status`          | Show current project and session status                 |
| `/session pause`   | Pause current session                                   |
| `/session resume`  | Resume paused session                                   |
| `/session end`     | End session with summary                                |
| `/session status`  | Show current session status                             |
| `/session history` | Browse past sessions                                    |

### Tasks

| Command             | Description    |
| ------------------- | -------------- |
| `/task add "title"` | Create a task  |
| `/task list`        | List tasks     |
| `/task complete ID` | Mark task done |

### SEO (Requires MCPs)

| Command           | Description                              |
| ----------------- | ---------------------------------------- |
| `/seo wins`       | Quick wins from GSC                      |
| `/seo gaps`       | Content opportunities                    |
| `/seo roi`        | Performance analysis (GSC + GA4)         |
| `/seo refresh`    | Declining pages (GSC + GA4 correlation)  |
| `/seo engagement` | Engagement quality from organic traffic  |

### Site Auditing (Requires all MCPs)

| Command                                | Description                                       |
| -------------------------------------- | ------------------------------------------------- |
| `/audit site`                          | Full site-wide audit (105+ checks, 11 categories) |
| `/audit site --quick`                  | Critical checks only (faster)                     |
| `/audit site --category=NAME`          | Category-specific audit                           |
| `/audit site --skip=mobile,competitor` | Skip specific categories                          |
| `/audit site --fix`                    | Auto-fix supported issues                         |

### Specialized Audits

| Command                | Description                                        |
| ---------------------- | -------------------------------------------------- |
| `/audit mobile [url]`  | Mobile-specific audit (CWV, viewport, tap targets) |
| `/audit international` | hreflang and geo-targeting validation              |
| `/audit social [url]`  | Open Graph and Twitter Card audit                  |
| `/audit behavior`      | User behavior audit (GA4 engagement, bounce rate)  |
| `/audit competitors`   | Competitor benchmarking analysis                   |

### Content Auditing

| Command                   | Description           |
| ------------------------- | --------------------- |
| `/audit content /path`    | Full 0-100 page audit |
| `/audit quick /path`      | 10-point check        |
| `/audit eeat /path`       | E-E-A-T deep dive     |
| `/audit batch collection` | Batch audit pages     |

### Performance Budgets

| Command                        | Description                      |
| ------------------------------ | -------------------------------- |
| `/budget set <metric> <value>` | Set a performance budget         |
| `/budget list`                 | Show all budgets with compliance |
| `/budget clear <metric>`       | Remove a budget                  |

### Competitor Tracking

| Command                        | Description               |
| ------------------------------ | ------------------------- |
| `/competitor add <domain>`     | Add competitor to track   |
| `/competitor list`             | Show tracked competitors  |
| `/competitor remove <domain>`  | Stop tracking competitor  |
| `/competitor analyze [domain]` | Deep competitive analysis |

### Development (Astro Projects)

| Command                  | Description                                                |
| ------------------------ | ---------------------------------------------------------- |
| `/astro-check`           | Pre-deployment validation (config, routes, best practices) |
| `/astro-check --fix`     | Auto-fix supported issues                                  |
| `/feature "description"` | Spec-driven feature development workflow                   |

### Meta Commands

| Command         | Description                                   |
| --------------- | --------------------------------------------- |
| `/init`         | Initialize config from .env file              |
| `/update`       | Update skills and run database migrations     |
| `/help`         | Show all available commands with descriptions |
| `/setup verify` | Verify installation and MCP configuration     |
| `/setup init`   | Re-initialize data directory                  |
| `/setup mcps`   | Show MCP setup instructions                   |

## Audit Categories

The site audit covers 12 categories with weighted scoring:

| Category        | Weight | Checks | Description                                     |
| --------------- | ------ | ------ | ----------------------------------------------- |
| Technical SEO   | 11%    | 12     | robots.txt, sitemap, canonical, HTTPS           |
| Schema Markup   | 8%     | 7      | Organization, WebSite, Article, FAQ             |
| E-E-A-T         | 11%    | 8      | Author, about page, dates, citations            |
| On-Page SEO     | 11%    | 20     | Titles, meta, headings, images, social meta     |
| AI Optimization | 7%     | 5      | Quotable sections, FAQ format                   |
| Performance     | 11%    | 17     | Core Web Vitals, budgets                        |
| Accessibility   | 8%     | 8      | Contrast, keyboard, ARIA                        |
| Security        | 7%     | 8      | Headers, SSL, privacy                           |
| Mobile          | 7%     | 10     | Mobile CWV, viewport, tap targets               |
| International   | 5%     | 8      | hreflang, lang attribute, geo-targeting         |
| Behavior        | 9%     | 8      | GA4 engagement, bounce rate, session duration   |
| Competitor      | 5%     | 8      | Domain rank, keyword gaps, backlinks            |

## Configuration

Create a `.env` file in your project root:

```env
# Required
SITE_URL=https://your-site.com

# ============================================
# Google Analytics (Optional)
# ============================================
# Property ID - for API access (Admin → Property Settings)
GA_PROPERTY_ID=347541531

# Measurement ID - for frontend tracking (optional, not used by cleo-web)
PUBLIC_GA_ID=G-XXXXXXXXXX

# Optional - auto-detected if not set
FRAMEWORK=astro
```

Run `/init` to generate `.cleo-web/config.json` from your `.env` file.

### Finding Your GA4 Property ID

1. Go to [Google Analytics](https://analytics.google.com)
2. Admin → Property Settings
3. Copy the **Property ID** (numeric, e.g., `347541531`)
4. Add to `.env` as: `GA_PROPERTY_ID=347541531`

> **Note:** The Property ID (numeric) is different from the Measurement ID (`G-XXXXXX`). cleo-web uses the Property ID for API access.

### Google Analytics Authentication

To use analytics-mcp, authenticate with the required scopes:

```bash
gcloud auth application-default login --scopes="https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/cloud-platform"
```

This is required for GA4 Data API access. Run this once, or again if you see "insufficient scopes" errors.

## Data Storage

### JSON Files (Atomic Operations)

```
.cleo-web/
├── todo.json        # Task state
├── config.json      # Configuration (from /init)
└── backups/         # Automatic backups
```

### SQLite Database (Time-Series)

```
.cleo-web/metrics.db
├── site_audits          # Site-wide audit scores (12 categories)
├── audit_checks         # Individual check results
├── check_definitions    # 113+ check definitions
├── lighthouse_snapshots # Core Web Vitals history
├── backlink_snapshots   # Backlink profile history
├── mobile_audits        # Mobile-specific results
├── hreflang_analysis    # International SEO data
├── social_meta_analysis # OG/Twitter tag data
├── behavior_analysis    # GA4 engagement metrics
├── performance_budgets  # Budget thresholds
├── budget_compliance    # Budget compliance history
├── competitors          # Tracked competitors
├── competitor_snapshots # Competitor comparison data
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
├── .claude/skills/  # Claude Code slash commands
├── adapters/        # Framework adapters
├── lib/             # Bash libraries
├── schemas/         # JSON Schema definitions
└── scripts/         # SQLite scripts (migrations)
```

## Auto-Task Creation

All audit issues automatically create tasks in `todo.json`:

| Severity | Task Priority |
| -------- | ------------- |
| Critical | critical      |
| High     | high          |
| Medium   | medium        |
| Low      | low           |

Tasks include audit metadata (check code, category, fix suggestion) for full traceability.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT
