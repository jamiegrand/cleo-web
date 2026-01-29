---
name: audit
description: Run SEO audits - site-wide or single page content audits
disable-model-invocation: true
argument-hint: [site|content|quick|mobile|international|social|competitors|behavior] [path]
---

# Audit Command

Usage: `/audit <type> [path] [options]`

## Audit Types

### `/audit site` - Full Site Audit
Run comprehensive site-wide audit with 105+ checks across 11 categories:

**Core Categories:**
- Technical SEO (robots.txt, sitemap, canonical, HTTPS)
- Schema Markup (Organization, WebSite, Article, FAQ)
- E-E-A-T Signals (author, about page, dates, citations)
- On-Page SEO (titles, meta, headings, images, URLs, social meta)
- AI Optimization (quotable sections, FAQ format, definitions)
- Performance (Core Web Vitals via Lighthouse, budget compliance)
- Accessibility (contrast, keyboard, ARIA, landmarks)
- Security (headers, SSL, privacy policy)

**Extended Categories (NEW):**
- Mobile (CWV mobile, viewport, tap targets, font size, content parity)
- International (hreflang, x-default, reciprocal links, lang attribute)
- Competitor (domain authority, keyword overlap, backlink comparison)

Options:
- `--category=<name>` - Run only specific category
- `--quick` - Critical checks only (faster)
- `--skip=mobile,competitor` - Skip specific categories

**Auto-Task Creation:** ALL issues (critical, high, medium, low) automatically create tasks.

### `/audit mobile [url]` - Mobile-Only Audit
Run mobile-specific checks:
- Mobile Core Web Vitals (LCP, INP, CLS)
- Viewport meta configuration
- Tap target sizing (48x48px minimum)
- Font size legibility (>=16px base)
- Content width fits viewport
- Mobile-first indexing readiness
- Content parity with desktop

Uses `mcp__dataforseo__on_page_lighthouse` with mobile emulation.

### `/audit international` - International SEO Audit
Check multi-language/region setup:
- hreflang tags present and valid
- x-default hreflang defined
- Reciprocal links validated
- HTML lang attribute set
- Content-Language header consistent
- Geo-targeting strategy (ccTLD, subdirectory, subdomain)

Uses `mcp__scraperapi__scrape` for HTML parsing.

### `/audit social [url]` - Social Meta Audit
Validate social sharing setup:
- Open Graph tags (og:title, og:description, og:image, og:url, og:type)
- Twitter Card tags (twitter:card, twitter:title, twitter:image)
- Image dimension validation (1200x630px for OG)
- Canonical URL consistency

Uses `mcp__scraperapi__scrape` for meta tag extraction.

### `/audit competitors` - Competitor Benchmarking
Compare against defined competitors:
- Domain authority comparison
- Keyword overlap/gaps
- Backlink profile comparison
- Performance comparison

Requires competitors to be configured via `/competitor add <domain>`.

Uses:
- `mcp__dataforseo__dataforseo_labs_google_domain_rank_overview`
- `mcp__dataforseo__dataforseo_labs_google_domain_intersection`
- `mcp__dataforseo__backlinks_competitors`

### `/audit behavior [url]` - User Behavior Audit (NEW)
Analyze user engagement patterns from GA4:

Uses `mcp__analytics-mcp__run_report` with engagement metrics.

**Checks:**
- BEHAV001: Homepage bounce rate < 50%
- BEHAV002: Site-wide engagement rate > 50%
- BEHAV003: Avg session duration > 60 seconds
- BEHAV004: Key landing pages have conversions
- BEHAV005: No high-exit pages without CTAs
- BEHAV006: Organic traffic engagement vs direct comparison
- BEHAV007: Mobile engagement parity with desktop
- BEHAV008: New vs returning user engagement balance

**Output:**
```
USER BEHAVIOR AUDIT
────────────────────────────────────────

✓ BEHAV001: Homepage bounce rate 42% (< 50%)
✗ BEHAV002: Engagement rate 38% (target: > 50%)
  → Add interactive elements, improve content quality
✓ BEHAV003: Avg session duration 1m 45s
✗ BEHAV004: /services has 0 conversions from 230 sessions
  → Add clear CTA, contact form, or demo booking
⚠ BEHAV007: Mobile engagement 15% lower than desktop
  → Review mobile UX, tap targets, load times

Score: 62/100
```

### `/audit content <path>` - Single Page Audit
Audit a specific page for content SEO:
- Read the file at the given path
- Analyze for target keyword optimization
- Check E-E-A-T signals
- Score 0-100 with recommendations

### `/audit quick <path>` - 10-Point Quick Check
Fast audit covering essentials:
1. Title tag present and optimized
2. Meta description present
3. Single H1 tag
4. Heading hierarchy
5. Images have alt text
6. Internal links present
7. Schema markup exists
8. Mobile-friendly
9. Page loads fast
10. No broken links

## Required MCPs
- `gsc` - For indexing status, crawl errors
- `dataforseo` - For Lighthouse, keyword data, competitor analysis
- `scraperapi` - For HTML parsing, headers
- `analytics-mcp` - For GA4 user behavior data (engagement, bounce rate, conversions)

## Output
Results stored in `.cleo-web/metrics.db`:
- `site_audits` - Overall scores by category
- `audit_checks` - Individual check results
- `mobile_audits` - Mobile-specific results
- `hreflang_analysis` - International SEO data
- `social_meta_analysis` - OG/Twitter tag data
- `competitor_snapshots` - Competitor comparison data
- `behavior_analysis` - GA4 engagement metrics (bounce rate, engagement rate, session duration)

**ALL issues** (critical, high, medium, low) automatically create tasks in todo.json.

## Category Weights (Overall Score)

```
Technical:      11%
Schema:          8%
E-E-A-T:        11%
On-Page:        11% (includes social)
AI:              7%
Performance:    11% (includes budgets)
Accessibility:   8%
Security:        7%
Mobile:          7%
International:   5%
Behavior:        9% (GA4 engagement data)
Competitor:      5% (optional)
```

## Arguments
$ARGUMENTS
