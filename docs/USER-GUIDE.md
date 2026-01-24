# cleo-web User Guide

Complete guide to using cleo-web for task management and SEO workflows.

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Task Management](#task-management)
4. [SEO Commands](#seo-commands)
5. [Site Auditing](#site-auditing)
6. [Specialized Audits](#specialized-audits)
7. [Content Auditing](#content-auditing)
8. [Performance Budgets](#performance-budgets)
9. [Competitor Tracking](#competitor-tracking)
10. [Configuration](#configuration)
11. [Multi-Agent Support](#multi-agent-support)
12. [Data Storage](#data-storage)
13. [Workflows](#workflows)
14. [Troubleshooting](#troubleshooting)

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
4. Creates tasks for ALL audit issues (critical, high, medium, low)
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
  Mobile             62/100  ██████░░░░  ⚠ Issues
  International      90/100  █████████░

⚠ 2 Critical Issues:
  • Missing Organization schema (site-wide)
  • Mobile LCP > 2.5s on homepage

Run /audit site for full report
────────────────────────────────────────────────────────────────

TODAY'S PRIORITIES:

1. [Critical] T001: Add Organization schema to site layout
2. [Critical] T002: Add author bios to blog posts (12 pages)
3. [Quick Win] /blog/react-hooks at position 8 (+2.4k clicks potential)
4. [Task] T003: Optimize homepage LCP - hero image

Commands:
  /audit site       Full site audit (11 categories, 105+ checks)
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
| `/audit site` | Full site-wide audit (105+ checks) |
| `/audit content /path "keyword"` | Single page SEO audit |
| `/audit mobile [url]` | Mobile-specific audit |
| `/budget set <metric> <value>` | Set performance budget |
| `/competitor add <domain>` | Track competitor |
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

Site-wide audits analyze your entire website across 11 categories with 105+ checks based on the comprehensive Website Audit Checklist.

### Full Site Audit

Run a comprehensive audit covering all categories:

```
/audit site
```

**Quick mode output (default):**
```
SITE AUDIT: example.com
════════════════════════════════════════════════════════════════

OVERALL SCORE: 68/100 (Fair) ↑3 from last audit

Category Scores:
  Technical SEO      85/100  █████████░
  Schema Markup      45/100  █████░░░░░  ⚠ Issues
  E-E-A-T            68/100  ███████░░░
  On-Page SEO        72/100  ███████░░░  (includes social meta)
  AI Optimization    52/100  █████░░░░░  ⚠ Issues
  Performance        78/100  ████████░░  (includes budgets)
  Accessibility      75/100  ████████░░
  Security           88/100  █████████░
  Mobile             62/100  ██████░░░░  ⚠ Issues
  International      90/100  █████████░

CRITICAL ISSUES (4):
• [MOBILE001] Mobile LCP > 2.5s on homepage (3.2s) [-15 pts]
• [MOBILE004] Missing viewport meta on 3 pages [-10 pts]
• [INTL003] hreflang reciprocal links broken (5 pages) [-15 pts]
• Missing Organization schema (site-wide) [-15 pts]

HIGH ISSUES (6):
• [MOBILE005] Tap targets too small on /contact [-10 pts]
• [ONPAGE013] Missing og:image on blog posts (8 pages) [-8 pts]
• LCP budget exceeded (2800ms > 2500ms budget) [-10 pts]
...

TASKS CREATED: 10 (all severities)

Run /audit site --full for detailed report
Run /task list to see all tasks
```

### Full Mode

Get detailed results for all 105+ checks:

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

| Category | Weight | Checks |
|----------|--------|--------|
| `technical` | 12% | robots.txt, sitemap, HTTPS, redirects, crawlability |
| `schema` | 9% | Organization, WebSite, Article, FAQ, validation |
| `eeat` | 12% | Author, About, Contact, Dates, Citations |
| `onpage` | 12% | Titles, Metas, Headings, Images, URLs, Links, Social meta |
| `ai` | 8% | LLM optimization, quotable sections, FAQ format |
| `performance` | 12% | Core Web Vitals, load time, asset optimization, budgets |
| `accessibility` | 9% | WCAG 2.1 AA, keyboard, ARIA, contrast |
| `security` | 8% | Headers, SSL, legal compliance |
| `mobile` | 8% | Mobile CWV, viewport, tap targets, font size |
| `international` | 5% | hreflang, x-default, lang attribute, geo-targeting |
| `competitor` | 5% | Domain rank, keyword overlap, backlink comparison |

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

| Category | Weight | Checks |
|----------|--------|--------|
| Technical SEO | 12% | 12 |
| Schema Markup | 9% | 7 |
| E-E-A-T Signals | 12% | 8 |
| On-Page SEO | 12% | 20 (includes social meta) |
| AI Optimization | 8% | 5 |
| Performance | 12% | 17 (includes budgets) |
| Accessibility | 9% | 8 |
| Security | 8% | 8 |
| Mobile | 8% | 10 |
| International | 5% | 8 |
| Competitor | 5% | 8 (optional) |

**Score Interpretation:**

| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | Excellent | Minor optimizations only |
| 75-89 | Good | Some improvements needed |
| 60-74 | Fair | Moderate work required |
| 40-59 | Poor | Significant issues |
| 0-39 | Critical | Urgent attention needed |

### Auto-Created Tasks

**ALL audit issues** automatically create tasks, regardless of severity:

| Audit Severity | Task Priority |
|----------------|---------------|
| Critical | critical |
| High | high |
| Medium | medium |
| Low | low |

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
    "severity": "critical",
    "impact": "+15 points",
    "fixSuggestion": "Add Organization JSON-LD to site layout"
  }
}
```

Tasks are not duplicated - if a task already exists for a check code, it won't be recreated. Tasks can be filtered by priority when viewing with `/task list`.

### Skip Categories

Skip specific categories to speed up audits:

```
/audit site --skip=mobile,competitor
```

### Integration with /start

Site audits run automatically at `/start` when:
- Last audit was more than 24 hours ago
- This is the first session

Quick mode runs (~30 seconds) covering critical checks only. The site health summary appears in the session output.

---

## Specialized Audits

In addition to the full site audit, cleo-web provides focused audit commands for specific areas.

### Mobile Audit

Run mobile-specific checks:

```
/audit mobile [url]
```

**Output:**
```
MOBILE AUDIT: example.com
────────────────────────────────────────

Mobile Performance: 62/100

Core Web Vitals (Mobile):
  LCP: 3.2s  ✗ Poor (> 2.5s)
  INP: 180ms ✓ Good (< 200ms)
  CLS: 0.08  ✓ Good (< 0.1)

Mobile-Specific Checks:
  ✓ Viewport meta configured
  ✗ Tap targets too small (3 issues)
  ✓ Font sizes legible
  ✓ Content fits viewport
  ✗ Mobile-first not ready

Issues:
• [CRITICAL] LCP > 2.5s - optimize hero image
• [HIGH] Tap targets on /contact too small

Tasks Created: 2
```

**Checks include:**
- Mobile Core Web Vitals (LCP, INP, CLS)
- Viewport meta tag configuration
- Tap target sizing (48x48px minimum)
- Font size legibility (>=16px)
- Content width fits viewport
- Mobile-first indexing readiness
- Content parity with desktop

### International SEO Audit

Check multi-language/region setup:

```
/audit international
```

**Output:**
```
INTERNATIONAL SEO AUDIT: example.com
────────────────────────────────────────

International Score: 75/100

hreflang Analysis:
  Pages with hreflang: 45/50
  x-default defined: Yes
  Reciprocal valid: 40/45 (5 broken)

Language Setup:
  ✓ HTML lang attribute set
  ⚠ Content-Language header missing
  ✓ Geo-targeting: subdirectory (/en/, /de/, /fr/)

Issues:
• [CRITICAL] 5 pages have broken reciprocal hreflang
• [HIGH] Missing hreflang on 5 pages
• [MEDIUM] Content-Language header not set

Tasks Created: 3
```

**Checks include:**
- hreflang tags present and valid
- x-default hreflang defined
- Reciprocal links validated
- HTML lang attribute set
- Content-Language header consistent
- Geo-targeting strategy (ccTLD, subdirectory, subdomain)

### Social Meta Audit

Validate social sharing setup:

```
/audit social [url]
```

**Output:**
```
SOCIAL META AUDIT: /blog/my-post
────────────────────────────────────────

Open Graph Score: 80/100
Twitter Card Score: 70/100

Open Graph:
  ✓ og:title present
  ✓ og:description present
  ✓ og:image present (1200x630)
  ✓ og:url matches canonical
  ✗ og:type missing

Twitter Card:
  ✓ twitter:card (summary_large_image)
  ✗ twitter:title missing
  ✗ twitter:description missing
  ✓ twitter:image valid

Issues:
• [HIGH] Missing og:type tag
• [MEDIUM] Missing twitter:title/description

Tasks Created: 2
```

**Checks include:**
- Open Graph tags (og:title, og:description, og:image, og:url, og:type)
- Twitter Card tags (twitter:card, twitter:title, twitter:image)
- Image dimension validation (1200x630px for OG)
- Canonical URL consistency

### Competitor Audit

Compare against tracked competitors:

```
/audit competitors
```

**Output:**
```
COMPETITOR ANALYSIS: example.com
────────────────────────────────────────

Your Domain Rank: 45

Competitor Comparison:
  competitor-a.com  Rank: 52  Keywords: 1,234  Overlap: 45%
  competitor-b.com  Rank: 38  Keywords: 892   Overlap: 32%
  industry-leader.com  Rank: 78  Keywords: 5,678  Overlap: 28%

Keyword Gaps (they rank, you don't):
  • "keyword phrase 1" - competitor-a.com ranks #3
  • "keyword phrase 2" - competitor-b.com ranks #5
  • "keyword phrase 3" - industry-leader.com ranks #1

Backlink Opportunities:
  • 45 domains link to competitors but not you
  • Top opportunity: techblog.com (DA 65)

Performance:
  Your LCP: 2.1s  vs  Avg competitor: 2.4s ✓ Better
```

Requires competitors to be configured via `/competitor add <domain>`. See [Competitor Tracking](#competitor-tracking).

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

## Performance Budgets

Set and track performance budget thresholds to ensure your site meets targets.

### Set a Budget

```
/budget set <metric> <threshold>
```

**Examples:**
```
/budget set lcp 2500        # LCP must be < 2500ms
/budget set fcp 1800        # FCP must be < 1800ms
/budget set ttfb 600        # TTFB must be < 600ms
/budget set page_size 500   # Total page size < 500KB
/budget set js_size 200     # JavaScript bundle < 200KB
/budget set css_size 50     # CSS < 50KB
/budget set image_size 300  # Images < 300KB per page
/budget set requests 50     # HTTP requests < 50
/budget set third_party 5   # Third-party scripts < 5
```

### List Budgets

```
/budget list
```

**Output:**
```
PERFORMANCE BUDGETS
────────────────────────────────────────

Active Budgets:
  lcp         < 2500ms   ✓ Compliant (2100ms)
  fcp         < 1800ms   ✓ Compliant (1200ms)
  ttfb        < 600ms    ✗ Exceeded (780ms, +30%)
  page_size   < 500KB    ✓ Compliant (420KB)
  requests    < 50       ⚠ Warning (48)

Last checked: 2 hours ago

Run /audit site to refresh
```

### Clear a Budget

```
/budget clear ttfb           # Remove single budget
/budget clear all            # Remove all budgets
```

### Available Metrics

| Metric | Type | Unit | Default Severity |
|--------|------|------|------------------|
| `lcp` | time | ms | critical |
| `fcp` | time | ms | high |
| `ttfb` | time | ms | high |
| `page_size` | resource | KB | medium |
| `js_size` | resource | KB | medium |
| `css_size` | resource | KB | low |
| `image_size` | resource | KB | medium |
| `requests` | quantity | count | medium |
| `third_party` | quantity | count | high |

### Integration with Audits

Performance budgets are checked during:
- `/audit site` - Full site audit includes budget checks (PERF009-PERF017)
- `/start` - Session start shows budget compliance summary

Budget violations create tasks with configured severity.

---

## Competitor Tracking

Track and benchmark against competitors.

### Add a Competitor

```
/competitor add <domain> [--type=TYPE] [--name=NAME]
```

**Examples:**
```
/competitor add competitor.com
/competitor add competitor.com --type=direct
/competitor add industry-leader.com --type=aspirational --name="Industry Leader"
```

**Competitor types:**
- `direct` - Direct competitors in your market
- `indirect` - Indirect/adjacent competitors
- `aspirational` - Industry leaders to benchmark against

### List Competitors

```
/competitor list
```

**Output:**
```
TRACKED COMPETITORS
────────────────────────────────────────

Direct:
  competitor-a.com     Rank: 52   Last checked: 2h ago
  competitor-b.com     Rank: 38   Last checked: 2h ago

Aspirational:
  industry-leader.com  Rank: 78   Last checked: 2h ago

Your domain rank: 45

Run /audit competitors for full analysis
```

### Remove a Competitor

```
/competitor remove competitor.com
```

### Analyze Competitors

```
/competitor analyze [domain]
```

Deep dive into a specific competitor or all tracked competitors:

**Output:**
```
COMPETITOR DEEP DIVE: competitor-a.com
────────────────────────────────────────

Domain Metrics:
  Domain Rank: 52 (vs your 45)
  Organic Keywords: 1,234
  Estimated Traffic: 25,000/mo

Keyword Analysis:
  Overlap: 456 keywords (37%)
  They rank better: 234 keywords
  You rank better: 189 keywords

Top Keyword Gaps:
  "keyword phrase 1"     Vol: 5,400   They: #3   You: not ranking
  "keyword phrase 2"     Vol: 3,200   They: #5   You: #42
  "keyword phrase 3"     Vol: 2,800   They: #8   You: not ranking

Backlink Comparison:
  Their backlinks: 1,245
  Your backlinks: 890
  Link gap domains: 156

Top Link Opportunities:
  techblog.com (DA 65) - links to competitor
  devnews.io (DA 58) - links to competitor
```

### MCP Requirements

Competitor tracking uses:
- `mcp__dataforseo__dataforseo_labs_google_domain_rank_overview` - Domain metrics
- `mcp__dataforseo__dataforseo_labs_google_domain_intersection` - Keyword overlap
- `mcp__dataforseo__backlinks_competitors` - Backlink comparison

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
| `site_audits` | Site-wide audit results (11 category scores) |
| `audit_checks` | Individual check results (105+ checks) |
| `check_definitions` | Check metadata and severity |
| `lighthouse_snapshots` | Core Web Vitals over time |
| `backlink_snapshots` | Backlink profile history |
| `schema_validations` | JSON-LD validation results |
| `security_headers` | Security header checks |
| `mobile_audits` | Mobile-specific audit results |
| `hreflang_analysis` | International SEO data |
| `social_meta_analysis` | Open Graph/Twitter Card data |
| `performance_budgets` | Budget thresholds |
| `budget_compliance` | Budget compliance history |
| `competitors` | Tracked competitors |
| `competitor_snapshots` | Competitor comparison data |
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
| `budget_status` | Current budget compliance |
| `competitor_summary` | Latest competitor metrics |

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
   - All issues auto-create tasks (critical, high, medium, low)

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
   - All issues auto-create tasks (sorted by priority)
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
   (All issues auto-create tasks)

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
| `/audit site --full` | Full site audit (105+ checks) |
| `/audit site --category=NAME` | Audit specific category |
| `/audit site --skip=mobile,competitor` | Skip specific categories |
| `/audit site --fix` | Auto-fix supported issues |

### Specialized Audit Commands
| Command | Description |
|---------|-------------|
| `/audit mobile [url]` | Mobile-specific audit |
| `/audit international` | hreflang and geo-targeting audit |
| `/audit social [url]` | Open Graph and Twitter Card audit |
| `/audit competitors` | Competitor benchmarking |

### Content Audit Commands
| Command | Description |
|---------|-------------|
| `/audit content /path "keyword"` | Full 0-100 page audit |
| `/audit quick /path` | 10-point page check |
| `/audit eeat /path` | E-E-A-T deep dive |
| `/audit batch collection --limit N` | Batch audit pages |

### Budget Commands
| Command | Description |
|---------|-------------|
| `/budget set <metric> <value>` | Set performance budget |
| `/budget list` | Show all budgets with compliance |
| `/budget clear <metric>` | Remove a budget |
| `/budget clear all` | Remove all budgets |

### Competitor Commands
| Command | Description |
|---------|-------------|
| `/competitor add <domain>` | Add competitor to track |
| `/competitor list` | Show tracked competitors |
| `/competitor remove <domain>` | Stop tracking competitor |
| `/competitor analyze [domain]` | Deep competitive analysis |
