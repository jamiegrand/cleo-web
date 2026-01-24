# ct-site-auditor

Comprehensive site-wide SEO, performance, and accessibility auditing skill based on the 25-section Website Audit Checklist.

## Overview

This skill performs full website audits across 11 categories with 105+ checks:

**Core Categories:**
1. Technical SEO (12 checks)
2. Schema Markup (7 checks)
3. E-E-A-T Signals (8 checks)
4. On-Page SEO (20 checks, includes social meta)
5. AI/LLM Optimization (5 checks)
6. Performance (17 checks, includes budgets)
7. Accessibility (8 checks)
8. Security (8 checks)

**Extended Categories:**
9. Mobile (10 checks)
10. International (8 checks)
11. Competitor (8 checks, optional)

## Capabilities

### Inputs
- `SITE_URL` - The website URL to audit
- `AUDIT_TYPE` - full, quick, or category-specific
- `CATEGORY_FILTER` - Optional category to focus on
- `AUTO_FIX` - Whether to apply automatic fixes

### Outputs
- `site_audit_report` - Comprehensive audit results
- `category_scores` - Individual category scores (0-100)
- `issues_list` - Prioritized list of issues
- `task_suggestions` - Auto-created task IDs

### Dependencies
- `ct-metrics-store` - For storing audit results
- `ct-task-manager` - For creating tasks from issues

### MCP Requirements
- `gsc` - Google Search Console data
- `dataforseo` - Lighthouse, on-page analysis, backlinks, competitor analysis, mobile CWV
- `scraperapi` - HTML fetching, header analysis, hreflang parsing, social meta parsing

## Audit Modules

### Module 1: Technical SEO
**Checks:** TECH001-TECH012

Uses:
- Local file reads for robots.txt, sitemap.xml
- `mcp__gsc__get_sitemaps` for sitemap status
- `mcp__gsc__check_indexing_issues` for crawl errors
- `mcp__scraperapi__scrape` for redirect and HTTPS checks

**Key Checks:**
- robots.txt properly configured
- XML sitemap exists and submitted
- Canonical tags present
- HTTPS with no mixed content
- No orphan pages

### Module 2: Schema Markup
**Checks:** SCHEMA001-SCHEMA007

Uses:
- `mcp__dataforseo__on_page_content_parsing` for schema extraction
- `mcp__scraperapi__scrape` for HTML parsing
- JSON-LD validation logic

**Key Checks:**
- Organization/Person schema present
- WebSite schema with SearchAction
- Article/BlogPosting on blog content
- BreadcrumbList for navigation
- FAQPage on FAQ pages
- Schema validation passes

### Module 3: E-E-A-T Signals
**Checks:** EEAT001-EEAT008

Uses:
- Local file scanning for page content
- HTML parsing for author elements
- `mcp__scraperapi__scrape` for live site checks

**Key Checks:**
- Author bylines with credentials
- About page comprehensive
- Contact information accessible
- Published/updated dates visible
- External citations to authoritative sources

### Module 4: On-Page SEO
**Checks:** ONPAGE001-ONPAGE010

Uses:
- `mcp__dataforseo__on_page_instant_pages` for meta analysis
- `mcp__dataforseo__on_page_content_parsing` for heading structure
- Local file scanning for URLs

**Key Checks:**
- Unique title tags (50-60 chars)
- Meta descriptions (150-160 chars)
- Single H1 per page
- Proper heading hierarchy
- Images have alt text
- Clean, keyword-rich URLs
- Strong internal linking

### Module 5: AI/LLM Optimization
**Checks:** AI001-AI005

Uses:
- Content structure analysis
- `mcp__dataforseo__ai_opt_llm_ment_search` for LLM mentions
- HTML parsing for FAQ elements

**Key Checks:**
- Clear, quotable sections
- Q&A format for common questions
- Key takeaways section
- Statistics with attribution
- Technical terms defined

### Module 6: Performance
**Checks:** PERF001-PERF008

Uses:
- `mcp__dataforseo__on_page_lighthouse` for Core Web Vitals
- Lighthouse performance audit

**Key Checks:**
- LCP < 2.5s
- FID/INP < 100ms
- CLS < 0.1
- Page load < 3s
- TTFB < 600ms
- Images optimized (WebP/AVIF)
- CSS/JS minified
- Lazy loading enabled

### Module 7: Accessibility
**Checks:** A11Y001-A11Y008

Uses:
- `mcp__dataforseo__on_page_lighthouse` accessibility audit
- HTML parsing for ARIA, landmarks

**Key Checks:**
- Color contrast meets WCAG AA
- Keyboard navigable
- Focus indicators visible
- ARIA labels present
- Landmark regions defined
- Form labels associated
- Skip link present
- Videos have captions

### Module 8: Security
**Checks:** SEC001-SEC008

Uses:
- `mcp__scraperapi__scrape` for header analysis
- SSL certificate checks

**Key Checks:**
- Content-Security-Policy configured
- X-Frame-Options set
- HSTS enabled
- X-Content-Type-Options set
- SSL valid and not expiring
- TLS 1.2 or higher
- Privacy policy exists
- Cookie consent implemented

### Module 9: Mobile
**Checks:** MOBILE001-MOBILE010

Uses:
- `mcp__dataforseo__on_page_lighthouse` with mobile emulation
- `mcp__scraperapi__scrape` for viewport meta parsing

**Key Checks:**
- Mobile LCP < 2.5s
- Mobile INP < 200ms
- Mobile CLS < 0.1
- Viewport meta configured
- Tap targets 48x48px+
- Font sizes >= 16px
- Content fits viewport
- Mobile-first indexing ready
- Mobile content parity
- Mobile resources optimized

### Module 10: International SEO
**Checks:** INTL001-INTL008

Uses:
- `mcp__scraperapi__scrape` for hreflang parsing
- Multi-URL validation for reciprocal links

**Key Checks:**
- hreflang tags present
- x-default hreflang exists
- hreflang reciprocal valid
- Language codes valid (ISO)
- HTML lang attribute set
- Content-Language header
- Geo-targeting consistent
- Regional content localized

### Module 11: Competitor Benchmarking
**Checks:** COMP001-COMP008

Uses:
- `mcp__dataforseo__dataforseo_labs_google_domain_rank_overview`
- `mcp__dataforseo__dataforseo_labs_google_domain_intersection`
- `mcp__dataforseo__backlinks_competitors`

**Key Checks:**
- Domain authority comparison
- Keyword overlap analysis
- Keyword gap opportunities
- Referring domains comparison
- Backlink quality comparison
- Link gap opportunities
- Performance vs competitors
- Content coverage analysis

Requires competitors to be configured via `/competitor add <domain>`.

## Scoring System

### Category Weights
```
Technical:      12%
Schema:          9%
E-E-A-T:        12%
On-Page:        12% (includes social meta)
AI:              8%
Performance:    12% (includes budgets)
Accessibility:   9%
Security:        8%
Mobile:          8%
International:   5%
Competitor:      5% (optional)
─────────────────
Total:         100%
```

### Score Calculation
```python
overall_score = (
    technical_score * 0.12 +
    schema_score * 0.09 +
    eeat_score * 0.12 +
    onpage_score * 0.12 +
    ai_score * 0.08 +
    performance_score * 0.12 +
    accessibility_score * 0.09 +
    security_score * 0.08 +
    mobile_score * 0.08 +
    international_score * 0.05 +
    competitor_score * 0.05  # optional, re-weighted if skipped
)
```

### Severity Classification
- **Critical**: Security issues, major indexability problems, severely broken UX
- **High**: Missing required elements, performance failures, accessibility violations
- **Medium**: Best practice violations, optimization opportunities
- **Low**: Nice-to-have improvements, polish items

## Auto-Fix Capabilities

The following checks support automatic fixes:

| Check Code | Fix Action |
|------------|------------|
| SCHEMA001 | Create OrganizationSchema component |
| SCHEMA002 | Create WebSiteSchema component |
| SCHEMA004 | Add Article schema to blog layout |
| SCHEMA005 | Add FAQPage schema to FAQ page |
| ONPAGE003 | Generate meta descriptions from content |
| PERF008 | Add loading="lazy" to images |
| A11Y007 | Add skip link to layout |

## Data Storage

### Tables Used
- `site_audits` - Overall audit results (11 category scores)
- `audit_checks` - Individual check results (105+ checks)
- `check_definitions` - Check metadata and severity
- `lighthouse_snapshots` - Performance history
- `backlink_snapshots` - Link profile history
- `schema_validations` - Schema validation results
- `security_headers` - Security header checks
- `mobile_audits` - Mobile-specific results
- `hreflang_analysis` - International SEO data
- `social_meta_analysis` - Open Graph/Twitter Card data
- `performance_budgets` - Budget thresholds
- `budget_compliance` - Budget compliance history
- `competitors` - Tracked competitors
- `competitor_snapshots` - Competitor comparison data

### Views Used
- `latest_site_audit` - Most recent audit with trend
- `site_audit_trends` - Historical score changes
- `failing_checks_summary` - Current failing checks
- `category_scores` - Latest category breakdown
- `budget_status` - Current budget compliance
- `competitor_summary` - Latest competitor metrics

## Task Integration

### Auto-Created Tasks

**ALL audit issues** automatically create tasks, regardless of severity:

| Audit Severity | Task Priority |
|----------------|---------------|
| Critical | critical |
| High | high |
| Medium | medium |
| Low | low |

```json
{
  "content": "Add Organization schema to site layout",
  "activeForm": "Adding Organization schema",
  "status": "pending",
  "priority": "critical",
  "labels": ["audit", "schema"],
  "source": "audit-site",
  "audit": {
    "checkCode": "SCHEMA001",
    "category": "schema",
    "severity": "critical",
    "impact": "+15 points",
    "fixSuggestion": "Add Organization JSON-LD to site layout"
  }
}
```

This ensures full visibility of all issues. Tasks can be filtered by priority when viewing.

### Task Linking
- `audit_checks.cleo_task_id` links check to task
- When task completed, check can be marked `fixed_at`
- Re-audit verifies the fix

## Usage Examples

### Full Site Audit
```
Input: /audit site --full
Process:
  1. Verify MCPs (gsc, dataforseo, scraperapi)
  2. Detect site URL from config
  3. Run all 8 audit modules
  4. Calculate scores
  5. Store results
  6. Create tasks for critical/high issues
  7. Display comprehensive report
```

### Category Audit
```
Input: /audit site --category=performance
Process:
  1. Verify dataforseo MCP
  2. Run only Module 6 (Performance)
  3. Run Lighthouse for all pages
  4. Store results
  5. Display focused report
```

### Quick Audit (at /start)
```
Input: (automatic at session start)
Process:
  1. Check last audit timestamp
  2. If stale (>24h), run critical checks only
  3. Store results
  4. Display summary in /start output
```

## Dispatch Triggers

This skill activates on:
- `/audit site` command
- `/start` (quick mode if stale)
- "run site audit"
- "check website health"
- "audit the whole site"
- "technical SEO audit"

## Error Handling

### MCP Unavailable
```
ERROR: Required MCP not available: dataforseo

The site audit requires the DataForSEO MCP for:
- Lighthouse performance testing
- On-page content analysis
- Backlink profile analysis

Setup instructions:
[... setup steps ...]
```

### Partial Failure
If one module fails, continue with others:
```
WARNING: Performance module failed (Lighthouse timeout)

Completed modules: 7/8
Skipped: Performance

Overall score calculated from available data.
Re-run /audit site --category=performance to retry.
```

### Rate Limiting
DataForSEO has rate limits. For large sites:
```
Site has 150 pages. Running batched audit...

Batch 1/3: Pages 1-50 ✓
Batch 2/3: Pages 51-100 ✓
Batch 3/3: Pages 101-150 ✓

Audit complete.
```
