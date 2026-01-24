---
name: ct-seo-auditor
version: 1.0.0
description: Content SEO auditing with 0-100 scoring across 6 categories
tags: [seo, auditing, content]
status: active
---

# SEO Content Auditor

Framework-agnostic content SEO auditing skill that scores pages on a 0-100 scale across 6 categories.

## Capabilities

- **Full Audit** (`audit-content`): Complete 6-category audit with detailed recommendations
- **Quick Check** (`audit-quick`): Rapid 10-point assessment
- **E-E-A-T Audit** (`audit-eeat`): Deep dive into Experience, Expertise, Authority, Trust
- **Batch Audit** (`audit-batch`): Audit multiple pages with ranking

## Scoring System

Total: **100 points**

| Category | Points | Weight | Focus |
|----------|--------|--------|-------|
| On-Page SEO | 20 | 20% | Title, meta, URL, headings, keywords |
| E-E-A-T Signals | 25 | 25% | Experience, Expertise, Authority, Trust |
| Content Quality | 20 | 20% | Readability, length, comprehensiveness |
| AI Overview | 15 | 15% | Citation-worthiness, extractable answers |
| Linking | 10 | 10% | Internal/external link strategy |
| Multimedia | 10 | 10% | Images, alt text, formatting |

### Score Interpretation

| Score | Rating | Action |
|-------|--------|--------|
| 90-100 | Excellent | Maintain |
| 75-89 | Good | Minor improvements |
| 60-74 | Fair | Moderate work needed |
| 40-59 | Poor | Significant issues |
| 0-39 | Critical | Urgent attention required |

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `PAGE_PATH` | Yes* | File path to content (e.g., `/src/pages/blog/post.md`) |
| `PAGE_URL` | Yes* | URL to audit (e.g., `https://example.com/blog/post`) |
| `TARGET_KEYWORD` | No | Primary keyword for optimization scoring |

*One of PAGE_PATH or PAGE_URL required

## Outputs

### Audit Report Structure

```json
{
  "page_path": "/blog/my-post",
  "url": "https://example.com/blog/my-post",
  "target_keyword": "web development",
  "audit_type": "full",
  "overall_score": 72,
  "scores": {
    "onpage": 16,
    "eeat": 18,
    "content": 14,
    "ai_overview": 10,
    "linking": 8,
    "multimedia": 6
  },
  "findings": {
    "onpage": [...],
    "eeat": [...],
    "content": [...],
    "ai_overview": [...],
    "linking": [...],
    "multimedia": [...]
  },
  "recommendations": [
    {
      "priority": "high",
      "category": "onpage",
      "issue": "Meta description too short (45 chars)",
      "recommendation": "Expand to 150-160 characters with target keyword",
      "impact": "+3 points"
    }
  ]
}
```

## Audit Criteria

### On-Page SEO (20 points)

| Criteria | Points | Check |
|----------|--------|-------|
| Title tag | 4 | Length 50-60 chars, keyword placement |
| Meta description | 4 | Length 150-160 chars, compelling CTA |
| URL structure | 3 | Clean, keyword-rich, no dates |
| H1 tag | 3 | Single H1, includes keyword |
| Heading hierarchy | 3 | Proper H2/H3 structure |
| Keyword usage | 3 | Natural density, LSI terms |

### E-E-A-T Signals (25 points)

| Criteria | Points | Check |
|----------|--------|-------|
| Experience | 6 | Personal anecdotes, first-hand knowledge |
| Expertise | 7 | Credentials, depth of coverage |
| Authority | 6 | Citations, external links, social proof |
| Trust | 6 | Author info, factual accuracy, transparency |

### Content Quality (20 points)

| Criteria | Points | Check |
|----------|--------|-------|
| Length | 5 | Appropriate for topic (vs. competitors) |
| Readability | 5 | Grade level, sentence variety |
| Comprehensiveness | 5 | Covers subtopics, answers questions |
| Freshness | 5 | Up-to-date info, recent references |

### AI Overview Optimization (15 points)

| Criteria | Points | Check |
|----------|--------|-------|
| Structured answers | 5 | Clear definitions, step lists |
| Citation-worthy | 5 | Factual, quotable statements |
| Question targeting | 5 | Addresses PAA questions |

### Linking (10 points)

| Criteria | Points | Check |
|----------|--------|-------|
| Internal links | 5 | Relevant, contextual links to own content |
| External links | 3 | Authoritative sources cited |
| Link text | 2 | Descriptive anchor text |

### Multimedia (10 points)

| Criteria | Points | Check |
|----------|--------|-------|
| Images | 4 | Relevant, high-quality images |
| Alt text | 3 | Descriptive, keyword-aware |
| Formatting | 3 | Lists, tables, callouts |

## Integration with cleo-web

### Auto-Create Tasks for Issues

When audit finds issues with severity `critical` or `high`, automatically create cleo-web tasks:

```bash
# Creates task linked to audit
/task add "Fix meta description on /blog/my-post" --epic SEO --labels "audit,onpage"
```

### Store Results in Metrics Database

All audits are stored in `.cleo-web/metrics.db` for:
- Score trend tracking
- Before/after comparison
- Portfolio-wide analysis

## Example Usage

### Full Audit
```
/audit content /blog/my-post "target keyword"
```

### Quick Check
```
/audit quick /blog/my-post
```

### E-E-A-T Deep Dive
```
/audit eeat /blog/my-post
```

### Batch Audit
```
/audit batch blog --limit 10
```

## Dependencies

- **ct-metrics-store**: For storing audit results and history
- **DataForSEO MCP** (optional): For keyword difficulty and SERP data
- **ScraperAPI MCP** (optional): For competitor analysis
