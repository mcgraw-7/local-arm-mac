#!/bin/zsh
# Comprehensive script cleanup and verification tool

echo "Starting comprehensive script cleanup..."

# Create backup directory with timestamp
BACKUP_DIR="$(date +%Y%m%d-%H%M%S)-script-backup"
mkdir -p "$BACKUP_DIR"

# Function to backup and remove a file
backup_and_remove() {
    local file="$1"
    local reason="$2"
    if [ -f "$file" ]; then
        echo "Backing up and removing: $file"
        echo "Reason: $reason"
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        cp "$file" "$BACKUP_DIR/$file"
        rm "$file"
    fi
}

# Function to verify script content
verify_script() {
    local script="$1"
    if [ -f "$script" ]; then
        echo "Verifying script: $script"
        
        # Check if file is empty
        if [ ! -s "$script" ]; then
            echo "❌ $script is empty"
            backup_and_remove "$script" "Empty script file"
            return 1
        fi
        
        # Check if file has execute permission
        if [ ! -x "$script" ]; then
            echo "⚠️ $script is not executable - fixing permissions"
            chmod +x "$script"
        fi
        
        # Check for common issues
        if grep -q "#!/bin/bash" "$script"; then
            echo "⚠️ $script uses bash instead of zsh - updating shebang"
            sed -i '' '1s|#!/bin/bash|#!/bin/zsh|' "$script"
        fi
        
        # Check for deprecated functions or patterns
        if grep -q "function" "$script"; then
            echo "ℹ️ $script uses 'function' keyword - consider updating to modern syntax"
        fi
        
        echo "✅ $script verified"
        return 0
    fi
    return 1
}

# Clean up empty or duplicate scripts
echo "Cleaning up empty and duplicate scripts..."

# Remove empty scripts
find . -type f -name "*.sh" -empty -exec rm {} \;

# Remove duplicate scripts with similar names
for script in $(find . -type f -name "*.sh"); do
    base_name=$(basename "$script" .sh)
    dir_name=$(dirname "$script")
    
    # Check for similar named files
    similar_files=$(find "$dir_name" -type f -name "${base_name}*" -not -name "$(basename "$script")")
    
    for similar in $similar_files; do
        if [ -f "$similar" ]; then
            # Compare file sizes
            if [ $(stat -f%z "$script") -gt $(stat -f%z "$similar") ]; then
                backup_and_remove "$similar" "Smaller duplicate of $script"
            else
                backup_and_remove "$script" "Smaller duplicate of $similar"
                break
            fi
        fi
    done
done

# Verify all remaining scripts
echo "Verifying remaining scripts..."
for script in $(find . -type f -name "*.sh"); do
    verify_script "$script"
done

# Check for potential script consolidation
echo "Checking for potential script consolidation opportunities..."

# Group similar scripts
echo "Similar script groups:"
echo "1. Java-related scripts:"
find . -type f -name "*.sh" -exec grep -l "java" {} \;
echo "2. WebLogic-related scripts:"
find . -type f -name "*.sh" -exec grep -l "weblogic" {} \;
echo "3. VBMS-related scripts:"
find . -type f -name "*.sh" -exec grep -l "vbms" {} \;

# Final report
echo "Cleanup complete. Backups stored in: $BACKUP_DIR"
echo "Please review the following for potential consolidation:"
echo "1. Java environment scripts"
echo "2. WebLogic startup scripts"
echo "3. Configuration verification scripts"
echo "4. Cleanup utility scripts"

# Create a summary report
echo "Creating summary report..."
SUMMARY_FILE="$BACKUP_DIR/cleanup-summary.txt"
{
    echo "Script Cleanup Summary"
    echo "====================="
    echo "Date: $(date)"
    echo "Backup Directory: $BACKUP_DIR"
    echo ""
    echo "Remaining Scripts:"
    find . -type f -name "*.sh" -exec echo "- {}" \;
    echo ""
    echo "Recommendations:"
    echo "1. Consider consolidating Java environment scripts"
    echo "2. Review WebLogic startup scripts for redundancy"
    echo "3. Standardize configuration verification scripts"
    echo "4. Combine similar cleanup utilities"
} > "$SUMMARY_FILE"

echo "Summary report created: $SUMMARY_FILE" 