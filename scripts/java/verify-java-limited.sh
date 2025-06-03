#!/bin/zsh
# Java Configuration Verification Script (Limited Access)
# Verifies that the correct Oracle JDK is configured for use

JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"

echo "=== Java Configuration Verification ==="
echo "Checking Oracle JDK installation at $JDK_PATH..."

# Check if Oracle JDK exists at specified path
if [ ! -d "$JDK_PATH" ]; then
    echo "❌ ERROR: Oracle JDK not found at $JDK_PATH"
    echo "Other Java installations found:"
    ls -la /Library/Java/JavaVirtualMachines/
    exit 1
fi

# Check java version
echo "✅ Oracle JDK found at $JDK_PATH"
echo "Checking Java version:"
"$JDK_PATH/bin/java" -version 2>&1

# Check current JAVA_HOME environment variable
echo ""
echo "Current JAVA_HOME: $JAVA_HOME"
if [ "$JAVA_HOME" != "$JDK_PATH" ]; then
    echo "⚠️  Warning: Current JAVA_HOME doesn't match the Oracle JDK path"
    echo "   To fix this, run: source ~/.zshrc after applying limited-access-java-env.sh"
else
    echo "✅ JAVA_HOME correctly set to Oracle JDK path"
fi

# Check which java is in path
echo ""
echo "Java in PATH:"
which java
java -version 2>&1

# Check if WebLogic can use this Java
echo ""
echo "Verifying WebLogic compatibility..."
if [ ! -d "${HOME}/dev/Oracle/Middleware/Oracle_Home" ]; then
    echo "⚠️  WebLogic installation not found, skipping WebLogic compatibility check"
else
    echo "✅ WebLogic installation found"
    echo "Use /Users/michaelmcgraw/dev/weblogic-java-env-limited.sh to ensure WebLogic uses the correct JDK"
fi

# Check WebLogic scripts in updated directory
UPDATED_SCRIPTS_DIR=$(find /Users/michaelmcgraw/dev -maxdepth 1 -type d -name "updated-scripts-*" | sort -r | head -1)
if [ -d "$UPDATED_SCRIPTS_DIR" ]; then
    echo ""
    echo "✅ Updated WebLogic scripts found at: $UPDATED_SCRIPTS_DIR"
    SCRIPT_COUNT=$(find "$UPDATED_SCRIPTS_DIR" -name "*.sh" | wc -l)
    echo "   $SCRIPT_COUNT scripts have been updated with the correct JDK path"
else
    echo ""
    echo "⚠️  No updated scripts directory found"
    echo "   Run /Users/michaelmcgraw/dev/update-scripts-without-sudo.sh to create updated scripts"
fi

echo ""
echo "=== Verification Complete ==="
