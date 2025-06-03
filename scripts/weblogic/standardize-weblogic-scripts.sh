#!/bin/zsh
# Script to update WebLogic scripts to use the standardized JDK
# This script creates updated versions of scripts in a separate directory

JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
DEV_DIR="${HOME}/dev"
UPDATED_DIR="${DEV_DIR}/standardized-scripts"

echo "=== WebLogic Script Standardization Tool ==="
echo "This tool will create updated versions of your WebLogic scripts"
echo "with the standardized Oracle JDK path."
echo ""

# Check if Oracle JDK exists
if [ ! -d "$JDK_PATH" ]; then
    echo "ERROR: Required Oracle JDK not found at $JDK_PATH"
    exit 1
fi

# Create directory for updated scripts if it doesn't exist
mkdir -p "$UPDATED_DIR"
echo "Output directory: $UPDATED_DIR"

# Function to update a script
function update_script() {
    local script="$1"
    local script_name=$(basename "$script")
    
    # Skip if file doesn't exist
    if [ ! -f "$script" ]; then
        echo "⚠️  Script not found: $script"
        return
    fi
    
    # Skip if it's one of our utility scripts
    if [[ "$script_name" == *"wl-java"* || "$script_name" == *"standardize"* ]]; then
        return
    fi
    
    echo "Processing: $script_name"
    
    # Copy script to updated directory
    cp "$script" "$UPDATED_DIR/$script_name"
    
    # Update JAVA_HOME references
    sed -i '' 's|JAVA_HOME=.*|JAVA_HOME="'"$JDK_PATH"'"|g' "$UPDATED_DIR/$script_name"
    sed -i '' 's|export JAVA_HOME=.*|export JAVA_HOME="'"$JDK_PATH"'"|g' "$UPDATED_DIR/$script_name"
    
    # Update JDK_PATH references
    sed -i '' 's|JDK_PATH=.*|JDK_PATH="'"$JDK_PATH"'"|g' "$UPDATED_DIR/$script_name"
    
    # Make executable
    chmod +x "$UPDATED_DIR/$script_name"
    
    echo "✅ Updated: $script_name"
}

# Update critical WebLogic scripts
echo ""
echo "Updating critical WebLogic scripts..."

# Core configuration script
update_script "${DEV_DIR}/core-config-status.sh"

# Domain creation scripts
update_script "${DEV_DIR}/create-domain-arm64-fix.sh"
update_script "${DEV_DIR}/create-domain-m3.sh"
update_script "${DEV_DIR}/create-domain-unified.sh"

# WebLogic startup scripts
update_script "${DEV_DIR}/start-final.sh"
update_script "${DEV_DIR}/startWebLogic.sh"

# VBMS deployment scripts
update_script "${DEV_DIR}/deploy-vbms-m3.sh"
update_script "${DEV_DIR}/vbms-deploy-m3.sh"
update_script "${DEV_DIR}/vbms-final-deploy-m3.sh"

# Create a script to apply environment before running WebLogic
cat > "$UPDATED_DIR/run-weblogic.sh" << EOF
#!/bin/zsh
# Script to run WebLogic with the standardized Oracle JDK
# Usage: ./run-weblogic.sh <script-name>

SCRIPT_DIR="\$(dirname "\$0")"
ORACLE_JDK="$JDK_PATH"

if [ \$# -eq 0 ]; then
    echo "Usage: \$0 <script-name> [arguments]"
    echo "Example: \$0 startWebLogic.sh"
    exit 1
fi

# Setup environment
export JAVA_HOME="\$ORACLE_JDK"
export PATH="\$JAVA_HOME/bin:\$PATH"

# Apple Silicon Mac specific settings
export BYPASS_CPU_CHECK=true
export BYPASS_PREFLIGHT=true
export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"

# Display environment
echo "=== Running with Oracle JDK ==="
echo "JAVA_HOME: \$JAVA_HOME"
java -version
echo "==============================="

# Run the specified script
SCRIPT_NAME="\$1"
shift
"\$SCRIPT_DIR/\$SCRIPT_NAME" "\$@"
EOF

chmod +x "$UPDATED_DIR/run-weblogic.sh"
echo "✅ Created run-weblogic.sh utility script"

echo ""
echo "=== Script Standardization Complete ==="
echo ""
echo "Updated scripts are available in: $UPDATED_DIR"
echo ""
echo "To use standardized scripts:"
echo ""
echo "1. Run individual scripts from the standardized directory:"
echo "   $UPDATED_DIR/script-name.sh"
echo ""
echo "2. Run WebLogic with the correct Java environment:"
echo "   $UPDATED_DIR/run-weblogic.sh script-name.sh"
echo ""
echo "3. Copy scripts back to your dev directory if needed:"
echo "   cp $UPDATED_DIR/script-name.sh $DEV_DIR/"
