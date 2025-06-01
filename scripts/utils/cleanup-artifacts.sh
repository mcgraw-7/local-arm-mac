#!/bin/zsh
# Script to clean up temporary files and artifacts in the WebLogic environment

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}====================================================${NC}"
echo "${BLUE}WebLogic Environment Cleanup${NC}"
echo "${BLUE}====================================================${NC}"

echo "This script will help clean up temporary files and artifacts that should not be committed to Git."

# Function to safely remove files
clean_files() {
    local pattern="$1"
    local description="$2"
    
    echo "${BLUE}Looking for $description...${NC}"
    files=$(find . -path "$pattern" -type f 2>/dev/null)
    
    if [ -n "$files" ]; then
        echo "${YELLOW}Found the following files:${NC}"
        echo "$files"
        echo ""
        echo -n "Do you want to remove these files? (y/n): "
        read confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Removing files..."
            find . -path "$pattern" -type f -delete 2>/dev/null
            echo "${GREEN}✅ Files removed${NC}"
        else
            echo "${YELLOW}Skipping removal${NC}"
        fi
    else
        echo "${GREEN}✅ No $description found${NC}"
    fi
    
    echo ""
}

# Get the root directory for this project
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
echo "Working from directory: ${PROJECT_ROOT}"
echo ""

# Check if we're in the right directory
if [[ "$PROJECT_ROOT" != *"/local-arm-mac"* ]]; then
    echo "${RED}Warning: This script should be run from the local-arm-mac directory${NC}"
    echo "${YELLOW}Current directory: ${PROJECT_ROOT}${NC}"
    echo -n "Do you want to continue anyway? (y/n): "
    read confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 1
    fi
fi

echo "${BLUE}Checking for common WebLogic artifact files...${NC}"

# Check for WebLogic log files
clean_files "**/hazelcastLog.txt" "Hazelcast logs"
clean_files "**/ajcore.*.txt" "AspectJ core dump files"
clean_files "**/*.log" "Log files"

# Check for WebLogic installer and related files
clean_files "**/fmw_*.jar" "WebLogic installer JARs"
clean_files "**/fmw_*_readme.html" "WebLogic readme files"

# Check for backup files
clean_files "**/*.bak" "Backup files"

# Check for Yarn related files in folders they shouldn't be in
clean_files "../**/yarn-error.log" "Yarn error logs outside designated directories"
clean_files "../**/yarn.lock" "Yarn lock files outside designated directories" 

# Check for local property files
clean_files "**/local.properties" "Local property files"

echo "${BLUE}====================================================${NC}"
echo "${GREEN}Cleanup process complete${NC}"
echo "${BLUE}====================================================${NC}"

echo "Tip: Make sure you add these patterns to .gitignore if they're not already there."
echo "Current .gitignore file should already contain most of these patterns."
