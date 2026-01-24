---
description: Begin session with MCP verification, site audit, and data-driven priorities
requires: [gsc, dataforseo, scraperapi]
---

# /start

Initialize a cleo-web session with full MCP verification, automatic site health check, and intelligent prioritization.

## Prerequisites

This command verifies required MCP servers are available:
- **GSC MCP** (required) - Google Search Console data, indexability, crawl errors
- **DataForSEO MCP** (required) - Keyword research, Lighthouse, backlinks, on-page analysis
- **ScraperAPI MCP** (required) - HTML fetching, header analysis, schema parsing

If MCPs are missing, you'll receive setup instructions.

## Execution Steps

### Step 1: Verify MCP Availability

Check that required MCP servers are responding:

```
Verifying MCP servers...
- [x] gsc: Connected (site: example.com)
- [x] dataforseo: Connected
- [x] scraperapi: Connected
- [ ] astro-mcp: Not configured (optional for Astro projects)
```

**If any required MCP is missing**: STOP and display setup instructions. Do not continue.

### Step 2: Detect Framework

Check for framework configuration files:
- `astro.config.mjs` → Astro adapter
- `next.config.js` → Next.js adapter
- `nuxt.config.js` → Nuxt adapter

If framework detected, load the corresponding adapter and verify framework-specific MCPs.

### Step 3: Initialize Data Directory

Ensure `.cleo-web/` directory exists with:
- `todo.json` - Task state
- `config.json` - Plugin configuration
- `metrics.db` - SQLite metrics database

### Step 4: Load Session Context

Check for existing session state:
- Active tasks from `todo.json`
- Recent audit scores from `metrics.db`
- GSC performance changes (if GSC MCP available)

### Step 5: Run Site Health Check

Run a quick site audit if:
- Last audit was more than 24 hours ago, OR
- This is the first session (no audit history)

```
Running site health check...
  Checking technical SEO... done
  Checking schema markup... done
  Checking performance (Lighthouse)... done
  Checking security headers... done
```

The quick audit runs critical checks only (~30 seconds) covering:
- Technical SEO fundamentals (robots.txt, sitemap, HTTPS)
- Schema markup presence (Organization, WebSite)
- Core Web Vitals (LCP, FID, CLS)
- Security headers (HSTS, CSP)

Results stored in `.cleo-web/metrics.db` in `site_audits` table.

### Step 6: Create Tasks for Issues

For any critical or high severity issues found:
1. Check if task already exists for this issue
2. If not, create new task with audit source
3. Set priority based on severity (critical → critical, high → high)

```
Auto-created tasks from audit:
  T001: Add Organization schema to site layout [critical]
  T002: Fix LCP > 2.5s on homepage [high]
```

### Step 7: Generate Priorities

Using available data, create prioritized work list:

**Priority 1: Site Health Critical Issues**
- Issues from site audit with severity `critical`
- Schema, security, or performance failures

**Priority 2: Content SEO Issues**
- Pages with audit score < 40
- Declining rankings (position dropped 5+)

**Priority 3: Quick Wins**
- Pages at positions 4-15 with high impressions
- Easy optimization opportunities

**Priority 4: Active Tasks**
- In-progress cleo-web tasks
- Blocked tasks that may be unblocked

### Step 8: Display Session Summary

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

## Error Handling

### Missing Required MCP

```
ERROR: Required MCP server not available: gsc

Google Search Console MCP is required for SEO features.

Setup instructions:
1. Install: npm install -g gsc-mcp-server
2. Configure credentials (see docs/mcp-setup.md#gsc)
3. Restart Claude Code

Run /start again after configuration.
```

```
ERROR: Required MCP server not available: scraperapi

ScraperAPI MCP is required for HTML fetching and header analysis.

Setup instructions:
1. Get API key from https://scraperapi.com
2. Set SCRAPERAPI_KEY environment variable
3. Configure MCP server (see docs/mcp-setup.md#scraperapi)
4. Restart Claude Code
```

### Database Not Initialized

If `metrics.db` doesn't exist, create it:
```bash
sqlite3 .cleo-web/metrics.db < scripts/init-db.sql
```

If you need the site audit tables:
```bash
sqlite3 .cleo-web/metrics.db < scripts/migrate-002-site-audit.sql
```

### Site Audit Skipped

If site audit is skipped, you'll see:
```
Site health check skipped: Last audit within 24 hours
Previous score: 72/100 (2 hours ago)
```

To force a new audit:
```
/audit site --full
```

## Notes

- Session state persists until explicitly ended
- MCP verification runs every session start (fail-fast)
- Site health check runs automatically if audit is stale (>24h)
- Priorities are recalculated each session based on latest data
- Critical issues from site audit auto-create tasks
- Use `/audit site --full` for comprehensive 60+ check audit

## Related Commands

- `/audit site` - Full site audit with all categories
- `/audit site --category=performance` - Performance-only audit
- `/audit content /path` - Single page content audit
- `/seo wins` - Quick win opportunities from GSC data
- `/task list` - View all tasks including audit-generated ones
