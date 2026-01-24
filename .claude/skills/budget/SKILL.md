---
name: budget
description: Performance budget management - set, list, clear thresholds
disable-model-invocation: true
argument-hint: [set|list|clear] [metric] [threshold]
---

# Budget Management Command

Usage: `/budget <subcommand> [args]`

## Subcommands

### `/budget set <metric> <threshold>` - Set Budget

Define a performance budget threshold:

```
/budget set lcp 2500        # LCP must be < 2500ms
/budget set fcp 1800        # FCP must be < 1800ms
/budget set ttfb 600        # TTFB must be < 600ms
/budget set page_size 500   # Total page size < 500KB
/budget set js_size 200     # JavaScript bundle < 200KB
/budget set css_size 50     # CSS < 50KB
/budget set image_size 300  # Images < 300KB per page
/budget set requests 50     # HTTP requests < 50
/budget set third_party 5   # Third-party scripts < 5
```

**Execution Steps:**
1. Validate metric name against allowed list
2. Parse threshold value
3. Insert/update in `performance_budgets` table
4. Confirm with current budget settings

**Available Metrics:**

| Metric | Type | Unit | Default Severity |
|--------|------|------|------------------|
| `lcp` | time | ms | critical |
| `fcp` | time | ms | high |
| `ttfb` | time | ms | high |
| `page_size` | resource | KB | medium |
| `js_size` | resource | KB | medium |
| `css_size` | resource | KB | low |
| `image_size` | resource | KB | medium |
| `requests` | quantity | count | medium |
| `third_party` | quantity | count | high |

### `/budget list` - List Budgets

Show all defined budgets with compliance status:

```
PERFORMANCE BUDGETS
────────────────────────────────────────

Active Budgets:
  lcp         < 2500ms   ✓ Compliant (2100ms)
  fcp         < 1800ms   ✓ Compliant (1200ms)
  ttfb        < 600ms    ✗ Exceeded (780ms, +30%)
  page_size   < 500KB    ✓ Compliant (420KB)
  requests    < 50       ⚠ Warning (48)

Last checked: 2 hours ago

Run /audit site --budgets to refresh
```

### `/budget clear <metric>` - Remove Budget

Remove a specific budget:

```
/budget clear ttfb
```

Removes the budget from `performance_budgets` table.

### `/budget clear all` - Remove All Budgets

Clear all performance budgets:

```
/budget clear all
```

## Data Storage

Budgets stored in `.cleo-web/metrics.db`:

```sql
-- performance_budgets table
site_url, metric, threshold_value, severity_if_exceeded

-- budget_compliance table (history)
budget_id, actual_value, is_compliant, variance_pct, created_at
```

## Integration with Audits

Performance budgets are checked during:
- `/audit site` - Full site audit includes budget checks (PERF009-PERF017)
- `/start` - Session start shows budget compliance summary

Budget violations create tasks with configured severity.

## Arguments
$ARGUMENTS
