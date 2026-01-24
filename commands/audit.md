---
description: Content SEO auditing with scoring
requires: [dataforseo]
---

# /audit

Content auditing commands with 0-100 scoring across 6 categories.

## Subcommands

### /audit content /path "keyword"

Full SEO audit of a page with target keyword.

**Input:**
```
/audit content /blog/my-post "target keyword"
/audit content https://example.com/page "keyword"
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

### /audit quick /path

Rapid 10-point assessment without keyword.

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

### /audit eeat /path

Deep dive into E-E-A-T signals.

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

### /audit batch collection --limit N

Audit multiple pages from a content collection.

**Input:**
```
/audit batch blog --limit 10
/audit batch products --limit 5
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

## Scoring System

| Category | Points | Focus |
|----------|--------|-------|
| On-Page SEO | 20 | Title, meta, URL, headings |
| E-E-A-T | 25 | Experience, Expertise, Authority, Trust |
| Content | 20 | Length, readability, comprehensiveness |
| AI Overview | 15 | Structured answers, citation-worthy |
| Linking | 10 | Internal/external link strategy |
| Multimedia | 10 | Images, alt text, formatting |

## Score Interpretation

| Score | Rating | Action |
|-------|--------|--------|
| 90-100 | Excellent | Maintain |
| 75-89 | Good | Minor improvements |
| 60-74 | Fair | Moderate work needed |
| 40-59 | Poor | Significant issues |
| 0-39 | Critical | Urgent attention |

## Data Storage

Audit results stored in `.cleo-web/metrics.db`:
- Audit history for trend tracking
- Issue tracking with status
- Score comparisons over time

## Auto-Task Creation

**ALL issues** (critical, high, medium, low) automatically create tasks:
```
Created task T015: Fix meta description on /blog/my-post
  Priority: high
  Labels: audit, onpage
  Source: audit-content
```

Tasks are sorted by priority so critical items appear first.

---

## Extended Audit Commands (NEW)

### /audit mobile [url]

Mobile-specific audit checking:
- Mobile Core Web Vitals (LCP, INP, CLS)
- Viewport meta tag configuration
- Tap target sizing (48x48px minimum)
- Font size legibility (>=16px)
- Content width fits viewport
- Mobile-first indexing readiness
- Content parity with desktop

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
```

### /audit international

International SEO (hreflang) audit:
- hreflang tags present on pages
- x-default hreflang defined
- Reciprocal link validation
- HTML lang attribute
- Content-Language header
- Geo-targeting strategy consistency

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
```

### /audit social [url]

Social media meta tag audit:
- Open Graph tags (og:title, og:description, og:image, og:url, og:type)
- Twitter Card tags
- Image dimension validation
- Canonical consistency

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
• [HIGH] Missing og:image on 8 blog posts
• [MEDIUM] Missing twitter:title/description
```

### /audit competitors

Competitor benchmarking (requires `/competitor add` first):
- Domain authority comparison
- Keyword overlap analysis
- Keyword gap opportunities
- Backlink profile comparison
- Performance comparison

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

## Related Commands

- `/budget set <metric> <threshold>` - Set performance budgets
- `/budget list` - View current budgets
- `/competitor add <domain>` - Add competitor to track
- `/competitor list` - View tracked competitors
