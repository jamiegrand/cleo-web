---
name: start
description: Begin cleo-web session with MCP verification and site health check
disable-model-invocation: true
---

# Start cleo-web Session

Execute these steps to start a cleo-web session:

## Step 1: Verify MCP Availability

Check that required MCP servers are responding:
- **gsc** (required) - Google Search Console data
- **dataforseo** (required) - Keyword research, Lighthouse, backlinks
- **scraperapi** (required) - HTML fetching, header analysis
- **analytics-mcp** (optional) - GA4 real-time and historical data

Use ToolSearch to verify each MCP is available before proceeding.

## Step 2: Check Configuration

Read `.cleo-web/config.json` for site settings:
- `siteUrl` - The site URL for GSC queries
- `framework` - Detected framework (astro, nextjs, nuxt, generic)
- `ga4PropertyId` - GA4 property ID for analytics (optional)

## Step 3: Load Tasks

Read `.cleo-web/todo.json` for current tasks.

## Step 4: Fetch Real-Time Analytics (if analytics-mcp available)

If analytics-mcp is connected and `ga4PropertyId` is configured:

1. Query `mcp__analytics-mcp__run_realtime_report` for:
   - Dimensions: `deviceCategory`
   - Metrics: `activeUsers`
   - Get current active users count

2. Query `mcp__analytics-mcp__run_report` for today's summary:
   - Date range: today
   - Metrics: `sessions`, `conversions`, `engagementRate`
   - Compare to 7-day average

## Step 5: Display Session Summary

Show a formatted summary:
- MCP status (connected/missing for each)
- Site URL from config
- Framework detected
- Active tasks count
- Site health score (if available from last audit in metrics.db)
- Real-time analytics (if available)

## Step 6: Offer Priorities

Suggest what to work on based on:
1. Critical site audit issues (query site_audits table)
2. Quick wins from GSC (pages in position 4-15)
3. Engagement issues from GA4 (pages with high bounce/low engagement)
4. Active tasks from todo.json

Format output like:
```
🚀 cleo-web Session Started

MCPs: ✓ gsc  ✓ dataforseo  ✓ scraperapi  ✓ analytics
Site: https://example.com (astro)
Tasks: 3 active

📊 Real-time: 8 active users
📈 Today: 156 sessions (+12% vs avg) | 4 conversions
💡 Engagement: 62% (target: 50%) ✓

Priorities:
1. Fix critical Schema issues (score: 45/100)
2. Quick win: "keyword" page 8 → could reach page 1
3. Low engagement: /services (38% engagement, high traffic)
4. Task: "Update meta descriptions"
```

If analytics-mcp is not available, show simplified output without real-time data:
```
🚀 cleo-web Session Started

MCPs: ✓ gsc  ✓ dataforseo  ✓ scraperapi  ○ analytics
Site: https://example.com (astro)
Tasks: 3 active

Priorities:
1. Fix critical Schema issues (score: 45/100)
2. Quick win: "keyword" page 8 → could reach page 1
3. Task: "Update meta descriptions"

💡 Tip: Connect analytics-mcp for real-time traffic insights
```
