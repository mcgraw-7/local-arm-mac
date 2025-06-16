#!/bin/zsh
# Script to clean up duplicate and unnecessary WebLogic scripts

echo "Starting script cleanup..."

# Create backup directory
BACKUP_DIR="$(date +%Y%m%d-%H%M%S)-script-backup"
mkdir -p "$BACKUP_DIR"

# Function to backup and remove a file
backup_and_remove() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "Backing up and removing: $file"
        cp "$file" "$BACKUP_DIR/"
        rm "$file"
    fi
}

# WebLogic scripts cleanup
echo "Cleaning up WebLogic scripts..."
backup_and_remove "scripts/weblogic/create-domain-m3.sh"
backup_and_remove "scripts/weblogic/old-check-weblogic-status.sh"
backup_and_remove "scripts/weblogic/start-weblogic-with-checks.sh"
backup_and_remove "scripts/java/run-with-oracle-jdk.sh"

# Verify remaining scripts
echo "Verifying remaining scripts..."
for script in scripts/weblogic/*.sh scripts/java/*.sh; do
    if [ -f "$script" ]; then
        echo "Testing script: $script"
        if [ -s "$script" ]; then
            echo "✅ $script is non-empty"
        else
            echo "❌ $script is empty - removing"
            backup_and_remove "$script"
        fi
    fi
done

echo "Cleanup complete. Backups stored in: $BACKUP_DIR"
echo "Please review the following scripts for any necessary updates:"
echo "1. scripts/weblogic/create-domain-m3-fixed.sh"
echo "2. scripts/weblogic/check-weblogic-status.sh"
echo "3. scripts/weblogic/start-weblogic.sh"
echo "4. scripts/java/weblogic-java-env-limited.sh"
echo "5. scripts/java/limited-access-java-env.sh" 