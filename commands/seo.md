---
description: SEO analysis and optimization workflows
requires: [gsc, dataforseo]
---

# /seo

SEO analysis commands powered by GSC and DataForSEO MCPs.

## Prerequisites

These commands require MCP servers:
- **gsc** - Google Search Console data
- **dataforseo** - Keyword research and SERP data

Run `/start` to verify MCP availability.

## Subcommands

### /seo wins

Find quick-win optimization opportunities from GSC data.

**Criteria:**
- Pages at positions 4-15 with high impressions
- Low CTR compared to position average
- Keywords with high search volume, low difficulty

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

### /seo gaps

Identify content gaps and keyword opportunities.

**Analysis:**
- Compare your keywords vs competitors
- Find high-volume keywords you don't rank for
- Identify declining rankings

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

### /seo roi

Calculate ROI projections for SEO opportunities.

**Input:**
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

### /seo refresh

Find pages with declining rankings needing refresh.

**Criteria:**
- Position dropped 5+ in last 90 days
- Impressions declining month-over-month
- Content older than 12 months

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

### /seo keywords "topic"

Research keywords for a topic using DataForSEO.

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

## Data Caching

Keyword data is cached in `.cleo-web/metrics.db`:
- Search volume cached for 7 days
- SERP data cached for 24 hours
- GSC snapshots stored for trend analysis

## Error Handling

If MCPs are unavailable:
```
ERROR: GSC MCP required for /seo wins

Setup instructions:
1. Install: npm install -g gsc-mcp-server
2. Configure credentials
3. Restart Claude Code

Run: /start to verify setup
```
