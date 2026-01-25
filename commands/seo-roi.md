---
description: Analyze content performance and ROI
parent: seo
type: implementation
requires: [gsc]
---

# /seo roi

Calculate ROI projections for SEO opportunities and measure content performance value.

## Usage

```
/seo roi /path
/seo roi /blog/my-post "target keyword"
/seo roi --top 10
/seo roi --section /blog/
```

## Arguments

| Argument | Description |
|----------|-------------|
| `/path` | Specific page to analyze |
| `"keyword"` | Target keyword for projections |
| `--top` | Analyze top N performing pages |
| `--section` | Analyze all pages in a section |
| `--cpc` | Custom CPC value (default: from DataForSEO) |

## ROI Calculation

Value is calculated as:
```
Monthly Value = Clicks × Average CPC × Conversion Factor
```

## Output - Single Page

```
ROI PROJECTION: /blog/my-post
────────────────────────────────────────

CURRENT STATE:
  Position: 12 | Traffic: 45/mo | CTR: 0.8%
  Keyword: "target keyword" (2,400 searches/mo)
  Current Value: $135/mo (CPC: $3.00)

PROJECTION IF POSITION 3:
  Expected CTR: 8.5%
  Projected Traffic: 204/mo (+354%)
  Projected Value: $612/mo

PROJECTION IF POSITION 1:
  Expected CTR: 27.6%
  Projected Traffic: 662/mo (+1371%)
  Projected Value: $1,986/mo

INVESTMENT ANALYSIS:
  Estimated Effort: Content update, on-page optimization
  Time to Rank: 2-4 months
  Payback Period: 1-2 months at position 3

RECOMMENDATION: High ROI opportunity
  Action: Update content, optimize for featured snippet
```

## Output - Section Analysis

```
ROI ANALYSIS: /blog/ (25 pages)
────────────────────────────────────────

CURRENT PERFORMANCE:
  Total Traffic: 2,340/mo
  Total Value: $7,020/mo
  Average Position: 14.2

TOP PERFORMERS:
  1. /blog/react-guide      890/mo  $2,670  Position: 4
  2. /blog/nextjs-tutorial  560/mo  $1,680  Position: 6
  3. /blog/vue-intro        320/mo  $960    Position: 8

HIGHEST ROI OPPORTUNITIES:
  1. /blog/astro-components
     Current: $45/mo → Potential: $890/mo
     ROI: 1,878% | Effort: Medium

  2. /blog/typescript-guide
     Current: $120/mo → Potential: $1,200/mo
     ROI: 900% | Effort: Low

PORTFOLIO SUMMARY:
  Current Value: $7,020/mo
  Potential Value: $18,500/mo
  Gap: $11,480/mo (163% growth possible)
```

## Required MCP

- **GSC**: Traffic and ranking data
- **DataForSEO** (optional): CPC and search volume data

## Related Commands

- `/seo wins` - Find quick win opportunities
- `/seo impact` - Measure changes after optimization
