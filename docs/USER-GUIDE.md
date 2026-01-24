# cleo-web User Guide

Complete guide to using cleo-web for task management and SEO workflows.

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Task Management](#task-management)
4. [SEO Commands](#seo-commands)
5. [Site Auditing](#site-auditing)
6. [Content Auditing](#content-auditing)
7. [Configuration](#configuration)
8. [Multi-Agent Support](#multi-agent-support)
9. [Data Storage](#data-storage)
10. [Workflows](#workflows)
11. [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

| Requirement | Purpose | Check |
|-------------|---------|-------|
| Bash 3.2+ | Script execution | `bash --version` |
| jq | JSON processing | `jq --version` |
| sqlite3 | Metrics storage | `sqlite3 --version` |
| flock (optional) | File locking | `flock --version` |

For macOS, install flock for better multi-agent support:
```bash
brew install discoteq/discoteq/flock
```

### Install cleo-web

```bash
# Navigate to your project
cd your-project

# Run the installer
/path/to/cleo-web/install.sh
```

The installer will:
1. Check prerequisites (jq, flock, sqlite3)
2. Detect your framework (Astro, Next.js, Nuxt)
3. Create `.cleo-web/` data directory
4. Initialize `todo.json`, `config.json`, and `metrics.db`
5. Update your `CLAUDE.md` file

### Configure MCPs

See [MCP Setup Guide](mcp-setup.md) for detailed instructions on configuring:
- Google Search Console MCP (required)
- DataForSEO MCP (required)
- ScraperAPI MCP (required)
- Framework-specific MCPs (optional)

---

## Getting Started

### Start a Session

Every work session should begin with:

```
/start
```

This command:
1. Verifies MCP servers are available (gsc, dataforseo, scraperapi)
2. Detects your framework and loads the adapter
3. Runs automatic site health check (if last audit > 24h old)
4. Creates tasks for critical/high severity issues
5. Loads existing tasks and metrics
6. Generates prioritized work list

**Output example:**
```
╔══════════════════════════════════════════════════════════════╗
║                     cleo-web Session                         ║
╚══════════════════════════════════════════════════════════════╝

MCPs: ✓ gsc  ✓ dataforseo  ✓ scraperapi
Framework: Astro 5.0
Site: https://example.com

────────────────────────────────────────────────────────────────
SITE HEALTH: 72/100 (Fair) ↑3 from last audit

Category Scores:
  Technical SEO      85/100  █████████░
  Schema Markup      45/100  █████░░░░░  ⚠ Issues
  Performance        91/100  █████████░  ✓ Excellent
  Security           88/100  █████████░

⚠ 2 Critical Issues:
  • Missing Organization schema (site-wide)
  • No author bios on blog posts (12 pages)

Run /audit site for full report
────────────────────────────────────────────────────────────────

TODAY'S PRIORITIES:

1. [Critical] T001: Add Organization schema to site layout
2. [Critical] T002: Add author bios to blog posts (12 pages)
3. [Quick Win] /blog/react-hooks at position 8 (+2.4k clicks potential)
4. [Task] T003: Optimize homepage LCP - hero image

Commands:
  /audit site       Full site audit (8 categories, 60+ checks)
  /audit content    Audit single page with keyword
  /seo wins         Quick win opportunities
  /task list        View all tasks
```

### Quick Commands Reference

| Command | Description |
|---------|-------------|
| `/start` | Begin session with site health check |
| `/task add "title"` | Create a task |
| `/task list` | Show all tasks |
| `/audit site` | Full site-wide audit (60+ checks) |
| `/audit content /path "keyword"` | Single page SEO audit |
| `/seo wins` | Find quick opportunities |

---

## Task Management

cleo-web provides robust task management with atomic operations and multi-agent safety.

### Creating Tasks

```
/task add "Optimize homepage meta description"
```

**Output:**
```
Created task T001: Optimize homepage meta description
  Status: pending
  Created: 2025-01-24T10:00:00Z
```

### Listing Tasks

```
/task list
```

**Output:**
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

Filter by status:
```
/task list --status pending
/task list --status in_progress
/task list --status completed
```

### Completing Tasks

```
/task complete T001
```

**Output:**
```
Completed task T001: Optimize meta descriptions for blog posts
  Completed: 2025-01-24T14:30:00Z
```

### Updating Tasks

```
/task update T001 --status in_progress
/task update T001 --priority high
/task update T001 --labels "seo,technical"
```

### Deleting Tasks

```
/task delete T001
```

You'll be asked to confirm before deletion.

### Task Schema

Tasks are stored with this structure:

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

---

## SEO Commands

SEO commands require the GSC and DataForSEO MCPs. If MCPs are not configured, you'll receive setup instructions.

### Quick Wins

Find optimization opportunities with high impact:

```
/seo wins
```

**Output:**
```
QUICK WINS (12 opportunities)

1. /blog/react-hooks-guide
   Keyword: "react hooks tutorial"
   Position: 8.2 | Impressions: 2,400/mo | CTR: 1.2%
   Opportunity: Move to top 3 for +3,200 clicks/mo
   Action: Improve title tag, add FAQ schema

2. /services/web-development
   Keyword: "web development services"
   Position: 11.5 | Impressions: 1,800/mo | CTR: 0.8%
   Opportunity: Optimize for featured snippet
   Action: Add comparison table, improve H1
```

### Content Gaps

Identify missing content opportunities:

```
/seo gaps
```

**Output:**
```
CONTENT GAPS (8 opportunities)

Missing Topics:
1. "next.js tutorial" - 12,000/mo, KD: 42
   Competitors ranking: example.com, other.com
   Recommendation: Create comprehensive guide

2. "react vs vue 2025" - 8,500/mo, KD: 35
   No content covering this topic
   Recommendation: Comparison article with code examples
```

### ROI Projection

Calculate potential return on SEO investment:

```
/seo roi /blog/my-post "target keyword"
```

**Output:**
```
ROI PROJECTION: /blog/my-post

Current State:
  Position: 12 | Traffic: 45/mo | Value: $135/mo

If improved to Position 3:
  Projected Traffic: 890/mo (+1878%)
  Projected Value: $2,670/mo

Investment Required:
  Content updates, backlink outreach

Payback Period: 2-3 months
```

### Content Refresh

Find pages with declining rankings:

```
/seo refresh
```

**Output:**
```
REFRESH CANDIDATES (5 pages)

1. /blog/old-post (published 18 months ago)
   Position: 15 → 28 (dropped 13)
   Traffic: -65% last 90 days
   Priority: HIGH

   Suggested Updates:
   - Update statistics and examples
   - Add new section on [trending topic]
   - Refresh meta description
```

### Keyword Research

Research keywords for a topic:

```
/seo keywords "react hooks"
```

**Output:**
```
KEYWORD RESEARCH: "react hooks"

Primary Keywords:
  react hooks tutorial     12,000/mo  KD:42  Intent:informational
  usestate react           8,500/mo   KD:38  Intent:informational
  react custom hooks       4,200/mo   KD:35  Intent:informational

Related Keywords:
  useeffect examples       3,100/mo   KD:32
  react hooks cheat sheet  2,800/mo   KD:28

Questions (PAA):
  - What are React hooks?
  - How do you use useState?
  - What is useEffect for?
```

---

## Site Auditing

Site-wide audits analyze your entire website across 8 categories with 60+ checks based on the comprehensive Website Audit Checklist.

### Full Site Audit

Run a comprehensive audit covering all categories:

```
/audit site
```

**Quick mode output (default):**
```
SITE AUDIT: example.com
════════════════════════════════════════════════════════════════

OVERALL SCORE: 72/100 (Fair) ↑3 from last audit

Category Scores:
  Technical SEO      85/100  █████████░
  Schema Markup      45/100  █████░░░░░  ⚠ Issues
  E-E-A-T            68/100  ███████░░░
  On-Page SEO        78/100  ████████░░
  AI Optimization    52/100  █████░░░░░  ⚠ Issues
  Performance        91/100  █████████░  ✓ Excellent
  Accessibility      75/100  ████████░░
  Security           88/100  █████████░

CRITICAL ISSUES (2):
• Missing Organization schema (site-wide) [-15 pts]
• No author bios on blog posts (12 pages) [-12 pts]

HIGH ISSUES (3):
• LCP > 2.5s on homepage [-8 pts]
• Missing FAQ schema on /faq [-5 pts]
• 3 pages missing meta descriptions [-6 pts]

TASKS CREATED: 5

Run /audit site --full for detailed report
Run /task list to see all tasks
```

### Full Mode

Get detailed results for all 60+ checks:

```
/audit site --full
```

**Full mode output:**
```
SITE AUDIT: example.com (Full Report)
════════════════════════════════════════════════════════════════

OVERALL SCORE: 72/100 (Fair)

Compared to last audit (Jan 20, 2025):
  Score: 69 → 72 (+3 points)
  Fixed: 4 issues
  New: 2 issues

────────────────────────────────────────────────────────────────
TECHNICAL SEO (85/100)
────────────────────────────────────────────────────────────────

✓ TECH001 robots.txt exists [5/5]
✓ TECH002 robots.txt not blocking important pages [5/5]
✓ TECH003 XML sitemap exists [5/5]
✓ TECH004 Sitemap submitted to GSC [5/5]
✓ TECH005 Canonical tags present [5/5]
✓ TECH006 HTTPS enabled [10/10]
✓ TECH007 No mixed content [5/5]
⚠ TECH008 WWW redirect - minor inconsistency [2/3]
✓ TECH009 Trailing slash consistency [3/3]
✓ TECH010 No noindex on important pages [5/5]
✓ TECH011 No crawl errors [5/5]
✗ TECH012 Orphan pages found [0/3]
  Found: /old-landing, /test-page
  Fix: Add links to these pages or remove them

────────────────────────────────────────────────────────────────
SCHEMA MARKUP (45/100)
────────────────────────────────────────────────────────────────

✗ SCHEMA001 Organization schema [0/15] [CRITICAL]
  No Organization or Person schema found
  Fix: Add Organization JSON-LD to site layout
  Auto-fixable: Yes

[... continues for all categories ...]
```

### Category-Specific Audits

Audit a specific category only:

```
/audit site --category=performance
```

**Available categories:**

| Category | Checks |
|----------|--------|
| `technical` | robots.txt, sitemap, HTTPS, redirects, crawlability |
| `schema` | Organization, WebSite, Article, FAQ, validation |
| `eeat` | Author, About, Contact, Dates, Citations |
| `onpage` | Titles, Metas, Headings, Images, URLs, Links |
| `ai` | LLM optimization, quotable sections, FAQ format |
| `performance` | Core Web Vitals, load time, asset optimization |
| `accessibility` | WCAG 2.1 AA, keyboard, ARIA, contrast |
| `security` | Headers, SSL, legal compliance |
| `backlinks` | Profile analysis, toxic links, diversity |

### Auto-Fix Mode

Automatically fix supported issues:

```
/audit site --fix
```

**Auto-fixable issues include:**
- Add Organization schema to layout
- Add Article schema to blog posts
- Add FAQ schema to FAQ pages
- Add missing meta descriptions
- Enable lazy loading on images
- Add skip navigation link

**Output:**
```
AUTO-FIX MODE
════════════════════════════════════════════════════════════════

Analyzing auto-fixable issues...

Found 6 auto-fixable issues:

1. SCHEMA001: Add Organization schema
   Action: Create src/components/OrganizationSchema.astro
   Status: ✓ Created

2. SCHEMA004: Add Article schema to blog posts
   Action: Update src/layouts/BlogPost.astro
   Status: ✓ Updated

[...]

Fixed: 6 issues
Remaining: 11 issues (require manual fixes)

Re-run /audit site to verify fixes
```

### Scoring System

**Category Weights:**

| Category | Weight |
|----------|--------|
| Technical SEO | 15% |
| Schema Markup | 10% |
| E-E-A-T Signals | 15% |
| On-Page SEO | 15% |
| AI Optimization | 10% |
| Performance | 15% |
| Accessibility | 10% |
| Security | 10% |

**Score Interpretation:**

| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | Excellent | Minor optimizations only |
| 75-89 | Good | Some improvements needed |
| 60-74 | Fair | Moderate work required |
| 40-59 | Poor | Significant issues |
| 0-39 | Critical | Urgent attention needed |

### Auto-Created Tasks

Issues with severity `critical` or `high` automatically create tasks:

```json
{
  "id": "T001",
  "content": "Add Organization schema to site layout",
  "activeForm": "Adding Organization schema",
  "status": "pending",
  "priority": "critical",
  "labels": ["audit", "schema"],
  "source": "audit-site",
  "audit": {
    "checkCode": "SCHEMA001",
    "category": "schema",
    "impact": "+15 points"
  }
}
```

Tasks are not duplicated - if a task already exists for a check code, it won't be recreated.

### Integration with /start

Site audits run automatically at `/start` when:
- Last audit was more than 24 hours ago
- This is the first session

Quick mode runs (~30 seconds) covering critical checks only. The site health summary appears in the session output.

---

## Content Auditing

Audit commands analyze individual pages for SEO issues and provide actionable recommendations.

### Full Content Audit

Comprehensive 0-100 scoring across 6 categories:

```
/audit content /blog/my-post "target keyword"
```

**Output:**
```
SEO AUDIT: /blog/my-post
Target Keyword: "target keyword"
────────────────────────────────────────

OVERALL SCORE: 72/100 (Fair)

Category Breakdown:
  On-Page SEO    16/20  ████████░░
  E-E-A-T        18/25  ███████░░░
  Content        14/20  ███████░░░
  AI Overview    10/15  ██████░░░░
  Linking         8/10  ████████░░
  Multimedia      6/10  ██████░░░░

TOP ISSUES:

[HIGH] Meta description too short (45 chars)
  Current: "Learn about our product..."
  Recommendation: Expand to 150-160 chars with keyword
  Impact: +3 points

[HIGH] Missing author bio (E-E-A-T)
  No author information found
  Recommendation: Add author section with credentials
  Impact: +4 points

[MEDIUM] No internal links to pillar content
  Found 2 internal links, none to main topics
  Recommendation: Add 2-3 contextual internal links
  Impact: +2 points
```

### Quick Audit

10-point assessment for rapid checks:

```
/audit quick /blog/my-post
```

**Output:**
```
QUICK AUDIT: /blog/my-post
────────────────────────────────────────

✓ Title tag present (58 chars)
✓ Meta description present
✗ H1 missing
✓ Images have alt text
✗ No schema markup
✓ Mobile responsive
✓ HTTPS enabled
✗ Core Web Vitals: LCP > 2.5s
✓ Internal links present
✗ No external citations

Score: 6/10
Priority: Fix H1 and LCP issues
```

### E-E-A-T Audit

Deep dive into Experience, Expertise, Authoritativeness, Trustworthiness:

```
/audit eeat /blog/my-post
```

**Output:**
```
E-E-A-T AUDIT: /blog/my-post
────────────────────────────────────────

EXPERIENCE (6/6)
  ✓ First-person anecdotes present
  ✓ Screenshots/examples included
  ✓ Specific details and outcomes

EXPERTISE (5/7)
  ✓ Technical depth appropriate
  ✓ Industry terminology used
  ✗ No credentials mentioned
  ✗ Missing data/statistics

AUTHORITY (4/6)
  ✓ Internal links from authority pages
  ✗ No external citations
  ✗ Missing author bio

TRUST (4/6)
  ✓ HTTPS enabled
  ✓ Privacy policy linked
  ✗ No contact information
  ✗ Missing last updated date

TOTAL: 19/25

Recommendations:
1. Add author bio with credentials
2. Include data sources and citations
3. Add "last updated" date
```

### Batch Audit

Audit multiple pages at once:

```
/audit batch blog --limit 10
```

**Output:**
```
BATCH AUDIT: blog collection
────────────────────────────────────────

Audited: 10 pages

Score Distribution:
  90-100 Excellent: 1
  75-89  Good:      3
  60-74  Fair:      4
  40-59  Poor:      2
  0-39   Critical:  0

Lowest Scoring:
1. /blog/old-post (42) - Missing E-E-A-T signals
2. /blog/quick-tip (51) - Too short, no links

Common Issues:
- 7/10 missing author bios
- 5/10 have thin content (<500 words)
- 4/10 missing schema markup

Tasks Created: 6 (for issues marked HIGH priority)
```

### Scoring System

| Category | Points | Focus |
|----------|--------|-------|
| On-Page SEO | 20 | Title, meta, URL, headings |
| E-E-A-T | 25 | Experience, Expertise, Authority, Trust |
| Content | 20 | Length, readability, comprehensiveness |
| AI Overview | 15 | Structured answers, citation-worthy |
| Linking | 10 | Internal/external link strategy |
| Multimedia | 10 | Images, alt text, formatting |

### Score Interpretation

| Score | Rating | Action |
|-------|--------|--------|
| 90-100 | Excellent | Maintain |
| 75-89 | Good | Minor improvements |
| 60-74 | Fair | Moderate work needed |
| 40-59 | Poor | Significant issues |
| 0-39 | Critical | Urgent attention |

---

## Configuration

### Configuration File

Settings stored in `.cleo-web/config.json`:

```json
{
  "framework": "astro",
  "siteUrl": "https://example.com",
  "mcps": {
    "gsc": true,
    "dataforseo": true
  }
}
```

### Framework Detection

cleo-web automatically detects your framework:

| Files Detected | Framework |
|----------------|-----------|
| `astro.config.mjs`, `astro.config.js`, `astro.config.ts` | Astro |
| `next.config.js`, `next.config.mjs`, `next.config.ts` | Next.js |
| `nuxt.config.js`, `nuxt.config.ts` | Nuxt |

When a framework is detected, the corresponding adapter is loaded for framework-specific features.

---

## Multi-Agent Support

cleo-web supports multiple agents working simultaneously with file locking.

### How It Works

When writing to `todo.json`:
1. Acquire file lock (blocks other agents)
2. Read current state
3. Make changes
4. Write to temp file
5. Validate JSON
6. Create backup
7. Atomic rename
8. Release lock

### Lock Timeout

Locks timeout after 30 seconds to prevent deadlocks. If you see lock timeout errors:
- Check for stuck processes
- Verify no agents crashed mid-operation

### flock vs mkdir Fallback

- **flock** (preferred): Uses OS-level file locking, reliable and fast
- **mkdir** (fallback): Uses directory creation as mutex, works everywhere

Install flock on macOS:
```bash
brew install discoteq/discoteq/flock
```

---

## Data Storage

### JSON Files

```
.cleo-web/
├── todo.json      # Task state
├── config.json    # Configuration
└── backups/       # Automatic backups
```

**todo.json structure:**
```json
{
  "_meta": {
    "schemaVersion": "1.0.0",
    "generation": 42,
    "createdAt": "2025-01-24T10:00:00Z",
    "framework": "astro"
  },
  "tasks": [...]
}
```

The `generation` counter increments on every write for conflict detection.

### SQLite Database

Time-series metrics stored in `.cleo-web/metrics.db`:

| Table | Purpose |
|-------|---------|
| `site_audits` | Site-wide audit results and scores |
| `audit_checks` | Individual check results (60+ checks) |
| `check_definitions` | Check metadata and severity |
| `lighthouse_snapshots` | Core Web Vitals over time |
| `backlink_snapshots` | Backlink profile history |
| `schema_validations` | JSON-LD validation results |
| `security_headers` | Security header checks |
| `audits` | Page-level audit history |
| `audit_issues` | Individual page issues found |
| `keywords` | Keyword data cache (7-day TTL) |
| `gsc_snapshots` | GSC performance history |
| `links` | Internal link analysis |

**Useful views:**

| View | Purpose |
|------|---------|
| `latest_site_audit` | Most recent audit with all scores |
| `site_audit_trends` | Score changes over time |
| `failing_checks_summary` | All failing checks grouped by severity |
| `cwv_history` | Core Web Vitals trends |
| `category_scores` | Scores by category over time |

### Backups

Automatic backups created before every write:
- `.cleo-web/backups/todo.json.1` (most recent)
- `.cleo-web/backups/todo.json.2`
- Up to 10 backups retained

---

## Workflows

### Daily SEO Workflow

1. **Start session** (includes automatic site health check)
   ```
   /start
   ```

2. **Review site health** - Check for critical issues
   - Site health score shown in session summary
   - Critical/high issues auto-create tasks

3. **Address critical issues first**
   ```
   /task list --status pending
   ```

4. **Check quick wins from GSC data**
   ```
   /seo wins
   ```

5. **Work on highest-impact items**

6. **Track progress**
   ```
   /task complete T001
   ```

### Site Audit Workflow

1. **Run full site audit**
   ```
   /audit site --full
   ```

2. **Review category scores** - Identify weakest areas

3. **Deep dive on problem categories**
   ```
   /audit site --category=schema
   /audit site --category=performance
   ```

4. **Auto-fix where possible**
   ```
   /audit site --fix
   ```

5. **Create tasks for manual fixes**
   - Critical/high issues auto-create tasks
   - Review `/task list` for audit-generated tasks

6. **Re-audit to verify improvements**
   ```
   /audit site
   ```

### Content Audit Workflow

1. **Batch audit a collection**
   ```
   /audit batch blog --limit 20
   ```

2. **Review lowest-scoring pages**

3. **Deep dive on specific pages**
   ```
   /audit content /blog/problem-page "keyword"
   /audit eeat /blog/problem-page
   ```

4. **Create tasks for issues**
   (High-priority issues auto-create tasks)

5. **Track fixes**
   ```
   /task list --status pending
   ```

### New Content Workflow

1. **Research keywords**
   ```
   /seo keywords "topic"
   ```

2. **Check content gaps**
   ```
   /seo gaps
   ```

3. **Create content task**
   ```
   /task add "Write guide for 'topic keyword'"
   ```

4. **After publishing, audit**
   ```
   /audit content /new-page "target keyword"
   ```

---

## Troubleshooting

### MCP Not Available

```
ERROR: Required MCP server not available: gsc
```

**Solution:** See [MCP Setup Guide](mcp-setup.md)

### JSON Validation Errors

```
ERROR: Invalid JSON syntax in file: .cleo-web/todo.json
```

**Solution:**
1. Check backup files: `.cleo-web/backups/todo.json.1`
2. Restore: `cp .cleo-web/backups/todo.json.1 .cleo-web/todo.json`
3. Verify: `jq . .cleo-web/todo.json`

### Lock Timeout

```
ERROR: Could not acquire lock on .cleo-web/todo.json
```

**Solution:**
1. Check for running Claude Code instances
2. Remove stale lock: `rm .cleo-web/.locks/todo.json.lock`
3. Retry operation

### Database Not Found

```
ERROR: metrics.db not found
```

**Solution:**
```bash
sqlite3 .cleo-web/metrics.db < /path/to/cleo-web/scripts/init-db.sql
```

### flock Not Found

```
WARNING: flock not found (using mkdir fallback)
```

This is non-critical. For better multi-agent support, install flock:
```bash
# macOS
brew install discoteq/discoteq/flock

# Linux (usually pre-installed)
apt-get install util-linux
```

---

## Command Reference

### Session Commands
| Command | Description |
|---------|-------------|
| `/start` | Begin session with MCP verification |
| `/status` | Show current state |

### Task Commands
| Command | Description |
|---------|-------------|
| `/task add "title"` | Create a task |
| `/task list` | List all tasks |
| `/task list --status STATUS` | Filter by status |
| `/task complete ID` | Mark as completed |
| `/task update ID --field value` | Update task |
| `/task delete ID` | Delete task |

### SEO Commands
| Command | Description |
|---------|-------------|
| `/seo wins` | Quick win opportunities |
| `/seo gaps` | Content gap analysis |
| `/seo roi /path "keyword"` | ROI projection |
| `/seo refresh` | Declining pages |
| `/seo keywords "topic"` | Keyword research |

### Site Audit Commands
| Command | Description |
|---------|-------------|
| `/audit site` | Quick site audit (critical checks) |
| `/audit site --full` | Full site audit (60+ checks) |
| `/audit site --category=NAME` | Audit specific category |
| `/audit site --fix` | Auto-fix supported issues |

### Content Audit Commands
| Command | Description |
|---------|-------------|
| `/audit content /path "keyword"` | Full 0-100 page audit |
| `/audit quick /path` | 10-point page check |
| `/audit eeat /path` | E-E-A-T deep dive |
| `/audit batch collection --limit N` | Batch audit pages |
