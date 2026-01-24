---
name: audit
description: Run SEO audits - site-wide or single page content audits
disable-model-invocation: true
argument-hint: [site|content|quick] [path]
---

# Audit Command

Usage: `/audit <type> [path] [options]`

## Audit Types

### `/audit site` - Full Site Audit
Run comprehensive site-wide audit with 60+ checks across 8 categories:
- Technical SEO (robots.txt, sitemap, canonical, HTTPS)
- Schema Markup (Organization, WebSite, Article, FAQ)
- E-E-A-T Signals (author, about page, dates, citations)
- On-Page SEO (titles, meta, headings, images, URLs)
- AI Optimization (quotable sections, FAQ format, definitions)
- Performance (Core Web Vitals via Lighthouse)
- Accessibility (contrast, keyboard, ARIA, landmarks)
- Security (headers, SSL, privacy policy)

Options:
- `--category=<name>` - Run only specific category

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
- `dataforseo` - For Lighthouse, keyword data
- `scraperapi` - For HTML parsing, headers

## Output
Results stored in `.cleo-web/metrics.db` (site_audits table).
Critical issues auto-create tasks in todo.json.

## Arguments
$ARGUMENTS
