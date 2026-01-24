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

Use ToolSearch to verify each MCP is available before proceeding.

## Step 2: Check Configuration

Read `.cleo-web/config.json` for site settings:
- `siteUrl` - The site URL for GSC queries
- `framework` - Detected framework (astro, nextjs, nuxt, generic)

## Step 3: Load Tasks

Read `.cleo-web/todo.json` for current tasks.

## Step 4: Display Session Summary

Show a formatted summary:
- MCP status (connected/missing for each)
- Site URL from config
- Framework detected
- Active tasks count
- Site health score (if available from last audit in metrics.db)

## Step 5: Offer Priorities

Suggest what to work on based on:
1. Critical site audit issues (query site_audits table)
2. Quick wins from GSC (pages in position 4-15)
3. Active tasks from todo.json

Format output like:
```
🚀 cleo-web Session Started

MCPs: ✓ gsc  ✓ dataforseo  ✓ scraperapi
Site: https://example.com (astro)
Tasks: 3 active

Priorities:
1. Fix critical Schema issues (score: 45/100)
2. Quick win: "keyword" page 8 → could reach page 1
3. Task: "Update meta descriptions"
```
