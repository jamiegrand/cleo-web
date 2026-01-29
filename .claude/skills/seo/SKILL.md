---
name: seo
description: SEO analysis - quick wins, content gaps, ROI analysis, declining pages, engagement
disable-model-invocation: true
argument-hint: [wins|gaps|roi|refresh|engagement]
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
Analyze which content produces best returns using GSC + GA4:

1. Query GSC for all pages with clicks
2. Query GA4 via `mcp__analytics-mcp__run_report` for:
   - `engagementRate` - User engagement quality
   - `averageSessionDuration` - Time on site from page
   - `conversions` - Goal completions attributed to page
   - `bounceRate` - Single-page session rate
3. Calculate composite ROI score:
   - Traffic value = clicks × avg position value
   - Engagement value = sessions × engagement rate
   - Conversion value = conversions × goal value
4. Show ROI metrics:
   - Best performing pages (high traffic + high engagement)
   - Underperforming (high traffic, low engagement)
   - Hidden gems (low traffic, high conversion)
   - Content type performance comparison

### `/seo refresh` - Find Declining Pages
Identify content that needs updating using GSC + GA4 correlation:

1. Compare last 28 days vs previous 28 days in GSC
2. Compare same periods in GA4 for engagement trends
3. Find pages with declining:
   - Position (getting worse in GSC)
   - Clicks (losing traffic)
   - Engagement rate (GA4 - users engaging less)
   - Session duration (GA4 - users leaving faster)
4. Prioritize by combined traffic + engagement impact
5. Suggest refresh strategies based on decline type

### `/seo engagement` - Engagement Quality Analysis (NEW)
Analyze user engagement quality from organic traffic:

1. Query GA4 via `mcp__analytics-mcp__run_report` with:
   - Dimensions: `pagePath`, `sessionSource`
   - Metrics: `sessions`, `engagementRate`, `averageSessionDuration`, `bounceRate`, `conversions`
   - Filter: sessionSource contains "organic" or "google"
2. Identify engagement issues:
   - High bounce pages (>70% bounce from organic)
   - Low engagement pages (<40% engagement rate)
   - Short sessions (<30s average duration)
3. Cross-reference with GSC position data
4. Output:
   ```
   📊 Engagement Analysis (Organic Traffic)

   ⚠️ High Bounce from Search:
   /blog/seo-tips     Bounce: 78%  Position: 5
     → Content may not match search intent

   ⚠️ Low Engagement:
   /services          Engagement: 32%  Sessions: 450
     → Users not interacting, add CTAs

   ✓ Top Engaged Pages:
   /case-studies      Engagement: 89%  Conversions: 12
   ```

## Required MCPs
- `gsc` - For search analytics data (positions, clicks, impressions)
- `dataforseo` - For competitor analysis, keyword data
- `analytics-mcp` - For GA4 engagement, conversions, behavior data

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
