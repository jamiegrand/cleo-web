---
name: update
description: Update cleo-web skills and run database migrations
disable-model-invocation: true
---

# Update cleo-web

Updates the cleo-web plugin while preserving your project data.

## Usage

```
/update
```

## What Gets Updated

| Component | Action | Data Preserved |
|-----------|--------|----------------|
| Skills | Overwritten with latest | N/A |
| Database schema | Migrations applied | All existing data |
| todo.json | Untouched | Yes |
| config.json | Untouched | Yes |
| metrics.db | Schema updated | All audit history |

## Execution Steps

### Step 1: Locate cleo-web Plugin

Find the cleo-web plugin installation path. This is typically where you cloned the repository.

If the path is unknown, check:
1. `~/.claude/plugins/cleo-web/`
2. Custom path from initial installation

### Step 2: Run Update Script

Execute the update script from your project directory:

```bash
/path/to/cleo-web/update.sh
```

### Step 3: Verify Update

The script will:
1. Update all skills in `.claude/skills/`
2. Run any new database migrations
3. Preserve all user data
4. Show what was updated

### Step 4: Confirm Success

Output should show:
```
╔══════════════════════════════════════════════════════════════╗
║                    Update Complete!                          ║
╚══════════════════════════════════════════════════════════════╝

Your data has been preserved:
  - .cleo-web/todo.json (tasks)
  - .cleo-web/config.json (configuration)
  - .cleo-web/metrics.db (audit history)

Run /start to begin your session with the updated plugin.
```

## Manual Update (Alternative)

If you prefer to update manually:

### Update Skills Only

```bash
# From your project directory
cp -r /path/to/cleo-web/.claude/skills/* .claude/skills/
```

### Run Migrations Only

```bash
# Apply all pending migrations
for migration in /path/to/cleo-web/scripts/migrate-*.sql; do
    sqlite3 .cleo-web/metrics.db < "$migration" 2>/dev/null || true
done
```

## After Updating

1. Run `/start` to verify MCPs and see new features
2. Run `/init` if you need to update config from `.env`
3. Check the [changelog](https://github.com/jamiegrand/cleo-web/releases) for new features

## Troubleshooting

### Skills not updating

Make sure you're running update.sh from your project root (where `.cleo-web/` exists).

### Migration errors

Some migrations may show warnings for tables that already exist - this is normal. Your data is preserved.

### Missing features after update

Clear Claude Code's cache and restart, then run `/start`.
