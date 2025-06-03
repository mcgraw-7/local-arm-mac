#!/bin/zsh
# Update JDK paths in WebLogic scripts to use JDK 1.8.0_202
# Created on June 3, 2025

# Set color codes for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}====================================================${NC}"
echo "${BLUE}Updating Java paths to JDK 1.8.0_202 in all scripts${NC}"
echo "${BLUE}====================================================${NC}"

# Define paths
OLD_JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"
NEW_JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
BASE_DIR="/Users/michaelmcgraw/dev/local-arm-mac"
BACKUP_DIR="${BASE_DIR}/updated-scripts-$(date +%Y%m%d-%H%M%S)"

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Created backup directory: $BACKUP_DIR"
fi

# Count of updated files
updated_count=0

# Find all script files with the old JDK path
echo "Searching for files with old JDK path references..."
files_to_update=$(grep -r "$OLD_JDK_PATH" "$BASE_DIR" --include="*.sh" --include="*.py" --include="*.properties" --include="*.conf" | cut -d: -f1 | sort | uniq)

# Update each file
for file in $files_to_update; do
    # Create a backup
    file_name=$(basename "$file")
    cp "$file" "${BACKUP_DIR}/${file_name}.bak"
    
    # Update the file
    sed -i '' "s|${OLD_JDK_PATH}|${NEW_JDK_PATH}|g" "$file"
    
    echo "${GREEN}✅ Updated:${NC} $file"
    updated_count=$((updated_count + 1))
done

# Update the .wljava_env file if it exists
if [ -f "$HOME/.wljava_env" ]; then
    cp "$HOME/.wljava_env" "${BACKUP_DIR}/.wljava_env.bak"
    sed -i '' "s|${OLD_JDK_PATH}|${NEW_JDK_PATH}|g" "$HOME/.wljava_env"
    echo "${GREEN}✅ Updated:${NC} $HOME/.wljava_env"
    updated_count=$((updated_count + 1))
fi

# Update verification scripts that check for specific JDK versions
verification_scripts=$(find "$BASE_DIR" -name "verify*.sh" -o -name "*verification*.sh" -o -name "*check*.sh")
for file in $verification_scripts; do
    if grep -q "jdk1.8.0_45" "$file"; then
        cp "$file" "${BACKUP_DIR}/$(basename "$file").bak"
        sed -i '' 's|jdk1.8.0_45|jdk1.8.0_202|g' "$file"
        echo "${GREEN}✅ Updated JDK version in:${NC} $file"
        updated_count=$((updated_count + 1))
    fi
done

echo "${BLUE}====================================================${NC}"
echo "${GREEN}Updated ${updated_count} files to use JDK 1.8.0_202${NC}"
echo "${BLUE}====================================================${NC}"
echo "Backups saved to: ${BACKUP_DIR}"
echo ""
echo "To verify the updates, run:"
echo "    cd $BASE_DIR"
echo "    ./scripts/utils/verify-java-standardization.sh"
