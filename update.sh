#!/usr/bin/env bash
# update.sh - cleo-web updater
#
# Updates cleo-web plugin in the current project directory
# Preserves user data (todo.json, config.json, metrics.db)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory (cleo-web plugin root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    cleo-web updater                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================================
# CHECK INSTALLATION
# ============================================================================

DATA_DIR=".cleo-web"

if [[ ! -d "$DATA_DIR" ]]; then
    echo -e "${RED}ERROR: cleo-web not installed in this project${NC}"
    echo "  Run install.sh first: $SCRIPT_DIR/install.sh"
    exit 1
fi

echo -e "Found existing installation in ${GREEN}$DATA_DIR/${NC}"
echo ""

# ============================================================================
# UPDATE SKILLS
# ============================================================================

echo "Updating skills..."

# Create .claude/skills directory if missing
mkdir -p ".claude/skills"

# Copy skill definitions from cleo-web (overwrite existing)
if [[ -d "$SCRIPT_DIR/.claude/skills" ]]; then
    cp -r "$SCRIPT_DIR/.claude/skills/"* ".claude/skills/" 2>/dev/null || true

    # Count skills updated
    skill_count=$(find ".claude/skills" -name "SKILL.md" | wc -l | tr -d ' ')
    echo -e "  ${GREEN}✓${NC} Updated $skill_count skills"
else
    echo -e "  ${RED}✗${NC} Skills directory not found in cleo-web"
    exit 1
fi

# ============================================================================
# RUN DATABASE MIGRATIONS
# ============================================================================

if command -v sqlite3 &>/dev/null && [[ -f "$DATA_DIR/metrics.db" ]]; then
    echo ""
    echo "Running database migrations..."

    migrations_applied=0

    for migration in "$SCRIPT_DIR"/scripts/migrate-*.sql; do
        if [[ -f "$migration" ]]; then
            migration_name=$(basename "$migration")
            # Extract version number from filename
            version_num=$(echo "$migration_name" | grep -oE '[0-9]+' | head -1)
            if [[ -n "$version_num" ]]; then
                # Remove leading zeros
                version_num=$((10#$version_num))
                already_applied=$(sqlite3 "$DATA_DIR/metrics.db" "SELECT COUNT(*) FROM schema_version WHERE version = $version_num;" 2>/dev/null || echo "0")
                if [[ "$already_applied" == "0" ]]; then
                    if sqlite3 "$DATA_DIR/metrics.db" < "$migration" 2>/dev/null; then
                        echo -e "  ${GREEN}✓${NC} Applied: $migration_name"
                        ((migrations_applied++))
                    else
                        echo -e "  ${YELLOW}⚠${NC} Partial: $migration_name"
                    fi
                fi
            fi
        fi
    done

    if [[ $migrations_applied -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} Database up to date"
    fi
else
    echo ""
    echo -e "  ${YELLOW}⚠${NC} Skipping migrations (sqlite3 not found or no database)"
fi

# ============================================================================
# UPDATE CLAUDE.MD
# ============================================================================

echo ""
echo "Checking CLAUDE.md..."

CLAUDE_MD="CLAUDE.md"

if [[ -f "$CLAUDE_MD" ]]; then
    if grep -q "cleo-web" "$CLAUDE_MD" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} CLAUDE.md already configured"
    else
        echo -e "  ${YELLOW}⚠${NC} CLAUDE.md exists but missing cleo-web config"
        echo "    Re-run install.sh to add it, or manually add cleo-web reference"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} CLAUDE.md not found - run install.sh to create"
fi

# ============================================================================
# SHOW WHAT'S NEW
# ============================================================================

echo ""
echo -e "${BLUE}What's Updated:${NC}"
echo "────────────────────────────────────────"

# Read version from plugin.json
if [[ -f "$SCRIPT_DIR/plugin.json" ]] && command -v jq &>/dev/null; then
    version=$(jq -r '.version // "unknown"' "$SCRIPT_DIR/plugin.json")
    echo "  Version: $version"
fi

echo ""
echo "  Skills updated:"
for skill_dir in ".claude/skills/"*/; do
    if [[ -d "$skill_dir" ]]; then
        skill_name=$(basename "$skill_dir")
        echo "    - /$skill_name"
    fi
done

# ============================================================================
# COMPLETION
# ============================================================================

echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Update Complete!                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Your data has been preserved:"
echo "  - $DATA_DIR/todo.json (tasks)"
echo "  - $DATA_DIR/config.json (configuration)"
echo "  - $DATA_DIR/metrics.db (audit history)"
echo ""
echo "Run /start to begin your session with the updated plugin."
echo ""
