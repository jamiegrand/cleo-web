#!/usr/bin/env bash
# mcp-check.sh - MCP requirement verification for cleo-web
#
# PROVIDES: check_required_mcps, check_mcp_available, get_mcp_setup_instructions
#
# Design: Fail-fast MCP verification - commands fail early with clear setup instructions

#=== SOURCE GUARD ================================================
[[ -n "${_CLEO_WEB_MCP_CHECK_LOADED:-}" ]] && return 0
declare -r _CLEO_WEB_MCP_CHECK_LOADED=1

# Note: We do NOT set -euo pipefail here because this is a library meant to be sourced.
# Setting these globally would affect the caller's shell.

# ============================================================================
# MCP DEFINITIONS (using functions for Bash 3.x compatibility)
# ============================================================================

# Get MCP description
_get_mcp_description() {
    case "$1" in
        gsc) echo "Google Search Console - provides ranking data, CTR, impressions" ;;
        dataforseo) echo "DataForSEO - provides keyword research, search volume, difficulty, Lighthouse, backlinks" ;;
        scraperapi) echo "ScraperAPI - provides HTML fetching for schema validation, security headers" ;;
        playwright) echo "Playwright - provides visual testing, screenshots, mobile rendering" ;;
        astro-docs) echo "Astro Documentation - provides framework best practices" ;;
        astro-mcp) echo "Astro Project Integration - provides routes, config, collections" ;;
        *) echo "Unknown MCP" ;;
    esac
}

# Get commands that require an MCP
_get_mcp_commands() {
    case "$1" in
        gsc) echo "seo-wins seo-gaps seo-roi seo-refresh seo-impact audit-content audit-site" ;;
        dataforseo) echo "seo-keywords audit-content audit-site content-strategist" ;;
        scraperapi) echo "audit-site audit-content audit-schema audit-security" ;;
        playwright) echo "audit-visual screenshot visual-test" ;;
        astro-docs) echo "astro-check feature-deploy" ;;
        astro-mcp) echo "astro-check status" ;;
        *) echo "" ;;
    esac
}

# List of core MCPs (required)
CORE_MCP_LIST="gsc dataforseo scraperapi"

# List of optional MCPs (enhance functionality)
OPTIONAL_MCP_LIST="playwright"

# List of Astro MCPs
ASTRO_MCP_LIST="astro-docs astro-mcp"

# All MCPs for iteration
ALL_MCP_LIST="gsc dataforseo scraperapi playwright astro-docs astro-mcp"

# ============================================================================
# MCP VERIFICATION FUNCTIONS
# ============================================================================

# Check if a specific MCP is available
# Args: $1 = MCP name (e.g., "gsc", "dataforseo")
# Returns: 0 if available, 1 if not
check_mcp_available() {
    local mcp_name="$1"

    # In Claude Code, MCPs are exposed as mcp__<server>__<tool> functions
    # We check for the presence of common tools for each MCP

    case "$mcp_name" in
        "gsc")
            # Check for GSC MCP tools
            if [[ -n "${MCP_GSC_AVAILABLE:-}" ]]; then
                return 0
            fi
            # In real execution, Claude would check for mcp__gsc__* tools
            # This is a placeholder for the actual check
            return 1
            ;;
        "dataforseo")
            if [[ -n "${MCP_DATAFORSEO_AVAILABLE:-}" ]]; then
                return 0
            fi
            return 1
            ;;
        "scraperapi")
            if [[ -n "${MCP_SCRAPERAPI_AVAILABLE:-}" ]]; then
                return 0
            fi
            return 1
            ;;
        "playwright")
            if [[ -n "${MCP_PLAYWRIGHT_AVAILABLE:-}" ]]; then
                return 0
            fi
            return 1
            ;;
        "astro-docs")
            if [[ -n "${MCP_ASTRO_DOCS_AVAILABLE:-}" ]]; then
                return 0
            fi
            return 1
            ;;
        "astro-mcp")
            if [[ -n "${MCP_ASTRO_MCP_AVAILABLE:-}" ]]; then
                return 0
            fi
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# Get setup instructions for an MCP
# Args: $1 = MCP name
# Returns: Setup instructions as text
get_mcp_setup_instructions() {
    local mcp_name="$1"

    case "$mcp_name" in
        "gsc")
            cat <<'EOF'
Google Search Console MCP Setup:

1. Install the MCP server:
   npm install -g gsc-mcp-server

2. Configure credentials:
   - Go to Google Cloud Console
   - Create a service account with Search Console API access
   - Download the JSON key file
   - Set environment variable:
     export GOOGLE_APPLICATION_CREDENTIALS="/path/to/credentials.json"

3. Add to your Claude Code settings (.claude/settings.local.json):
   {
     "mcpServers": {
       "gsc": {
         "command": "gsc-mcp-server",
         "args": ["--site-url", "https://your-site.com"]
       }
     }
   }

4. Restart Claude Code and verify with: /status
EOF
            ;;
        "dataforseo")
            cat <<'EOF'
DataForSEO MCP Setup:

1. Get API credentials:
   - Sign up at https://dataforseo.com
   - Note your username and password from dashboard

2. Set environment variables:
   export DATAFORSEO_USERNAME="your_username"
   export DATAFORSEO_PASSWORD="your_password"

3. Add to your Claude Code settings (.claude/settings.local.json):
   {
     "mcpServers": {
       "dataforseo": {
         "command": "npx",
         "args": ["-y", "dataforseo-mcp-server"],
         "env": {
           "DATAFORSEO_USERNAME": "${DATAFORSEO_USERNAME}",
           "DATAFORSEO_PASSWORD": "${DATAFORSEO_PASSWORD}"
         }
       }
     }
   }

4. Restart Claude Code and verify with: /status
EOF
            ;;
        "scraperapi")
            cat <<'EOF'
ScraperAPI MCP Setup:

1. Get API key:
   - Sign up at https://www.scraperapi.com
   - Get your API key from the dashboard

2. Set environment variable:
   export SCRAPERAPI_KEY="your_api_key"

3. Add to your Claude Code settings (.claude/settings.local.json):
   {
     "mcpServers": {
       "scraperapi": {
         "command": "npx",
         "args": ["-y", "scraperapi-mcp-server"],
         "env": {
           "SCRAPERAPI_KEY": "${SCRAPERAPI_KEY}"
         }
       }
     }
   }

4. Restart Claude Code and verify with: /status

Note: ScraperAPI is used for HTML fetching to validate schema markup,
security headers, and other on-page elements.
EOF
            ;;
        "playwright")
            cat <<'EOF'
Playwright MCP Setup (Optional):

1. Install the MCP server:
   npm install -g playwright-mcp-server

2. Install browser binaries:
   npx playwright install chromium

3. Add to your Claude Code settings (.claude/settings.local.json):
   {
     "mcpServers": {
       "playwright": {
         "command": "playwright-mcp-server",
         "env": {
           "PLAYWRIGHT_BROWSERS": "chromium"
         }
       }
     }
   }

4. Restart Claude Code and verify with: /status

Note: Playwright enables visual testing features including screenshots,
mobile rendering verification, and visual regression testing.
EOF
            ;;
        "astro-docs")
            cat <<'EOF'
Astro Documentation MCP Setup:

1. Add to your Claude Code settings (.claude/settings.local.json):
   {
     "mcpServers": {
       "astro-docs": {
         "url": "https://mcp.docs.astro.build/mcp",
         "type": "http"
       }
     }
   }

2. Restart Claude Code and verify with: /status
EOF
            ;;
        "astro-mcp")
            cat <<'EOF'
Astro Project MCP Setup:

1. Install in your Astro project:
   npx astro add astro-mcp

2. The integration auto-configures the MCP server

3. Start your Astro dev server:
   npm run dev

4. Restart Claude Code and verify with: /status
EOF
            ;;
        *)
            echo "Unknown MCP: $mcp_name"
            echo "Check the cleo-web documentation for setup instructions."
            ;;
    esac
}

# Check all required MCPs for a command
# Args: $1 = command name (e.g., "seo-wins")
# Returns: 0 if all required MCPs available, 1 if any missing
check_command_requirements() {
    local command="$1"
    local missing_mcps=""
    local mcp_name commands

    # Check each MCP to see if this command requires it
    for mcp_name in $ALL_MCP_LIST; do
        commands=$(_get_mcp_commands "$mcp_name")

        # Check if command is in this MCP's required commands
        if [[ " $commands " == *" $command "* ]]; then
            if ! check_mcp_available "$mcp_name"; then
                missing_mcps="$missing_mcps $mcp_name"
            fi
        fi
    done

    # Trim leading space
    missing_mcps="${missing_mcps# }"

    if [[ -n "$missing_mcps" ]]; then
        echo "ERROR: Command '$command' requires the following MCP servers:" >&2
        echo "" >&2
        for mcp in $missing_mcps; do
            echo "  - $mcp: $(_get_mcp_description "$mcp")" >&2
        done
        echo "" >&2
        echo "Setup instructions:" >&2
        echo "" >&2
        for mcp in $missing_mcps; do
            echo "=== $mcp ===" >&2
            get_mcp_setup_instructions "$mcp" >&2
            echo "" >&2
        done
        return 1
    fi

    return 0
}

# Check all core MCPs
# Returns: 0 if all available, 1 if any missing
check_core_mcps() {
    local missing=""
    local mcp_name

    for mcp_name in $CORE_MCP_LIST; do
        if ! check_mcp_available "$mcp_name"; then
            missing="$missing $mcp_name"
        fi
    done

    missing="${missing# }"

    if [[ -n "$missing" ]]; then
        echo "WARNING: Missing core MCP servers:" >&2
        for mcp in $missing; do
            echo "  - $mcp: $(_get_mcp_description "$mcp")" >&2
        done
        echo "" >&2
        echo "Some commands will not be available until these are configured." >&2
        echo "Run: cleo-web setup --verify for detailed setup instructions." >&2
        return 1
    fi

    echo "All core MCP servers available." >&2
    return 0
}

# Check optional MCPs
# Returns: List of available optional MCPs
check_optional_mcps() {
    local available=""
    local mcp_name

    for mcp_name in $OPTIONAL_MCP_LIST; do
        if check_mcp_available "$mcp_name"; then
            available="$available $mcp_name"
        fi
    done

    available="${available# }"

    if [[ -n "$available" ]]; then
        echo "Optional MCPs available: $available" >&2
    else
        echo "No optional MCPs configured." >&2
        echo "Consider adding: $OPTIONAL_MCP_LIST for enhanced features." >&2
    fi

    echo "$available"
}

# Check framework-specific MCPs
# Args: $1 = framework name (e.g., "astro")
# Returns: 0 if all available, 1 if any missing
check_framework_mcps() {
    local framework="$1"
    local missing=""
    local mcp_list=""
    local mcp_name

    case "$framework" in
        "astro")
            mcp_list="$ASTRO_MCP_LIST"
            ;;
        *)
            # Unknown framework - no additional MCPs required
            return 0
            ;;
    esac

    for mcp_name in $mcp_list; do
        if ! check_mcp_available "$mcp_name"; then
            missing="$missing $mcp_name"
        fi
    done

    missing="${missing# }"

    if [[ -n "$missing" ]]; then
        echo "WARNING: Missing $framework MCP servers:" >&2
        for mcp in $missing; do
            echo "  - $mcp: $(_get_mcp_description "$mcp")" >&2
        done
        echo "" >&2
        echo "Framework-specific features will be limited." >&2
        return 1
    fi

    echo "All $framework MCP servers available." >&2
    return 0
}

# Detect framework from project files
# Returns: framework name (astro, next, nuxt, or unknown)
detect_framework() {
    local project_dir="${1:-.}"

    # Check for Astro
    if [[ -f "$project_dir/astro.config.mjs" ]] || \
       [[ -f "$project_dir/astro.config.js" ]] || \
       [[ -f "$project_dir/astro.config.ts" ]]; then
        echo "astro"
        return 0
    fi

    # Check for Next.js
    if [[ -f "$project_dir/next.config.js" ]] || \
       [[ -f "$project_dir/next.config.mjs" ]] || \
       [[ -f "$project_dir/next.config.ts" ]]; then
        echo "nextjs"
        return 0
    fi

    # Check for Nuxt
    if [[ -f "$project_dir/nuxt.config.js" ]] || \
       [[ -f "$project_dir/nuxt.config.ts" ]]; then
        echo "nuxt"
        return 0
    fi

    # Check package.json for framework dependencies
    if [[ -f "$project_dir/package.json" ]]; then
        if grep -q '"astro"' "$project_dir/package.json" 2>/dev/null; then
            echo "astro"
            return 0
        fi
        if grep -q '"next"' "$project_dir/package.json" 2>/dev/null; then
            echo "nextjs"
            return 0
        fi
        if grep -q '"nuxt"' "$project_dir/package.json" 2>/dev/null; then
            echo "nuxt"
            return 0
        fi
    fi

    echo "generic"
    return 0
}

# Full MCP verification for /start command
# Returns: 0 if minimum requirements met, 1 if critical MCPs missing
verify_all_mcps() {
    local project_dir="${1:-.}"
    local exit_code=0

    echo "Verifying MCP server availability..." >&2
    echo "" >&2

    # Check core MCPs
    echo "Core MCPs:" >&2
    if ! check_core_mcps; then
        exit_code=1
    fi
    echo "" >&2

    # Detect and check framework MCPs
    local framework
    framework=$(detect_framework "$project_dir")

    if [[ "$framework" != "generic" ]]; then
        echo "Detected framework: $framework" >&2
        echo "Framework MCPs:" >&2
        if ! check_framework_mcps "$framework"; then
            # Framework MCPs missing is a warning, not failure
            :
        fi
    else
        echo "No recognized framework detected." >&2
        echo "Framework-specific features will not be available." >&2
    fi

    echo "" >&2

    if [[ $exit_code -eq 0 ]]; then
        echo "MCP verification complete. All required servers available." >&2
    else
        echo "MCP verification complete with warnings." >&2
        echo "Some features will be unavailable. Run /setup verify for details." >&2
    fi

    return $exit_code
}

# Export functions
export -f check_mcp_available
export -f get_mcp_setup_instructions
export -f check_command_requirements
export -f check_core_mcps
export -f check_framework_mcps
export -f detect_framework
export -f verify_all_mcps
