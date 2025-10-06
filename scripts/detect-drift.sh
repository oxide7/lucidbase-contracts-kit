#!/bin/bash

# Drift Detection Script for Lucidbase Contracts Kit
# This script detects drift between the contracts kit and consumer repositories

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
CONTRACTS_KIT_REPO="oxide7/lucidbase-contracts-kit"
CONTRACTS_FILE="contracts/00-runtime-guard.md"
CONSUMER_REPOS=(
    "oxide7/lucidbase-ts"
    "oxide7/lucidbase-feat" 
    "oxide7/lucidbase-fix"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the latest version from the contracts kit
get_latest_version() {
    local latest_tag=$(gh api "repos/$CONTRACTS_KIT_REPO/tags" --jq '.[0].name' 2>/dev/null || echo "")
    if [ -z "$latest_tag" ]; then
        log_error "Failed to get latest version from $CONTRACTS_KIT_REPO"
        return 1
    fi
    echo "$latest_tag"
}

# Get the contract hash for a specific version
get_contract_hash() {
    local version="$1"
    local temp_dir=$(mktemp -d)
    
    # Clone the specific version
    git clone --depth 1 --branch "$version" "https://github.com/$CONTRACTS_KIT_REPO.git" "$temp_dir" 2>/dev/null || {
        log_error "Failed to clone version $version"
        rm -rf "$temp_dir"
        return 1
    }
    
    # Get the hash
    local hash=$(git -C "$temp_dir" hash-object "$CONTRACTS_FILE" 2>/dev/null || echo "")
    rm -rf "$temp_dir"
    
    if [ -z "$hash" ]; then
        log_error "Failed to get contract hash for version $version"
        return 1
    fi
    
    echo "$hash"
}

# Check drift in a consumer repository
check_consumer_drift() {
    local repo="$1"
    local expected_hash="$2"
    local latest_version="$3"
    
    log_info "Checking drift in $repo..."
    
    # Check if the repository exists and is accessible
    if ! gh repo view "$repo" >/dev/null 2>&1; then
        log_warning "Repository $repo not accessible or doesn't exist"
        return 0
    fi
    
    # Get the current contract file from the consumer repo
    local temp_file=$(mktemp)
    if gh api "repos/$repo/contents/$CONTRACTS_FILE" --jq -r '.content' | base64 -d > "$temp_file" 2>/dev/null; then
        local current_hash=$(git hash-object "$temp_file" 2>/dev/null || echo "")
        rm -f "$temp_file"
        
        if [ "$current_hash" = "$expected_hash" ]; then
            log_success "$repo is up to date (hash: $current_hash)"
            return 0
        else
            log_warning "$repo has drifted (expected: $expected_hash, current: $current_hash)"
            
            # Create a drift issue if it doesn't exist
            local issue_title="Contract Drift Detected - Update Required"
            local issue_body="## Contract Drift Detection

The contract file \`$CONTRACTS_FILE\` in this repository has drifted from the expected version.

**Details:**
- **Expected Hash:** \`$expected_hash\`
- **Current Hash:** \`$current_hash\`
- **Contracts Kit Version:** \`$latest_version\`

**Action Required:**
Please update the contract file to match the latest version from the contracts kit.

**How to Fix:**
1. Run the contract update script in your repository
2. Or manually copy the latest contract file from \`$CONTRACTS_KIT_REPO\` version \`$latest_version\`

This issue was automatically created by the drift detection system."
            
            # Check if an open issue with this title already exists
            local existing_issue=$(gh api "repos/$repo/issues" --jq '.[] | select(.title == "'"$issue_title"'" and .state == "open") | .number' 2>/dev/null || echo "")
            
            if [ -z "$existing_issue" ]; then
                log_info "Creating drift issue for $repo..."
                gh issue create --repo "$repo" --title "$issue_title" --body "$issue_body" --label "drift,contracts,automated" 2>/dev/null || {
                    log_warning "Failed to create issue for $repo (may not have permissions)"
                }
            else
                log_info "Drift issue already exists for $repo (issue #$existing_issue)"
            fi
            
            return 1
        fi
    else
        log_warning "Could not access contract file in $repo"
        return 0
    fi
}

# Main function
main() {
    log_info "Starting drift detection for Lucidbase contracts..."
    
    # Check if gh CLI is available and authenticated
    if ! command -v gh >/dev/null 2>&1; then
        log_error "GitHub CLI (gh) is not installed"
        exit 1
    fi
    
    if ! gh auth status >/dev/null 2>&1; then
        log_error "Not authenticated with GitHub CLI"
        exit 1
    fi
    
    # Get the latest version and contract hash
    log_info "Getting latest version from contracts kit..."
    local latest_version=$(get_latest_version)
    if [ -z "$latest_version" ]; then
        log_error "Could not determine latest version"
        exit 1
    fi
    
    log_info "Latest version: $latest_version"
    
    log_info "Getting contract hash for version $latest_version..."
    local expected_hash=$(get_contract_hash "$latest_version")
    if [ -z "$expected_hash" ]; then
        log_error "Could not get contract hash"
        exit 1
    fi
    
    log_info "Expected contract hash: $expected_hash"
    
    # Check each consumer repository
    local drifted_repos=()
    for repo in "${CONSUMER_REPOS[@]}"; do
        if ! check_consumer_drift "$repo" "$expected_hash" "$latest_version"; then
            drifted_repos+=("$repo")
        fi
    done
    
    # Summary
    echo ""
    log_info "Drift detection complete!"
    
    if [ ${#drifted_repos[@]} -eq 0 ]; then
        log_success "All repositories are up to date with contracts kit version $latest_version"
    else
        log_warning "Found drift in ${#drifted_repos[@]} repository(ies):"
        for repo in "${drifted_repos[@]}"; do
            echo "  - $repo"
        done
        echo ""
        log_info "Issues have been created for drifted repositories (where permissions allow)"
    fi
}

# Run main function
main "$@"
