---
description: 10-point rapid content check
parent: audit
type: implementation
---

# /audit quick

Perform a rapid 10-point SEO assessment without requiring a target keyword.

## Usage

```
/audit quick /path
/audit quick /blog/my-post
/audit quick https://example.com/page
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `/path` or URL | Yes | Page to audit |

## Quick Check Criteria

10 essential SEO checkpoints:

1. **Title tag** - Present and proper length (50-60 chars)
2. **Meta description** - Present and proper length (150-160 chars)
3. **H1 tag** - Single H1 present
4. **Image alt text** - All images have alt attributes
5. **Schema markup** - Structured data present
6. **Mobile responsive** - Viewport meta configured
7. **HTTPS** - Secure connection
8. **Core Web Vitals** - LCP, CLS within thresholds
9. **Internal links** - At least 2 internal links
10. **External citations** - At least 1 authoritative link

## Output

```
QUICK AUDIT: /blog/my-post
────────────────────────────────────────

✓ Title tag present (58 chars)
✓ Meta description present (142 chars)
✗ H1 missing
✓ Images have alt text (5/5)
✗ No schema markup
✓ Mobile responsive
✓ HTTPS enabled
✗ Core Web Vitals: LCP > 2.5s (3.2s)
✓ Internal links present (4 links)
✗ No external citations

────────────────────────────────────────
SCORE: 6/10

PRIORITY FIXES:
  1. Add H1 heading (critical for SEO)
  2. Fix LCP performance issue
  3. Add schema markup (Article or BlogPosting)
  4. Add external citations to authoritative sources

Tasks created: 2 (for critical issues)

For detailed analysis: /audit content /blog/my-post "keyword"
```

## When to Use

- **Quick check**: Before publishing new content
- **Spot check**: Reviewing random pages
- **Triage**: Identifying pages needing full audit

## Comparison: Quick vs Full Audit

| Aspect | Quick | Full |
|--------|-------|------|
| Time | ~10 seconds | ~60 seconds |
| Depth | Surface checks | Deep analysis |
| Keyword | Not required | Recommended |
| Score | 0-10 | 0-100 |
| Tasks | Critical only | All issues |

## Related Commands

- `/audit content` - Full detailed audit
- `/audit batch` - Quick audit multiple pages
- `/audit eeat` - E-E-A-T focused audit
