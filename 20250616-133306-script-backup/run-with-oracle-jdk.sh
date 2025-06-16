#!/bin/zsh
# Run a command using Oracle JDK 1.8.0_45

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command> [arguments]"
    echo "Runs the specified command with Oracle JDK 1.8.0_45"
    exit 1
fi

# Setup environment
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Apple Silicon Mac specific settings
export BYPASS_CPU_CHECK=true
export BYPASS_PREFLIGHT=true
export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"

# Run the command
echo "Running with Oracle JDK 1.8.0_45:"
java -version
echo "------------------------------"
"$@"
