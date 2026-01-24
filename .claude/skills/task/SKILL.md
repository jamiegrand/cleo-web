---
name: task
description: Task management - add, list, complete tasks
disable-model-invocation: true
argument-hint: [add|list|complete] [title|id]
---

# Task Management Command

Usage: `/task <subcommand> [args]`

## Subcommands

### `/task add "title"` - Create Task
Create a new task in `.cleo-web/todo.json`:

1. Generate unique task ID (format: T001, T002, etc.)
2. Add task with:
   - `id`: Generated ID
   - `title`: Provided title
   - `status`: "pending"
   - `createdAt`: Current timestamp
3. Save to todo.json (atomic write)
4. Confirm creation

### `/task list` - List Tasks
Display all tasks from `.cleo-web/todo.json`:

1. Read todo.json
2. Group by status (active, pending, done)
3. Show formatted list:
   ```
   📋 Tasks (3 active, 5 pending, 12 done)

   Active:
   - [T015] Optimize homepage meta tags
   - [T018] Add FAQ schema to blog posts

   Pending:
   - [T020] Write about page content
   - [T021] Fix mobile navigation
   ```

### `/task complete <id>` - Mark Complete
Complete a task by ID:

1. Find task by ID in todo.json
2. Update status to "done"
3. Add completedAt timestamp
4. Save to todo.json (atomic write)
5. Confirm completion

## Data Storage
Tasks stored in `.cleo-web/todo.json`:
```json
{
  "_meta": {
    "schemaVersion": "1.0.0",
    "framework": "astro"
  },
  "tasks": [
    {
      "id": "T001",
      "title": "Task title",
      "status": "pending",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

## Arguments
$ARGUMENTS
