#!/bin/zsh
# Java Environment Configuration for Limited Access Users
# This script configures the Java environment for WebLogic without requiring sudo access

# Standard Oracle JDK path
JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"

echo "=== Java Environment Configuration (Limited Access) ==="

# Check if Oracle JDK exists
if [ ! -d "$JDK_PATH" ]; then
    echo "❌ ERROR: Required Oracle JDK not found at $JDK_PATH"
    echo "Please contact your system administrator to ensure jdk1.8.0_202.jdk is properly installed."
    exit 1
fi

echo "✅ Oracle JDK found at $JDK_PATH"

# Create a local wrapper script for Java
LOCAL_JAVA_DIR="$HOME/dev/java-wrapper"
mkdir -p "$LOCAL_JAVA_DIR/bin"

# Create Java wrapper script that points to Oracle JDK
cat > "$LOCAL_JAVA_DIR/bin/java" << EOF
#!/bin/zsh
export JAVA_HOME="$JDK_PATH"
"$JDK_PATH/bin/java" "\$@"
EOF

# Create javac wrapper
cat > "$LOCAL_JAVA_DIR/bin/javac" << EOF
#!/bin/zsh
export JAVA_HOME="$JDK_PATH"
"$JDK_PATH/bin/javac" "\$@"
EOF

# Create other common wrapper scripts
for cmd in jar javadoc javap jdb keytool; do
    cat > "$LOCAL_JAVA_DIR/bin/$cmd" << EOF
#!/bin/zsh
export JAVA_HOME="$JDK_PATH"
"$JDK_PATH/bin/$cmd" "\$@"
EOF
    chmod +x "$LOCAL_JAVA_DIR/bin/$cmd"
done

# Make all wrapper scripts executable
chmod +x "$LOCAL_JAVA_DIR/bin/"*

echo "✅ Created Java wrapper scripts in $LOCAL_JAVA_DIR/bin"

# Update .zshrc file with PATH to our wrapper scripts
ZSHRC_FILE="$HOME/.zshrc"

echo "Updating $ZSHRC_FILE with Java environment settings..."

# Remove any existing JAVA_HOME settings
if grep -q "export JAVA_HOME=" "$ZSHRC_FILE"; then
    echo "Removing existing JAVA_HOME settings..."
    sed -i '' '/export JAVA_HOME=/d' "$ZSHRC_FILE"
fi

# Add our configuration to .zshrc
cat >> "$ZSHRC_FILE" << EOF

# Oracle JDK Configuration for WebLogic Development
export JAVA_HOME="$JDK_PATH"
export PATH="$LOCAL_JAVA_DIR/bin:\$JAVA_HOME/bin:\$PATH"
# WebLogic specific Java settings for Apple Silicon Mac
export BYPASS_CPU_CHECK=true
export BYPASS_PREFLIGHT=true
EOF

echo "✅ Updated $ZSHRC_FILE"

# Create helper script to reset Java version temporarily
cat > "$LOCAL_JAVA_DIR/reset-java-version.sh" << EOF
#!/bin/zsh
# This script temporarily resets the Java version to system default
# Use with caution and only when you need to use a different Java version

export PATH=\$(echo "\$PATH" | sed "s|$LOCAL_JAVA_DIR/bin:||g")
export PATH=\$(echo "\$PATH" | sed "s|$JDK_PATH/bin:||g")
unset JAVA_HOME

echo "Java path temporarily reset to system default"
echo "Current Java version:"
java -version
echo ""
echo "Note: This change is only effective in the current terminal session"
echo "Open a new terminal to restore the WebLogic Java environment"
EOF

chmod +x "$LOCAL_JAVA_DIR/reset-java-version.sh"

echo "✅ Created reset script at $LOCAL_JAVA_DIR/reset-java-version.sh"

# Verify Java version
echo ""
echo "Verifying Java version:"
"$LOCAL_JAVA_DIR/bin/java" -version

echo ""
echo "=== Configuration Complete ==="
echo ""
echo "Please run 'source ~/.zshrc' or open a new terminal for changes to take effect."
echo ""
echo "Your WebLogic development will now use Oracle JDK 1.8.0_45"
echo "If you temporarily need to use a different JDK, run: $LOCAL_JAVA_DIR/reset-java-version.sh"
