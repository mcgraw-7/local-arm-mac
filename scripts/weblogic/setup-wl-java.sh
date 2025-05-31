#!/bin/zsh
# Simple WebLogic Java Environment Setup (No Sudo Required)
# This script creates a .wljava_env file in your home directory that can be sourced before running WebLogic

ORACLE_JDK="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"
ENV_FILE="${HOME}/.wljava_env"

echo "=== Setting up WebLogic Java environment ==="

# Check if Oracle JDK exists
if [ ! -d "$ORACLE_JDK" ]; then
    echo "ERROR: Oracle JDK not found at $ORACLE_JDK"
    echo "Cannot continue without the required JDK"
    exit 1
fi

# Create environment file
cat > "$ENV_FILE" << EOF
# WebLogic Java Environment Configuration
# Source this file before running WebLogic commands
export JAVA_HOME="$ORACLE_JDK"
export PATH="\$JAVA_HOME/bin:\$PATH"

# WebLogic specific variables
export ORACLE_HOME="\${HOME}/dev/Oracle/Middleware/Oracle_Home"
export WL_HOME="\${ORACLE_HOME}/wlserver"
export DOMAIN_HOME="\${ORACLE_HOME}/user_projects/domains/P2-DEV"

# Apple Silicon Mac specific settings
export BYPASS_CPU_CHECK=true
export BYPASS_PREFLIGHT=true
export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"

echo "=== WebLogic Java Environment Activated ==="
echo "Using Oracle JDK: \$JAVA_HOME"
java -version
EOF

chmod +x "$ENV_FILE"

echo "✅ Created WebLogic Java environment file at $ENV_FILE"

# Update .zshrc to include a wl_java function
if ! grep -q "wl_java()" "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" << EOF

# WebLogic Java environment helper function
wl_java() {
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
        echo "WebLogic Java environment activated"
    else
        echo "ERROR: WebLogic Java environment file not found"
    fi
}
EOF
    echo "✅ Added wl_java() function to your .zshrc"
else
    echo "ℹ️ wl_java() function already exists in .zshrc"
fi

# Create a simple script to run WebLogic commands with the right Java
cat > "${HOME}/dev/run-with-oracle-jdk.sh" << EOF
#!/bin/zsh
# Run a command using Oracle JDK 1.8.0_45

if [ \$# -eq 0 ]; then
    echo "Usage: \$0 <command> [arguments]"
    echo "Runs the specified command with Oracle JDK 1.8.0_45"
    exit 1
fi

# Setup environment
export JAVA_HOME="$ORACLE_JDK"
export PATH="\$JAVA_HOME/bin:\$PATH"

# Apple Silicon Mac specific settings
export BYPASS_CPU_CHECK=true
export BYPASS_PREFLIGHT=true
export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"

# Run the command
echo "Running with Oracle JDK 1.8.0_45:"
java -version
echo "------------------------------"
"\$@"
EOF

chmod +x "${HOME}/dev/run-with-oracle-jdk.sh"
echo "✅ Created ${HOME}/dev/run-with-oracle-jdk.sh script"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To use the Oracle JDK for WebLogic development:"
echo ""
echo "1. In any new terminal session, run:"
echo "   source $ENV_FILE"
echo ""
echo "2. Or use the function added to your .zshrc:"
echo "   wl_java"
echo ""
echo "3. To run a specific command with Oracle JDK:"
echo "   ~/dev/run-with-oracle-jdk.sh [command]"
echo ""
echo "4. To make these changes active in the current terminal:"
echo "   source ~/.zshrc"
echo "   source $ENV_FILE"
