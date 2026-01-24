---
name: astro-adapter
version: 1.0.0
framework: astro
detects: [astro.config.mjs, astro.config.js, astro.config.ts]
requires: [astro-docs, astro-mcp]
status: active
---

# Astro Framework Adapter

Provides Astro-specific project understanding and best practices for cleo-web.

## Detection

This adapter activates when any of these files are found:
- `astro.config.mjs`
- `astro.config.js`
- `astro.config.ts`

## Capabilities

### Route Detection

Uses `astro-mcp` to enumerate all routes:
- Static pages (`/src/pages/*.astro`)
- Dynamic routes (`/src/pages/[slug].astro`)
- API endpoints (`/src/pages/api/*.ts`)
- Content collection pages

### Content Collection Enumeration

Lists all content collections from `/src/content/`:
- Blog posts
- Documentation
- Product data
- Custom collections

### Config Validation

Reads `astro.config.*` to understand:
- Output mode (static/server/hybrid)
- Integrations (Tailwind, MDX, etc.)
- Adapter configuration
- Build settings

### Best Practice Checks

Validates against Astro best practices:
- Proper use of `client:*` directives
- Image optimization with `@astrojs/image`
- Correct content collection schemas
- Performance patterns

## Required MCPs

| MCP | Purpose | Required |
|-----|---------|----------|
| `astro-docs` | Documentation search | Yes |
| `astro-mcp` | Project integration | Yes |

### astro-docs MCP

Provides access to official Astro documentation:
- API references
- Best practices
- Migration guides
- Integration docs

### astro-mcp MCP

Provides runtime project information:
- `get-astro-config`: Read configuration
- `list-astro-routes`: Enumerate all routes
- `get-integration-docs`: Integration-specific help

## Integration with cleo-web

### Page Path Resolution

Converts URLs to source file paths:
```
/blog/my-post → src/content/blog/my-post.md
/services → src/pages/services.astro
```

### Batch Audit Support

Enables batch auditing by collection:
```
/audit batch blog --limit 10
```

### Framework-Aware Scoring

Adjusts audit criteria for Astro:
- Checks for proper `<head>` management
- Validates SEO component usage
- Verifies sitemap generation

## Commands Enhanced

| Command | Enhancement |
|---------|-------------|
| `/start` | Shows Astro version, output mode |
| `/status` | Displays route count, collections |
| `/audit batch` | Can target content collections |
| `/seo links` | Uses route data for link analysis |

## Example Output

```
Framework: Astro 5.0.0
Output Mode: static
Site: https://example.com

Collections:
- blog (23 entries)
- docs (45 entries)
- products (12 entries)

Routes:
- Static: 84
- Dynamic: 3
- API: 2

Integrations:
- @astrojs/tailwind
- @astrojs/mdx
- @astrojs/sitemap
```

## Fallback Behavior

If `astro-mcp` is unavailable:
- Route detection uses file system scanning
- Collections enumerated from `/src/content/`
- Config read directly from file

If `astro-docs` is unavailable:
- Best practice checks disabled
- Documentation references link to web docs
