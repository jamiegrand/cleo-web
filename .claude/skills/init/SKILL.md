---
name: init
description: Initialize cleo-web configuration from .env file
disable-model-invocation: true
---

# Initialize cleo-web

Sets up `.cleo-web/config.json` by reading environment variables from the project's `.env` file.

## Usage

```
/init
```

## Execution Steps

### Step 1: Check for .env File

Look for `.env` file in project root. If not found, show instructions:

```
⚠️ No .env file found

Create a .env file with your configuration:

SITE_URL=https://your-site.com
GA_PROPERTY_ID=347541531
FRAMEWORK=astro
```

### Step 2: Read Environment Variables

Parse the `.env` file for these variables:

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `SITE_URL` | Yes | Site URL for GSC queries | `https://example.com` |
| `GA_PROPERTY_ID` | No | GA4 property ID (numeric) | `347541531` |
| `FRAMEWORK` | No | Framework type (auto-detected if not set) | `astro`, `nextjs`, `nuxt`, `generic` |

**Note:** The numeric `GA_PROPERTY_ID` is automatically formatted as `properties/XXX` when stored in config.

### Step 3: Auto-Detect Framework (if not specified)

If `FRAMEWORK` is not set in `.env`, detect from project files:

1. Check for `astro.config.*` → `astro`
2. Check for `next.config.*` → `nextjs`
3. Check for `nuxt.config.*` → `nuxt`
4. Default to `generic`

### Step 4: Create Data Directory

Ensure `.cleo-web/` directory exists with:
- `config.json` - Configuration
- `todo.json` - Task state (if not exists)
- `metrics.db` - SQLite database (if not exists)

### Step 5: Write Configuration

Write to `.cleo-web/config.json`:

```json
{
  "siteUrl": "https://example.com",
  "framework": "astro",
  "ga4PropertyId": "properties/123456789",
  "initializedAt": "2024-01-01T00:00:00Z"
}
```

### Step 6: Report Status

Show initialization summary with warnings for missing optional values:

```
✓ cleo-web Initialized

Configuration:
  Site URL:     https://example.com ✓
  Framework:    astro (auto-detected)
  GA4 Property: properties/123456789 ✓

Data Directory: .cleo-web/
  ✓ config.json created
  ✓ todo.json exists
  ✓ metrics.db exists

Run /start to begin your session
```

If `GA_PROPERTY_ID` is missing:

```
✓ cleo-web Initialized

Configuration:
  Site URL:     https://example.com ✓
  Framework:    astro (auto-detected)
  GA4 Property: Not configured ⚠️

⚠️ Missing optional configuration:
   GA_PROPERTY_ID - Add to .env for real-time analytics in /start

   To find your GA4 Property ID:
   1. Go to Google Analytics → Admin → Property Settings
   2. Copy the Property ID (numeric, e.g., 347541531)
   3. Add to .env: GA_PROPERTY_ID=347541531

Data Directory: .cleo-web/
  ✓ config.json created

Run /start to begin your session
```

If `SITE_URL` is missing (required):

```
✗ Initialization Failed

Missing required configuration in .env:
  SITE_URL - Your website URL for GSC queries

Add to your .env file:
  SITE_URL=https://your-site.com

Then run /init again.
```

## .env Template

Create this in your project root:

```env
# Required
SITE_URL=https://your-site.com

# ============================================
# Google Analytics (Optional)
# ============================================
# Property ID - for API access (Admin → Property Settings)
GA_PROPERTY_ID=347541531

# Measurement ID - for frontend tracking (not used by cleo-web)
PUBLIC_GA_ID=G-67BSYLS8DP

# Optional - auto-detected if not set
FRAMEWORK=astro
```

**Important:** cleo-web uses `GA_PROPERTY_ID` (the numeric Property ID) for API access via analytics-mcp. The `PUBLIC_GA_ID` (Measurement ID starting with `G-`) is for frontend gtag.js tracking and is not used by cleo-web.

## Google Analytics Authentication

If you see authentication errors when using analytics features, run:

```bash
gcloud auth application-default login --scopes="https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/cloud-platform"
```

This authenticates with the required scopes for GA4 Data API access.

## Re-initialization

Running `/init` again will:
1. Re-read `.env` for updated values
2. Update `config.json` with new values
3. Preserve existing `todo.json` and `metrics.db`
