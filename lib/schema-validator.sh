#!/usr/bin/env bash
# schema-validator.sh - JSON-LD structured data validation
#
# Validates JSON-LD schema markup for SEO compliance and rich results eligibility.

# Get script directory for relative paths
SCHEMA_VALIDATOR_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# SCHEMA TYPE DEFINITIONS
# =============================================================================

# Required properties for each schema type
declare -A SCHEMA_REQUIRED_PROPS

# Organization schema
SCHEMA_REQUIRED_PROPS["Organization"]="name,url"
SCHEMA_REQUIRED_PROPS["Organization.recommended"]="logo,sameAs,contactPoint"

# WebSite schema
SCHEMA_REQUIRED_PROPS["WebSite"]="name,url"
SCHEMA_REQUIRED_PROPS["WebSite.recommended"]="potentialAction"

# Article/BlogPosting schema
SCHEMA_REQUIRED_PROPS["Article"]="headline,datePublished,author"
SCHEMA_REQUIRED_PROPS["Article.recommended"]="dateModified,image,publisher"
SCHEMA_REQUIRED_PROPS["BlogPosting"]="headline,datePublished,author"
SCHEMA_REQUIRED_PROPS["BlogPosting.recommended"]="dateModified,image,publisher"

# FAQPage schema
SCHEMA_REQUIRED_PROPS["FAQPage"]="mainEntity"
SCHEMA_REQUIRED_PROPS["Question"]="name,acceptedAnswer"
SCHEMA_REQUIRED_PROPS["Answer"]="text"

# Product schema
SCHEMA_REQUIRED_PROPS["Product"]="name"
SCHEMA_REQUIRED_PROPS["Product.recommended"]="image,description,offers,review,aggregateRating"

# BreadcrumbList schema
SCHEMA_REQUIRED_PROPS["BreadcrumbList"]="itemListElement"
SCHEMA_REQUIRED_PROPS["ListItem"]="position,item"

# LocalBusiness schema
SCHEMA_REQUIRED_PROPS["LocalBusiness"]="name,address"
SCHEMA_REQUIRED_PROPS["LocalBusiness.recommended"]="telephone,openingHours,geo"

# Person schema (for author)
SCHEMA_REQUIRED_PROPS["Person"]="name"
SCHEMA_REQUIRED_PROPS["Person.recommended"]="url,image,jobTitle"

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Extract JSON-LD from HTML content
# Usage: extract_jsonld <html_content>
extract_jsonld() {
    local html="$1"

    # Extract all script tags with type="application/ld+json"
    echo "$html" | grep -oP '<script[^>]*type="application/ld\+json"[^>]*>.*?</script>' | \
        sed 's/<script[^>]*>//g' | \
        sed 's/<\/script>//g'
}

# Validate JSON syntax
# Usage: validate_json_syntax <json_string>
validate_json_syntax() {
    local json="$1"

    if echo "$json" | jq . >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Get schema type from JSON-LD
# Usage: get_schema_type <json_ld>
get_schema_type() {
    local json="$1"

    echo "$json" | jq -r '.["@type"] // empty'
}

# Check if property exists in JSON-LD
# Usage: has_property <json_ld> <property_name>
has_property() {
    local json="$1"
    local prop="$2"

    local value
    value=$(echo "$json" | jq -r ".[\"$prop\"] // empty")

    [[ -n "$value" && "$value" != "null" ]]
}

# Validate schema against required properties
# Usage: validate_schema_properties <json_ld> <schema_type>
# Returns: JSON with validation results
validate_schema_properties() {
    local json="$1"
    local schema_type="$2"

    local required="${SCHEMA_REQUIRED_PROPS[$schema_type]:-}"
    local recommended="${SCHEMA_REQUIRED_PROPS["${schema_type}.recommended"]:-}"

    local missing_required=()
    local missing_recommended=()
    local present=()

    # Check required properties
    if [[ -n "$required" ]]; then
        IFS=',' read -ra props <<< "$required"
        for prop in "${props[@]}"; do
            if has_property "$json" "$prop"; then
                present+=("$prop")
            else
                missing_required+=("$prop")
            fi
        done
    fi

    # Check recommended properties
    if [[ -n "$recommended" ]]; then
        IFS=',' read -ra props <<< "$recommended"
        for prop in "${props[@]}"; do
            if has_property "$json" "$prop"; then
                present+=("$prop")
            else
                missing_recommended+=("$prop")
            fi
        done
    fi

    # Build result JSON
    cat <<EOF
{
  "schemaType": "$schema_type",
  "valid": $([ ${#missing_required[@]} -eq 0 ] && echo "true" || echo "false"),
  "presentProperties": $(printf '%s\n' "${present[@]}" | jq -R . | jq -s .),
  "missingRequired": $(printf '%s\n' "${missing_required[@]}" | jq -R . | jq -s .),
  "missingRecommended": $(printf '%s\n' "${missing_recommended[@]}" | jq -R . | jq -s .)
}
EOF
}

# Validate a complete JSON-LD block
# Usage: validate_jsonld <json_ld>
# Returns: JSON with full validation results
validate_jsonld() {
    local json="$1"

    # Check syntax first
    if ! validate_json_syntax "$json"; then
        cat <<EOF
{
  "valid": false,
  "syntaxValid": false,
  "error": "Invalid JSON syntax"
}
EOF
        return 1
    fi

    # Get schema type
    local schema_type
    schema_type=$(get_schema_type "$json")

    if [[ -z "$schema_type" ]]; then
        cat <<EOF
{
  "valid": false,
  "syntaxValid": true,
  "error": "Missing @type property"
}
EOF
        return 1
    fi

    # Handle @graph structures
    if [[ "$schema_type" == "null" ]]; then
        local has_graph
        has_graph=$(echo "$json" | jq 'has("@graph")')

        if [[ "$has_graph" == "true" ]]; then
            # Validate each item in @graph
            local results=()
            local all_valid=true

            while IFS= read -r item; do
                local item_result
                item_result=$(validate_jsonld "$item")
                results+=("$item_result")

                local item_valid
                item_valid=$(echo "$item_result" | jq -r '.valid')
                if [[ "$item_valid" != "true" ]]; then
                    all_valid=false
                fi
            done < <(echo "$json" | jq -c '.["@graph"][]')

            cat <<EOF
{
  "valid": $all_valid,
  "syntaxValid": true,
  "isGraph": true,
  "items": $(printf '%s\n' "${results[@]}" | jq -s .)
}
EOF
            return 0
        fi
    fi

    # Validate properties
    local prop_result
    prop_result=$(validate_schema_properties "$json" "$schema_type")

    local is_valid
    is_valid=$(echo "$prop_result" | jq -r '.valid')

    cat <<EOF
{
  "valid": $is_valid,
  "syntaxValid": true,
  "schemaType": "$schema_type",
  "properties": $prop_result
}
EOF
}

# =============================================================================
# RICH RESULTS ELIGIBILITY
# =============================================================================

# Check if schema is eligible for rich results
# Usage: check_rich_results_eligibility <json_ld>
check_rich_results_eligibility() {
    local json="$1"
    local schema_type
    schema_type=$(get_schema_type "$json")

    local eligible="false"
    local reason=""
    local features=()

    case "$schema_type" in
        "FAQPage")
            # Check for mainEntity with questions
            local question_count
            question_count=$(echo "$json" | jq '.mainEntity | length')
            if [[ "$question_count" -gt 0 ]]; then
                eligible="true"
                features+=("FAQ rich results")
                reason="FAQPage with $question_count questions"
            else
                reason="FAQPage missing questions in mainEntity"
            fi
            ;;

        "Article"|"BlogPosting"|"NewsArticle")
            # Check for required article properties
            if has_property "$json" "headline" && has_property "$json" "datePublished"; then
                eligible="true"
                features+=("Article rich results")
                if has_property "$json" "image"; then
                    features+=("Image thumbnail")
                fi
                reason="Valid article markup"
            else
                reason="Missing headline or datePublished"
            fi
            ;;

        "Product")
            # Check for offers or review
            if has_property "$json" "offers" || has_property "$json" "aggregateRating"; then
                eligible="true"
                features+=("Product rich results")
                if has_property "$json" "offers"; then
                    features+=("Price display")
                fi
                if has_property "$json" "aggregateRating"; then
                    features+=("Star ratings")
                fi
                reason="Valid product markup"
            else
                reason="Missing offers or aggregateRating"
            fi
            ;;

        "BreadcrumbList")
            local item_count
            item_count=$(echo "$json" | jq '.itemListElement | length')
            if [[ "$item_count" -gt 1 ]]; then
                eligible="true"
                features+=("Breadcrumb trail")
                reason="Valid breadcrumb with $item_count items"
            else
                reason="Breadcrumb needs at least 2 items"
            fi
            ;;

        "LocalBusiness"|"Restaurant"|"Store")
            if has_property "$json" "name" && has_property "$json" "address"; then
                eligible="true"
                features+=("Local business panel")
                if has_property "$json" "openingHours"; then
                    features+=("Hours display")
                fi
                reason="Valid local business markup"
            else
                reason="Missing name or address"
            fi
            ;;

        "Organization")
            if has_property "$json" "name" && has_property "$json" "logo"; then
                eligible="true"
                features+=("Knowledge panel")
                reason="Valid organization markup"
            else
                reason="Missing name or logo for knowledge panel"
            fi
            ;;

        *)
            reason="Schema type '$schema_type' not eligible for rich results"
            ;;
    esac

    cat <<EOF
{
  "schemaType": "$schema_type",
  "eligible": $eligible,
  "reason": "$reason",
  "features": $(printf '%s\n' "${features[@]}" | jq -R . | jq -s .)
}
EOF
}

# =============================================================================
# PAGE VALIDATION
# =============================================================================

# Validate all JSON-LD on a page
# Usage: validate_page_schema <html_content>
validate_page_schema() {
    local html="$1"

    local schemas=()
    local all_valid=true
    local rich_results_eligible=()

    # Extract and validate each JSON-LD block
    while IFS= read -r jsonld; do
        if [[ -n "$jsonld" ]]; then
            local result
            result=$(validate_jsonld "$jsonld")
            schemas+=("$result")

            local is_valid
            is_valid=$(echo "$result" | jq -r '.valid')
            if [[ "$is_valid" != "true" ]]; then
                all_valid=false
            fi

            # Check rich results eligibility
            local rich_result
            rich_result=$(check_rich_results_eligibility "$jsonld")
            local is_eligible
            is_eligible=$(echo "$rich_result" | jq -r '.eligible')
            if [[ "$is_eligible" == "true" ]]; then
                rich_results_eligible+=("$rich_result")
            fi
        fi
    done < <(extract_jsonld "$html")

    local schema_count=${#schemas[@]}
    local rich_count=${#rich_results_eligible[@]}

    cat <<EOF
{
  "valid": $all_valid,
  "schemaCount": $schema_count,
  "schemas": $(printf '%s\n' "${schemas[@]}" | jq -s .),
  "richResultsEligible": $rich_count,
  "richResults": $(printf '%s\n' "${rich_results_eligible[@]}" | jq -s .)
}
EOF
}

# =============================================================================
# SCHEMA GENERATION HELPERS
# =============================================================================

# Generate Organization schema
# Usage: generate_organization_schema <name> <url> [logo_url] [same_as_urls]
generate_organization_schema() {
    local name="$1"
    local url="$2"
    local logo="${3:-}"
    local same_as="${4:-}"

    local schema
    schema=$(cat <<EOF
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "$name",
  "url": "$url"
}
EOF
)

    if [[ -n "$logo" ]]; then
        schema=$(echo "$schema" | jq --arg logo "$logo" '. + {"logo": $logo}')
    fi

    if [[ -n "$same_as" ]]; then
        schema=$(echo "$schema" | jq --argjson sameAs "$same_as" '. + {"sameAs": $sameAs}')
    fi

    echo "$schema" | jq .
}

# Generate Article schema
# Usage: generate_article_schema <headline> <date_published> <author_name> [image_url]
generate_article_schema() {
    local headline="$1"
    local date_published="$2"
    local author_name="$3"
    local image="${4:-}"

    local schema
    schema=$(cat <<EOF
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "$headline",
  "datePublished": "$date_published",
  "author": {
    "@type": "Person",
    "name": "$author_name"
  }
}
EOF
)

    if [[ -n "$image" ]]; then
        schema=$(echo "$schema" | jq --arg image "$image" '. + {"image": $image}')
    fi

    echo "$schema" | jq .
}

# Generate FAQPage schema from Q&A pairs
# Usage: generate_faq_schema <questions_json>
# questions_json format: [{"question": "...", "answer": "..."}, ...]
generate_faq_schema() {
    local questions="$1"

    local main_entity
    main_entity=$(echo "$questions" | jq '[.[] | {
        "@type": "Question",
        "name": .question,
        "acceptedAnswer": {
            "@type": "Answer",
            "text": .answer
        }
    }]')

    cat <<EOF
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": $main_entity
}
EOF
}

# =============================================================================
# EXPORTS
# =============================================================================

export -f extract_jsonld 2>/dev/null || true
export -f validate_json_syntax 2>/dev/null || true
export -f validate_jsonld 2>/dev/null || true
export -f validate_page_schema 2>/dev/null || true
export -f check_rich_results_eligibility 2>/dev/null || true
export -f generate_organization_schema 2>/dev/null || true
export -f generate_article_schema 2>/dev/null || true
export -f generate_faq_schema 2>/dev/null || true
