---
description: Find declining pages needing content refresh
parent: seo
type: implementation
requires: [gsc]
---

# /seo refresh

Find pages with declining rankings that need content refresh.

## Usage

```
/seo refresh
/seo refresh --days 90
/seo refresh --threshold 5
/seo refresh --section /blog/
```

## Arguments

| Argument | Description |
|----------|-------------|
| `--days` | Comparison period in days (default: 90) |
| `--threshold` | Minimum position drop to flag (default: 3) |
| `--section` | Filter to specific URL section |
| `--limit` | Maximum results (default: 20) |

## Decline Criteria

Pages are flagged when:
- **Position drop**: Decreased 3+ positions in period
- **Traffic decline**: 20%+ drop in clicks
- **Impression drop**: May indicate SERP feature loss
- **Age**: Content older than 12 months

## Output

```
REFRESH CANDIDATES (7 pages found)
────────────────────────────────────────
Analysis Period: Last 90 days vs Previous 90 days

CRITICAL (position drop > 10):

1. /blog/react-2023-guide (published 18 months ago)
   Position: 8 → 21 (dropped 13)
   Traffic: 450 → 85/mo (-81%)
   Primary Keyword: "react tutorial"
   Priority: CRITICAL

   Suggested Updates:
   • Update to React 2025 patterns
   • Add new hooks examples
   • Refresh screenshots and code
   • Update statistics and benchmarks

2. /blog/css-grid-tutorial
   Position: 5 → 18 (dropped 13)
   Traffic: 890 → 120/mo (-87%)
   Primary Keyword: "css grid tutorial"
   Priority: CRITICAL

   Suggested Updates:
   • Add container queries section
   • Update browser support data
   • Add modern layout patterns

HIGH (position drop 5-10):

3. /services/web-development
   Position: 6 → 12 (dropped 6)
   Traffic: 320 → 180/mo (-44%)
   Priority: HIGH

   Suggested Updates:
   • Add 2025 tech stack info
   • Update case studies
   • Refresh testimonials

MODERATE (position drop 3-5):

4. /blog/typescript-basics
   Position: 9 → 13 (dropped 4)
   Traffic: 560 → 380/mo (-32%)
   Priority: MODERATE

────────────────────────────────────────
SUMMARY:
  Critical: 2 pages (need immediate attention)
  High: 2 pages
  Moderate: 3 pages

  Potential Traffic Recovery: +2,100 clicks/mo

Tasks created: 4 (for critical and high priority)
```

## Content Age Analysis

```
CONTENT AGE REPORT
────────────────────────────────────────

> 24 months: 5 pages (high refresh priority)
> 18 months: 8 pages
> 12 months: 12 pages
< 12 months: 25 pages (likely fresh)

Oldest content:
  /blog/old-post (published 2023-06-15)
  Last updated: Never
```

## Required MCP

- **GSC**: Historical ranking and traffic data

## Related Commands

- `/seo impact` - Measure effect after refresh
- `/audit content` - Detailed page audit
- `/task add` - Create refresh tasks
