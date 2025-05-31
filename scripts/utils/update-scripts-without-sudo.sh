#!/bin/zsh
# Script to update JAVA_HOME in WebLogic shell scripts without sudo
# This script creates a new version of each script with updated JAVA_HOME

JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"
SCRIPT_DIR="/Users/michaelmcgraw/dev"
UPDATED_DIR="${SCRIPT_DIR}/updated-scripts-$(date +%Y%m%d-%H%M%S)"

# Check if Oracle JDK exists
if [ ! -d "$JDK_PATH" ]; then
    echo "ERROR: Oracle JDK not found at $JDK_PATH"
    echo "Please ensure jdk1.8.0_45.jdk is installed at the specified location."
    exit 1
fi

# Create directory for updated scripts
mkdir -p "$UPDATED_DIR"
echo "Created directory for updated scripts: $UPDATED_DIR"

# Find all shell scripts with JAVA_HOME
echo "Finding scripts with JAVA_HOME references..."
count=0
for script in ${SCRIPT_DIR}/*.sh; do
    # Skip our update scripts
    if [[ "$script" == *"limited-access"* || "$script" == *"update-"* ]]; then
        continue
    fi
    
    # Check if script contains JAVA_HOME
    if grep -q "JAVA_HOME" "$script"; then
        script_name=$(basename "$script")
        echo "Processing: $script_name"
        
        # Create updated version
        cp "$script" "${UPDATED_DIR}/${script_name}"
        
        # Replace JAVA_HOME paths with the correct one
        sed -i '' 's|JAVA_HOME=.*|JAVA_HOME="'"$JDK_PATH"'"|g' "${UPDATED_DIR}/${script_name}"
        sed -i '' 's|export JAVA_HOME=.*|export JAVA_HOME="'"$JDK_PATH"'"|g' "${UPDATED_DIR}/${script_name}"
        
        # Fix JDK_PATH variables in scripts
        sed -i '' 's|JDK_PATH=.*|JDK_PATH="'"$JDK_PATH"'"|g' "${UPDATED_DIR}/${script_name}"
        
        echo "Updated: ${UPDATED_DIR}/${script_name}"
        
        # Make script executable
        chmod +x "${UPDATED_DIR}/${script_name}"
        
        count=$((count + 1))
    fi
done

echo ""
echo "Successfully updated JAVA_HOME in $count WebLogic shell scripts"
echo "Updated scripts are available in: $UPDATED_DIR"
echo ""
echo "To use these updated scripts:"
echo "1. Verify they work correctly"
echo "2. Copy them to your dev directory as needed:"
echo "   cp ${UPDATED_DIR}/script-name.sh ${SCRIPT_DIR}/"
