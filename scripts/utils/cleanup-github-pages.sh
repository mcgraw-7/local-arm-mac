#!/bin/zsh
# Script to clean up all GitHub Pages related files

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the repository root directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "${BLUE}====================================================${NC}"
echo "${BLUE}Cleaning up GitHub Pages files${NC}"
echo "${BLUE}====================================================${NC}"

# Remove GitHub Pages files
echo "Removing GitHub Pages related files..."

# Remove Jekyll config files
rm -f "$REPO_ROOT/_config.yml"
rm -f "$REPO_ROOT/Gemfile"
rm -f "$REPO_ROOT/CNAME"
rm -rf "$REPO_ROOT/_layouts"
rm -rf "$REPO_ROOT/_includes"
rm -rf "$REPO_ROOT/assets"

# Remove content files
rm -f "$REPO_ROOT/index.md"
rm -f "$REPO_ROOT/navigation.md"
rm -f "$REPO_ROOT/GITHUB_PAGES.md"
rm -rf "$REPO_ROOT/docs/github-pages-setup.md"

# Remove GitHub workflow files
rm -rf "$REPO_ROOT/.github/workflows/pages.yml"
rm -rf "$REPO_ROOT/.github/workflows/deploy-github-pages.yml"

# Keep the update-github-pages.sh script for reference but rename it
if [ -f "$REPO_ROOT/scripts/utils/update-github-pages.sh" ]; then
    mv "$REPO_ROOT/scripts/utils/update-github-pages.sh" "$REPO_ROOT/scripts/utils/update-github-pages.sh.bak"
    echo "${YELLOW}Renamed update-github-pages.sh to update-github-pages.sh.bak${NC}"
fi

echo "${GREEN}✅ GitHub Pages files removed successfully${NC}"
echo ""
echo "${YELLOW}Note: The README.md file is now the only documentation source${NC}"
echo "${BLUE}====================================================${NC}"
