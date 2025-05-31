#!/bin/zsh
# WebLogic-specific Java Environment Configuration
# This script applies WebLogic-specific Java environment settings

# Standard Oracle JDK path
JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"

# Export required environment variables
export JAVA_HOME="$JDK_PATH"
export PATH="$JAVA_HOME/bin:$PATH"

# WebLogic-specific environment variables
export ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
export WL_HOME="${ORACLE_HOME}/wlserver"
export DOMAIN_HOME="${ORACLE_HOME}/user_projects/domains/P2-DEV"
export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"

# Apple Silicon Mac specific environment variables
if [ "$(uname -m)" = "arm64" ]; then
    export BYPASS_CPU_CHECK=true
    export BYPASS_PREFLIGHT=true
fi

# Display current Java environment
echo "=== WebLogic Java Environment ==="
echo "JAVA_HOME: $JAVA_HOME"
echo "ORACLE_HOME: $ORACLE_HOME"
echo "WL_HOME: $WL_HOME"
echo "DOMAIN_HOME: $DOMAIN_HOME"
echo "Java Version:"
java -version
echo "=== Environment Setup Complete ==="

# Execute command with the correct environment if provided
if [ $# -gt 0 ]; then
    echo "Executing: $@"
    "$@"
fi
