---
name: ct-gsc-analyst
version: 1.0.0
description: Google Search Console analysis for SEO opportunities
tags: [seo, analytics, gsc]
status: active
requires_mcp: [gsc]
---

# GSC Analyst

Google Search Console analysis skill for identifying SEO opportunities. Analyzes ranking data, click-through rates, and impressions to find quick wins and content gaps.

## Capabilities

- **SEO Wins** (`seo-wins`): Find pages ranking 4-15 with optimization potential
- **Content Gaps** (`seo-gaps`): Identify queries without matching content
- **ROI Analysis** (`seo-roi`): Measure content performance and value
- **Refresh Finder** (`seo-refresh`): Detect declining pages needing updates
- **Impact Measurement** (`seo-impact`): Before/after analysis of SEO changes

## Required MCP

This skill requires the **GSC MCP server** to be configured:

```json
{
  "gsc": {
    "package": "gsc-mcp-server",
    "env": ["GOOGLE_APPLICATION_CREDENTIALS", "GSC_SITE_URL"]
  }
}
```

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `SITE_URL` | No | Override default site (from env) |
| `DATE_RANGE` | No | Analysis period (default: 28 days) |
| `PAGE_PATH` | No | Filter to specific page/section |
| `MIN_IMPRESSIONS` | No | Minimum impressions threshold |
| `MIN_CLICKS` | No | Minimum clicks threshold |

## Outputs

### Quick Wins Report

```json
{
  "analysis_type": "quick_wins",
  "date_range": "2025-12-28 to 2026-01-24",
  "opportunities": [
    {
      "query": "astro components",
      "page": "/blog/astro-guide",
      "position": 8.2,
      "impressions": 1250,
      "clicks": 45,
      "ctr": 3.6,
      "potential": "high",
      "recommendation": "Optimize title tag, position 8→3 potential"
    }
  ],
  "total_potential_clicks": 340
}
```

### Content Gaps Report

```json
{
  "analysis_type": "content_gaps",
  "gaps": [
    {
      "query": "astro vs next performance",
      "impressions": 890,
      "current_page": null,
      "recommendation": "Create comparison article",
      "estimated_traffic": 120
    }
  ]
}
```

### Declining Pages Report

```json
{
  "analysis_type": "declining",
  "period_comparison": "28d vs previous 28d",
  "declining_pages": [
    {
      "page": "/blog/old-post",
      "current_position": 12.5,
      "previous_position": 6.2,
      "position_change": -6.3,
      "click_change": -45,
      "recommendation": "Content refresh needed"
    }
  ]
}
```

## Analysis Methods

### Quick Wins Detection

Finds pages with high potential based on:
- Position 4-15 (close to page 1 or top 3)
- High impressions relative to clicks
- Low CTR vs position average
- Keyword difficulty feasibility

### Content Gap Analysis

Identifies opportunities by:
- Queries with impressions but no clicks
- High-impression queries without dedicated content
- Related queries not covered by existing pages

### Decline Detection

Monitors for:
- Position drops > 3 positions
- CTR drops > 20%
- Click volume decline > 30%
- Impression drops (may indicate SERP feature loss)

## Example Usage

### Find Quick Wins
```
/seo wins
```

### Analyze Content Gaps
```
/seo gaps
```

### Check ROI
```
/seo roi /blog/
```

### Find Declining Pages
```
/seo refresh --days 90
```

### Measure Impact
```
/seo impact /blog/updated-post --since 2026-01-01
```

## Integration

### With ct-metrics-store

GSC data is cached in SQLite for:
- Historical trend analysis
- Cross-period comparisons
- Faster repeated queries

### With ct-task-manager

Creates tasks for identified opportunities:
```
Quick win found: "astro guide" position 8
→ Creates: task "Optimize /blog/astro-guide for position improvement"
```

## Dependencies

- **ct-metrics-store**: For caching GSC data and trend analysis
- **GSC MCP**: Required for data access
