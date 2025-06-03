#!/bin/zsh
# Comprehensive script to update Java paths in all scripts
# Updates from JDK 1.8.0_45 to JDK 1.8.0_202

# Set color codes for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define paths
OLD_JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"
NEW_JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
SCRIPTS_DIR="/Users/michaelmcgraw/dev/local-arm-mac"
BACKUP_DIR="${SCRIPTS_DIR}/jdk-update-backup-$(date +%Y%m%d-%H%M%S)"

# Check if the new JDK exists
if [ ! -d "$NEW_JDK_PATH" ]; then
    echo "${RED}ERROR: New JDK not found at $NEW_JDK_PATH${NC}"
    echo "Please ensure JDK 1.8.0_202 is installed at this location."
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo "${BLUE}Created backup directory: $BACKUP_DIR${NC}"

# Find all files containing references to old JDK
echo "${BLUE}Finding files with old JDK paths...${NC}"
file_count=0
updated_count=0

# Find all relevant file types
find "$SCRIPTS_DIR" -type f \( -name "*.sh" -o -name "*.properties" -o -name "*.xml" -o -name "*.conf" \) | while read file; do
    # Check if file contains old JDK path strings
    if grep -q "jdk1.8.0_45\|jdk1.8.0_" "$file"; then
        file_count=$((file_count + 1))
        echo "${YELLOW}Processing: $(basename $file)${NC}"
        
        # Create backup
        cp "$file" "${BACKUP_DIR}/$(basename $file).bak"
        
        # Replace references to old JDK with new JDK
        sed -i '' "s|${OLD_JDK_PATH}|${NEW_JDK_PATH}|g" "$file"
        sed -i '' "s|/jdk1.8.0_45/|/jdk1.8.0_202/|g" "$file"
        sed -i '' "s|jdk1.8.0_45.jdk|jdk1.8.0_202.jdk|g" "$file"
        sed -i '' "s|\"1.8.0_45\"|\"1.8.0_202\"|g" "$file"
        sed -i '' "s|'1.8.0_45'|'1.8.0_202'|g" "$file"
        
        # Count successfully updated files
        if [ $? -eq 0 ]; then
            updated_count=$((updated_count + 1))
            echo "${GREEN}✅ Updated: $(basename $file)${NC}"
        else
            echo "${RED}❌ Failed to update: $(basename $file)${NC}"
        fi
    fi
done

# Update .wljava_env if it exists
if [ -f "${HOME}/.wljava_env" ]; then
    echo "${YELLOW}Processing: .wljava_env${NC}"
    cp "${HOME}/.wljava_env" "${BACKUP_DIR}/.wljava_env.bak"
    sed -i '' "s|${OLD_JDK_PATH}|${NEW_JDK_PATH}|g" "${HOME}/.wljava_env"
    sed -i '' "s|jdk1.8.0_45.jdk|jdk1.8.0_202.jdk|g" "${HOME}/.wljava_env"
    echo "${GREEN}✅ Updated: .wljava_env${NC}"
fi

# Final summary
echo ""
echo "${BLUE}=== Java Path Update Summary ===${NC}"
echo "${GREEN}Found $file_count files with JDK references${NC}"
echo "${GREEN}Successfully updated $updated_count files${NC}"
echo "${YELLOW}Backups saved to: $BACKUP_DIR${NC}"
echo ""
echo "To verify the updates, run:"
echo "    cd $SCRIPTS_DIR"
echo "    ./scripts/utils/verify-standardization.sh"
echo ""
