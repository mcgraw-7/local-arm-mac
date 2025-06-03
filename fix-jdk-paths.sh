#!/bin/zsh
# Script to update Java paths in all shell scripts of local-arm-mac directory
# Created on June 3, 2025

OLD_JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"
NEW_JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
BASE_DIR="/Users/michaelmcgraw/dev/local-arm-mac"

echo "Updating JDK paths from $OLD_JDK_PATH to $NEW_JDK_PATH"
echo "This may take a moment..."

find "$BASE_DIR" -type f -name "*.sh" | while read file; do
    if grep -q "$OLD_JDK_PATH" "$file"; then
        echo "Updating: $file"
        sed -i '' "s|$OLD_JDK_PATH|$NEW_JDK_PATH|g" "$file"
    fi
done

# Also update .py files
find "$BASE_DIR" -type f -name "*.py" | while read file; do
    if grep -q "$OLD_JDK_PATH" "$file"; then
        echo "Updating: $file"
        sed -i '' "s|$OLD_JDK_PATH|$NEW_JDK_PATH|g" "$file"
    fi
done

echo "Update complete!"
echo "To verify, run:"
echo "grep -r \"jdk1.8.0_45\" $BASE_DIR --include=\"*.sh\" --include=\"*.py\""
