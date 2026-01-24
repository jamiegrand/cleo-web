---
description: Comprehensive site-wide audit based on 25-section Website Audit Checklist
requires: [gsc, dataforseo, scraperapi]
---

# /audit site

Run a comprehensive site-wide audit covering Technical SEO, Schema, E-E-A-T, On-Page, AI Optimization, Performance, Accessibility, and Security.

## Prerequisites

This command requires all three core MCPs:
- **GSC MCP** - For indexability and crawl data
- **DataForSEO MCP** - For Lighthouse, on-page analysis, backlinks
- **ScraperAPI MCP** - For HTML fetching and header analysis

## Syntax

```
/audit site [--full] [--category=NAME] [--fix]
```

## Options

| Option | Description |
|--------|-------------|
| (none) | Run critical checks only (~30 seconds) |
| `--full` | Run all 25 sections (~2-3 minutes) |
| `--category=NAME` | Run specific category only |
| `--fix` | Attempt auto-fixes where possible |

### Categories

| Name | Sections Covered |
|------|------------------|
| `technical` | robots.txt, sitemap, HTTPS, redirects, crawlability |
| `schema` | Organization, WebSite, Article, FAQ, validation |
| `eeat` | Author, About, Contact, Dates, Citations |
| `onpage` | Titles, Metas, Headings, Images, URLs, Links |
| `ai` | LLM optimization, quotable sections, FAQ format |
| `performance` | Core Web Vitals, load time, asset optimization |
| `accessibility` | WCAG 2.1 AA, keyboard, ARIA, contrast |
| `security` | Headers, SSL, legal compliance |
| `backlinks` | Profile analysis, toxic links, diversity |

## Execution Flow

### Step 1: Verify MCPs
Check that all required MCPs are available. Fail-fast if any missing.

### Step 2: Detect Site URL
```
Detecting site configuration...
Site URL: https://example.com
Framework: Astro 5.0
Pages discovered: 47
```

### Step 3: Run Audit Modules

For each category:
1. Fetch required data (GSC, Lighthouse, HTML)
2. Run checks against checklist criteria
3. Calculate scores (0-100 per category)
4. Identify issues and fixes

### Step 4: Store Results

Save to `.cleo-web/metrics.db`:
- `site_audits` table with scores
- `audit_checks` table with individual results
- `lighthouse_snapshots` for performance data
- `backlink_snapshots` for link profile

### Step 5: Create Tasks

For issues with severity `critical` or `high`:
```
Created task T001: Add Organization schema to site layout [critical]
  Source: audit-site
  Category: schema
  Impact: +15 points
```

### Step 6: Display Results

## Output Format

### Quick Mode (Default)

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

### Full Mode (--full)

```
SITE AUDIT: example.com (Full Report)
════════════════════════════════════════════════════════════════

OVERALL SCORE: 72/100 (Fair)

Compared to last audit (Jan 20, 2026):
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

✗ SCHEMA002 WebSite schema [0/10]
  No WebSite schema with SearchAction
  Fix: Add WebSite schema with site search

✓ SCHEMA003 BreadcrumbList schema [10/10]
✗ SCHEMA004 Article/BlogPosting schema [5/15]
  Found on 3/12 blog posts
  Missing: /blog/post-4, /blog/post-5, ...
  Auto-fixable: Yes

✗ SCHEMA005 FAQ schema [0/10]
  /faq page has no FAQPage schema
  Auto-fixable: Yes

✓ SCHEMA006 Schema validates [10/10]
⚠ SCHEMA007 Rich results eligible [10/10]
  Eligible: BreadcrumbList
  Not eligible: FAQ, Article (missing schema)

[... continues for all categories ...]

────────────────────────────────────────────────────────────────
ISSUE SUMMARY
────────────────────────────────────────────────────────────────

By Severity:
  Critical: 2
  High: 3
  Medium: 8
  Low: 4

By Category:
  Schema: 4 issues
  E-E-A-T: 3 issues
  On-Page: 5 issues
  Performance: 2 issues
  Accessibility: 3 issues

Auto-Fixable: 6 issues
  Run: /audit site --fix to apply automatic fixes

────────────────────────────────────────────────────────────────
TASKS CREATED
────────────────────────────────────────────────────────────────

T001: Add Organization schema to site layout [critical]
T002: Add author bios to blog posts (12 pages) [critical]
T003: Optimize homepage LCP - hero image [high]
T004: Add FAQ schema to /faq page [high]
T005: Add meta descriptions to 3 pages [high]

Run /task list to see all tasks
```

### Category Mode (--category=NAME)

```
/audit site --category=performance

PERFORMANCE AUDIT: example.com
════════════════════════════════════════════════════════════════

PERFORMANCE SCORE: 91/100 (Excellent)

Core Web Vitals (Mobile):
  LCP: 2.1s ✓ Good
  INP: 45ms ✓ Good
  CLS: 0.05 ✓ Good

Core Web Vitals (Desktop):
  LCP: 1.2s ✓ Good
  INP: 32ms ✓ Good
  CLS: 0.02 ✓ Good

Page-by-Page Results:
  /               Desktop: 94  Mobile: 87
  /about          Desktop: 96  Mobile: 91
  /blog           Desktop: 92  Mobile: 88
  /blog/post-1    Desktop: 89  Mobile: 82  ⚠ LCP issue
  /contact        Desktop: 98  Mobile: 95

ISSUES (2):

[HIGH] PERF001 LCP > 2.5s on /blog/post-1 mobile [0/20]
  Current: 2.8s
  Target: < 2.5s
  Cause: Large hero image (1.2MB)
  Fix: Compress image, add preload, use responsive sizes

[MEDIUM] PERF006 Images not optimized [5/10]
  3 images still using JPEG instead of WebP
  Files: /images/hero.jpg, /images/team.jpg, /images/office.jpg
```

## Auto-Fix Mode (--fix)

```
/audit site --fix

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

3. SCHEMA005: Add FAQ schema to /faq
   Action: Update src/pages/faq.astro
   Status: ✓ Updated

4. ONPAGE003: Add meta descriptions
   Action: Update 3 page frontmatter files
   Status: ✓ Updated (3 files)

5. PERF008: Enable lazy loading
   Action: Add loading="lazy" to below-fold images
   Status: ✓ Updated (8 images)

6. A11Y007: Add skip link
   Action: Add skip link to src/layouts/Base.astro
   Status: ✓ Created

────────────────────────────────────────────────────────────────

Fixed: 6 issues
Remaining: 11 issues (require manual fixes)

Re-run /audit site to verify fixes
```

## Scoring System

### Category Weights

| Category | Max Points | Weight |
|----------|-----------|--------|
| Technical SEO | 100 | 15% |
| Schema Markup | 100 | 10% |
| E-E-A-T Signals | 100 | 15% |
| On-Page SEO | 100 | 15% |
| AI Optimization | 100 | 10% |
| Performance | 100 | 15% |
| Accessibility | 100 | 10% |
| Security | 100 | 10% |

### Score Interpretation

| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | Excellent | Minor optimizations only |
| 75-89 | Good | Some improvements needed |
| 60-74 | Fair | Moderate work required |
| 40-59 | Poor | Significant issues |
| 0-39 | Critical | Urgent attention needed |

## Data Storage

Results stored in `.cleo-web/metrics.db`:

| Table | Purpose |
|-------|---------|
| `site_audits` | Overall audit results and scores |
| `audit_checks` | Individual check results |
| `lighthouse_snapshots` | Core Web Vitals over time |
| `backlink_snapshots` | Backlink profile history |
| `schema_validations` | Schema markup validation |
| `security_headers` | Security header checks |

## Integration with /start

When running `/start`, a quick site audit runs automatically if:
- Last audit was more than 24 hours ago
- This is the first session

The summary appears in the session start output:

```
SITE HEALTH: 72/100 (Fair) ↑3 from last audit

⚠ 2 Critical Issues:
  • Missing Organization schema
  • No author bios on blog posts

Run /audit site for full report
```

## Task Auto-Creation

Issues create tasks automatically based on severity:

| Severity | Auto-Create Task |
|----------|------------------|
| Critical | Yes, priority: critical |
| High | Yes, priority: high |
| Medium | No (can be added manually) |
| Low | No |

Task format:
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
    "check_code": "SCHEMA001",
    "category": "schema",
    "impact": "+15 points"
  }
}
```

## Comparison with Page Audits

| Feature | /audit site | /audit content |
|---------|-------------|----------------|
| Scope | Entire site | Single page |
| Categories | 8 modules | 6 categories |
| Checks | 60+ checks | 30+ checks |
| MCP Required | gsc, dataforseo, scraperapi | dataforseo |
| Auto-fix | Yes | No |
| Run at /start | Yes (quick mode) | No |

## Related Commands

- `/audit content /path` - Audit single page with keyword
- `/audit quick /path` - Quick 10-point page check
- `/audit eeat /path` - Deep E-E-A-T analysis
- `/audit batch collection` - Batch audit content collection
- `/seo wins` - Find quick optimization opportunities
