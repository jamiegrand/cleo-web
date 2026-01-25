---
description: Find SEO quick wins from Search Console (positions 4-15)
parent: seo
type: implementation
requires: [gsc]
---

# /seo wins

Find quick-win optimization opportunities from Google Search Console data.

## Usage

```
/seo wins
/seo wins --min-impressions 500
/seo wins --path /blog/
/seo wins --limit 10
```

## Arguments

| Argument | Description |
|----------|-------------|
| `--min-impressions` | Minimum impressions threshold (default: 100) |
| `--path` | Filter to specific URL path/section |
| `--limit` | Maximum opportunities to show (default: 20) |
| `--days` | Analysis period in days (default: 28) |

## Quick Win Criteria

Pages are scored as quick wins when:
- **Position 4-15**: Close to page 1 or top 3
- **High impressions**: Significant search visibility
- **Low CTR**: Below position average (opportunity to improve)
- **Actionable**: Clear optimization path available

## Output

```
QUICK WINS (12 opportunities found)
────────────────────────────────────────

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

3. /blog/nextjs-tutorial
   Keyword: "next.js getting started"
   Position: 6.1 | Impressions: 3,100/mo | CTR: 2.1%
   Opportunity: Top 3 position achievable
   Action: Update content, improve meta description

────────────────────────────────────────
Total Potential: +8,500 clicks/mo

Tasks created: 3 (for top opportunities)
```

## Required MCP

This command requires the **GSC MCP server**:
- Provides ranking data, impressions, clicks, CTR
- Must have `GSC_SITE_URL` and credentials configured

## Data Caching

Results are cached in `.cleo-web/metrics.db` for:
- Historical comparison
- Trend tracking
- Faster subsequent queries

## Related Commands

- `/seo gaps` - Find content opportunities
- `/seo roi` - Calculate ROI projections
- `/seo refresh` - Find declining pages
