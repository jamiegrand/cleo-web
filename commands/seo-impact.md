---
description: Measure before/after effect of SEO changes
parent: seo
type: implementation
requires: [gsc]
---

# /seo impact

Measure the before/after impact of SEO changes on specific pages.

## Usage

```
/seo impact /path
/seo impact /blog/updated-post --since 2026-01-01
/seo impact --task T015
/seo impact --days 30
```

## Arguments

| Argument | Description |
|----------|-------------|
| `/path` | Page path to analyze |
| `--since` | Start date for comparison (YYYY-MM-DD) |
| `--days` | Days since change (alternative to --since) |
| `--task` | Link to task ID for context |
| `--keyword` | Focus on specific keyword |

## Output

```
IMPACT ANALYSIS: /blog/updated-post
────────────────────────────────────────
Change Date: 2026-01-15 (10 days ago)
Linked Task: T015 "Optimize meta description and title"

BEFORE (14 days prior to change):
  Position: 12.4
  Impressions: 1,240
  Clicks: 28
  CTR: 2.3%

AFTER (10 days since change):
  Position: 8.1 (+4.3 improvement)
  Impressions: 1,580 (+27%)
  Clicks: 89 (+218%)
  CTR: 5.6% (+143%)

CHANGE BREAKDOWN:

Position Trend:
  Day 1-3:   12.4 → 11.2 (initial movement)
  Day 4-7:   11.2 → 9.5 (climbing)
  Day 8-10:  9.5 → 8.1 (stabilizing)

Keyword Performance:
  "primary keyword"    12 → 7  (+5 positions)
  "secondary keyword"  18 → 12 (+6 positions)
  "related term"       25 → 19 (+6 positions)

IMPACT SUMMARY:
  ✓ Position improved by 4.3 (35% improvement)
  ✓ Traffic increased by 218%
  ✓ CTR more than doubled

  Projected Monthly Impact: +180 clicks/mo
  Estimated Value: +$540/mo

STATUS: Successful optimization
```

## Comparison View

```
IMPACT COMPARISON: 3 recent optimizations
────────────────────────────────────────

Page                    | Before | After | Change | Status
------------------------|--------|-------|--------|--------
/blog/updated-post      | 12.4   | 8.1   | +4.3   | ✓ Success
/blog/refreshed-guide   | 18.2   | 14.5  | +3.7   | ✓ Success
/services/consulting    | 9.1    | 10.3  | -1.2   | ⚠ Monitor

Average improvement: +2.3 positions
Success rate: 67% (2/3)
```

## Tracking Changes

Impact is automatically tracked when:
1. Task completed with page reference
2. Audit score improves
3. Manual `/seo impact` measurement

## Required MCP

- **GSC**: Before/after ranking and traffic data

## Related Commands

- `/seo wins` - Find next opportunities
- `/seo refresh` - Find pages needing updates
- `/task complete` - Mark optimization tasks done
