---
name: seo
description: SEO analysis - quick wins, content gaps, ROI analysis, declining pages
disable-model-invocation: true
argument-hint: [wins|gaps|roi|refresh]
---

# SEO Analysis Command

Usage: `/seo <subcommand>`

## Subcommands

### `/seo wins` - Quick Win Opportunities
Find pages ranking position 4-15 that could reach page 1 with optimization:

1. Query GSC for pages with good impressions but position > 3
2. Sort by potential (impressions * (1/position))
3. Show top 10 opportunities with:
   - Current position and clicks
   - Target keyword
   - Recommended actions

### `/seo gaps` - Content Gap Analysis
Find keywords competitors rank for that you don't:

1. Get your top ranking keywords from GSC
2. Use DataForSEO to find competitor keywords
3. Identify gaps where competitor ranks but you don't
4. Prioritize by search volume and difficulty

### `/seo roi` - Performance ROI Analysis
Analyze which content produces best returns:

1. Query GSC for all pages with clicks
2. Calculate clicks/impressions (CTR)
3. Group by content type/category
4. Show ROI metrics:
   - Best performing pages
   - Worst performing (optimization candidates)
   - Content type performance comparison

### `/seo refresh` - Find Declining Pages
Identify content that needs updating:

1. Compare last 28 days vs previous 28 days
2. Find pages with declining:
   - Position (getting worse)
   - Clicks (losing traffic)
   - CTR (less engaging)
3. Prioritize by traffic impact
4. Suggest refresh strategies

## Required MCPs
- `gsc` - For search analytics data
- `dataforseo` - For competitor analysis, keyword data

## Output Format
```
📈 SEO Quick Wins

1. /blog/seo-guide
   Position: 8 → Target: 3
   Impressions: 2,400/mo | Clicks: 96
   Action: Add FAQ section, improve title

2. /services/consulting
   Position: 12 → Target: 5
   Impressions: 1,800/mo | Clicks: 45
   Action: Add testimonials, schema markup
```

## Arguments
$ARGUMENTS
