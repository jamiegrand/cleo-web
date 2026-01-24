# MCP Setup Guide

cleo-web requires MCP (Model Context Protocol) servers for SEO functionality. This guide walks through setting up each required MCP.

## Overview

| MCP | Required | Purpose |
|-----|----------|---------|
| **gsc** | Yes | Google Search Console data (rankings, CTR, impressions) |
| **dataforseo** | Yes | Keyword research, Lighthouse, backlinks, on-page analysis |
| **scraperapi** | Yes | HTML fetching, header analysis, schema parsing |
| **playwright** | Optional | Visual testing, screenshots, mobile rendering |
| **astro-docs** | When using Astro | Astro documentation search |
| **astro-mcp** | When using Astro | Astro project integration |

## Core MCPs

### GSC (Google Search Console) {#gsc}

The GSC MCP provides access to your Google Search Console data for ranking analysis and quick wins detection.

#### Installation

```bash
npm install -g gsc-mcp-server
```

#### Configuration

1. **Create OAuth credentials** in Google Cloud Console:
   - Go to https://console.cloud.google.com/apis/credentials
   - Create OAuth 2.0 Client ID (Desktop application)
   - Download the credentials JSON

2. **Configure Claude Code** - Add to your MCP settings:

```json
{
  "mcpServers": {
    "gsc": {
      "command": "gsc-mcp-server",
      "args": ["--credentials", "/path/to/credentials.json"],
      "env": {
        "GSC_PROPERTY": "https://example.com/"
      }
    }
  }
}
```

3. **Verify connection**:
```bash
/start
```

Look for:
```
- [x] gsc: Connected (site: example.com)
```

#### Troubleshooting

**Error: "gsc MCP not available"**
- Ensure gsc-mcp-server is installed globally
- Check credentials path is correct
- Verify GSC_PROPERTY matches your Search Console property URL

**Error: "Authentication failed"**
- Re-download OAuth credentials from Google Cloud Console
- Ensure the OAuth consent screen is configured
- Check that Search Console API is enabled in your project

### DataForSEO {#dataforseo}

DataForSEO provides keyword research data including search volume, keyword difficulty, and SERP features.

#### Account Setup

1. Create an account at https://dataforseo.com/
2. Note your **username** (email) and **password** (API key)

#### Configuration

Set environment variables:

```bash
# Add to your shell profile (.bashrc, .zshrc)
export DATAFORSEO_USERNAME="your_username"
export DATAFORSEO_PASSWORD="your_api_key"
```

Or configure in Claude Code MCP settings:

```json
{
  "mcpServers": {
    "dataforseo": {
      "command": "dataforseo-mcp-server",
      "env": {
        "DATAFORSEO_USERNAME": "your_username",
        "DATAFORSEO_PASSWORD": "your_api_key"
      }
    }
  }
}
```

#### Verify Connection

```bash
/start
```

Look for:
```
- [x] dataforseo: Connected
```

#### Cost Considerations

DataForSEO charges per API call. cleo-web caches data to minimize costs:
- Keyword data cached for 7 days
- SERP data cached for 24 hours
- Batch operations to reduce call count

### ScraperAPI {#scraperapi}

ScraperAPI provides HTML fetching capabilities for parsing page content, security headers, and structured data.

#### Account Setup

1. Create an account at https://www.scraperapi.com/
2. Get your API key from the dashboard

#### Configuration

Set environment variable:

```bash
# Add to your shell profile (.bashrc, .zshrc)
export SCRAPERAPI_KEY="your_api_key"
```

Or configure in Claude Code MCP settings:

```json
{
  "mcpServers": {
    "scraperapi": {
      "command": "scraperapi-mcp-server",
      "env": {
        "SCRAPERAPI_KEY": "your_api_key"
      }
    }
  }
}
```

#### Verify Connection

```bash
/start
```

Look for:
```
- [x] scraperapi: Connected
```

#### Usage in Site Audits

ScraperAPI is used for:
- **Schema parsing**: Extract and validate JSON-LD structured data
- **Security headers**: Check CSP, HSTS, X-Frame-Options, etc.
- **HTML analysis**: Parse page content for E-E-A-T signals
- **Header inspection**: Analyze HTTP response headers

#### Cost Considerations

ScraperAPI charges per request. cleo-web minimizes costs by:
- Caching HTML responses for 1 hour
- Batching requests for multi-page audits
- Using lightweight requests (no JavaScript rendering) when possible

## Optional MCPs

### Playwright {#playwright}

Playwright MCP enables visual testing, screenshot capture, and mobile rendering verification. This is optional but recommended for comprehensive auditing.

#### Installation

```bash
npm install -g playwright-mcp-server
npx playwright install  # Install browser binaries
```

#### Configuration

```json
{
  "mcpServers": {
    "playwright": {
      "command": "playwright-mcp-server",
      "env": {
        "PLAYWRIGHT_BROWSERS": "chromium,firefox"
      }
    }
  }
}
```

#### Usage in Audits

When Playwright MCP is available, cleo-web can:

- **Screenshot comparisons**: Capture before/after screenshots when fixing issues
- **Mobile rendering**: Verify pages render correctly on mobile viewports
- **Visual regression**: Detect unexpected visual changes
- **Above-fold content**: Analyze LCP elements visually

#### Example Commands

```
/audit site --visual           # Include visual checks
/audit content /page --screenshot  # Capture page screenshot
```

#### Cost Considerations

Playwright runs locally - no API costs. However:
- Browser instances use memory
- Screenshots stored in `.cleo-web/screenshots/`
- Consider disk space for screenshot history

## Framework MCPs

### Astro {#astro}

When working with Astro projects, these MCPs enhance the experience.

#### astro-docs

Provides documentation search for Astro APIs and patterns.

```bash
npm install -g astro-docs-mcp
```

Configuration:
```json
{
  "mcpServers": {
    "astro-docs": {
      "command": "astro-docs-mcp"
    }
  }
}
```

#### astro-mcp

Provides Astro project integration.

```bash
npx astro add astro-mcp
```

Configuration:
```json
{
  "mcpServers": {
    "astro-mcp": {
      "command": "astro-mcp",
      "args": ["--project", "."]
    }
  }
}
```

## Verifying Setup

After configuring MCPs, verify everything is working:

```bash
# Start a cleo-web session
/start
```

Expected output:
```
Verifying MCP servers...
- [x] gsc: Connected (site: example.com)
- [x] dataforseo: Connected
- [x] scraperapi: Connected
- [x] astro-mcp: Connected (optional)

Session Started
...
```

If any required MCP is missing, cleo-web will display specific setup instructions and stop. This is intentional - we use fail-fast behavior to ensure you have full functionality before starting work.

## Common Issues

### MCP Not Found After Installation

Restart Claude Code after installing or configuring MCPs. The MCP connection is established at startup.

### Credentials Not Working

1. Check environment variables are exported in your shell
2. Verify paths to credential files are absolute
3. Test the MCP server directly: `gsc-mcp-server --help`

### Rate Limiting

DataForSEO has rate limits. If you hit them:
- Wait before retrying
- Use batch commands (`/audit batch`) to reduce API calls
- Check your DataForSEO dashboard for usage

## Next Steps

Once MCPs are configured:
1. Run `/start` to begin a session (includes automatic site health check)
2. Run `/audit site` for comprehensive site-wide audit
3. Try `/seo wins` to find quick optimization opportunities
4. Run `/audit content /path "keyword"` on a page
