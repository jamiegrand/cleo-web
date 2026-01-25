---
description: Full SEO content audit with 0-100 scoring
parent: audit
type: implementation
---

# /audit content

Perform a full SEO audit of a page with 0-100 scoring across 6 categories.

## Usage

```
/audit content /path
/audit content /blog/my-post "target keyword"
/audit content https://example.com/page "keyword"
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `/path` or URL | Yes | Page to audit (file path or URL) |
| `"keyword"` | No | Target keyword for optimization scoring |

## Scoring Categories

| Category | Points | Focus |
|----------|--------|-------|
| On-Page SEO | 20 | Title, meta, URL, headings, keywords |
| E-E-A-T | 25 | Experience, Expertise, Authority, Trust |
| Content | 20 | Length, readability, comprehensiveness |
| AI Overview | 15 | Structured answers, citation-worthy |
| Linking | 10 | Internal/external link strategy |
| Multimedia | 10 | Images, alt text, formatting |

## Output

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

[CRITICAL] Missing H1 tag
  No H1 heading found on page
  Recommendation: Add single H1 with target keyword
  Impact: +4 points

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

[LOW] Images missing alt text (2 of 5)
  Recommendation: Add descriptive alt text
  Impact: +1 point

────────────────────────────────────────
TASKS CREATED: 5

  T020: [CRITICAL] Add H1 tag to /blog/my-post
  T021: [HIGH] Fix meta description on /blog/my-post
  T022: [HIGH] Add author bio to /blog/my-post
  T023: [MEDIUM] Add internal links to /blog/my-post
  T024: [LOW] Fix image alt text on /blog/my-post

Use /task list to see all tasks
```

## Score Interpretation

| Score | Rating | Action |
|-------|--------|--------|
| 90-100 | Excellent | Maintain |
| 75-89 | Good | Minor improvements |
| 60-74 | Fair | Moderate work needed |
| 40-59 | Poor | Significant issues |
| 0-39 | Critical | Urgent attention |

## Data Storage

Audit results stored in `.cleo-web/metrics.db` for:
- Score trend tracking
- Before/after comparison
- Portfolio analysis

## Related Commands

- `/audit quick` - Rapid 10-point check
- `/audit eeat` - Deep E-E-A-T analysis
- `/audit batch` - Audit multiple pages
