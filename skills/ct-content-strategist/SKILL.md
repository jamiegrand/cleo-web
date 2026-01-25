---
name: ct-content-strategist
version: 1.0.0
description: Keyword research and content strategy with topic clustering
tags: [seo, keywords, strategy]
status: active
requires_mcp: [dataforseo]
---

# Content Strategist

Keyword research and content strategy skill. Provides search volume data, keyword difficulty, topic clustering, and content recommendations.

## Capabilities

- **Keyword Research** (`keyword-research`): Get search volume, difficulty, and SERP data
- **Topic Clustering** (`topic-clustering`): Group related keywords into content themes
- **Content Gaps** (`content-gaps`): Find topics competitors cover that you don't
- **PAA Questions** (`paa-questions`): Extract People Also Ask for content ideas
- **SERP Analysis** (`serp-analysis`): Analyze search results for a keyword

## Required MCP

This skill requires the **DataForSEO MCP server** to be configured:

```json
{
  "dataforseo": {
    "command": "npx",
    "args": ["-y", "dataforseo-mcp-server"],
    "env": ["DATAFORSEO_USERNAME", "DATAFORSEO_PASSWORD"]
  }
}
```

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `SEED_KEYWORD` | Yes* | Starting keyword for research |
| `TOPIC` | Yes* | Topic for clustering |
| `COMPETITOR_URL` | No | Competitor site for gap analysis |
| `LOCATION` | No | Target location (default: US) |
| `LANGUAGE` | No | Target language (default: en) |

*One of SEED_KEYWORD or TOPIC required

## Outputs

### Keyword Report

```json
{
  "keyword": "astro framework",
  "search_volume": 12100,
  "difficulty": 45,
  "cpc": 2.50,
  "competition": "medium",
  "trend": "growing",
  "serp_features": ["featured_snippet", "paa", "video"],
  "related_keywords": [
    {
      "keyword": "astro js",
      "volume": 8100,
      "difficulty": 42
    }
  ],
  "paa_questions": [
    "What is Astro framework used for?",
    "Is Astro better than Next.js?"
  ]
}
```

### Topic Cluster

```json
{
  "pillar_topic": "Astro Framework",
  "pillar_keyword": "astro framework guide",
  "clusters": [
    {
      "cluster_name": "Getting Started",
      "keywords": [
        {"keyword": "astro tutorial", "volume": 2900},
        {"keyword": "astro getting started", "volume": 1600}
      ],
      "suggested_content": "Beginner's guide to Astro"
    },
    {
      "cluster_name": "Comparisons",
      "keywords": [
        {"keyword": "astro vs next", "volume": 1900},
        {"keyword": "astro vs gatsby", "volume": 880}
      ],
      "suggested_content": "Framework comparison article"
    }
  ]
}
```

### Content Gap Report

```json
{
  "competitor": "competitor.com",
  "gaps": [
    {
      "topic": "Astro Islands Architecture",
      "competitor_pages": 3,
      "your_pages": 0,
      "estimated_traffic": 2400,
      "keywords": ["astro islands", "partial hydration astro"]
    }
  ]
}
```

## Research Methods

### Keyword Expansion

Starting from a seed keyword:
1. Get search volume and difficulty
2. Find related keywords
3. Extract PAA questions
4. Identify SERP features
5. Analyze competitor coverage

### Topic Clustering

Groups keywords by:
- Semantic similarity
- Search intent alignment
- Content type match
- Difficulty level

### Gap Analysis

Compares your content vs competitors:
- Keyword overlap analysis
- Missing topic identification
- Traffic opportunity estimation

## Example Usage

### Research Keywords
```
/seo keywords "astro framework"
```

### Build Topic Cluster
```
/seo keywords cluster "web performance"
```

### Find Content Gaps
```
/seo keywords gaps --competitor example.com
```

### Get PAA Questions
```
/seo keywords paa "astro components"
```

## Caching Strategy

Keyword data is cached in `ct-metrics-store`:
- Search volume: 7 days
- SERP data: 24 hours
- PAA questions: 3 days
- Difficulty scores: 14 days

Use `/seo keywords refresh` to force update.

## Integration

### With ct-seo-auditor

Provides keyword data for audit scoring:
- Target keyword difficulty
- Search volume context
- SERP feature opportunities

### With ct-gsc-analyst

Combines GSC data with keyword research:
- Match ranking queries to search volume
- Calculate real vs potential traffic
- Prioritize by opportunity value

## Dependencies

- **ct-metrics-store**: For caching keyword data
- **DataForSEO MCP**: Required for keyword data
