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

Issues with severity `high` or `critical` automatically create tasks:
```
Created task T015: Fix meta description on /blog/my-post
  Epic: SEO
  Labels: audit, onpage
  Source: audit-content
```
