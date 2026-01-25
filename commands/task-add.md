---
description: Add a new task
parent: task
type: implementation
---

# /task add

Create a new task in the cleo-web task system.

## Usage

```
/task add "title"
/task add "title" --priority high
/task add "title" --epic SEO --labels "audit,content"
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `title` | Yes | Task title/description in quotes |
| `--priority` | No | Priority level: critical, high, medium, low |
| `--epic` | No | Parent epic for grouping (e.g., SEO, Content) |
| `--labels` | No | Comma-separated labels for categorization |

## Process

1. Generate unique task ID (T001, T002, etc.)
2. Create task object with:
   - `id`: Generated ID
   - `content`: The title provided
   - `activeForm`: Present participle form (auto-generated)
   - `status`: `pending`
   - `priority`: Provided or default `medium`
   - `labels`: Provided or empty array
   - `createdAt`: Current timestamp
3. Save to `.cleo-web/todo.json` using atomic write
4. Display confirmation with task ID

## Output

```
Created task T015: "Optimize meta descriptions for blog posts"
  Priority: high
  Labels: seo, content
  Epic: SEO

Use /task list to see all tasks
Use /task complete T015 when done
```

## Examples

```
/task add "Fix broken internal links on /services"
/task add "Add FAQ schema to product pages" --priority high
/task add "Research competitor keywords" --epic SEO --labels "research"
```

## Auto-Creation

Tasks are automatically created by:
- `/audit content` - For issues found during audit
- `/seo wins` - For quick win opportunities
- `/seo gaps` - For content gap recommendations

## Data Storage

Tasks stored in `.cleo-web/todo.json` with atomic write operations.
