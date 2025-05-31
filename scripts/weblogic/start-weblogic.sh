#!/bin/zsh
# WebLogic Start Script with Oracle DB Container Check
# This script starts the WebLogic server after ensuring the Oracle DB container is running

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in PATH"
    echo "Please install Docker Desktop and try again"
    exit 1
fi

# Check if Oracle DB container is running
ORACLE_CONTAINER=$(docker ps | grep -i oracle | grep -i database)
if [ -z "$ORACLE_CONTAINER" ]; then
    echo "❌ WARNING: Oracle database container is not running!"
    echo "The Oracle database is required for WebLogic domain creation and operation."
    
    read -p "Do you want to start the Oracle database container now? (y/n): " START_DB
    if [[ "$START_DB" =~ ^[Yy]$ ]]; then
        echo "Starting Oracle database container..."
        # You may need to adjust this command based on your specific Oracle DB container setup
        # This is a generic example
        docker start oracle-database || docker run -d --name oracle-database -p 1521:1521 oracle/database:latest
        
        echo "Waiting 30 seconds for database to initialize..."
        sleep 30
    else
        echo "⚠️ Proceeding without Oracle database. Some WebLogic features may not work properly."
    fi
else
    echo "✅ Oracle database container is running: $ORACLE_CONTAINER"
fi

# Source the WebLogic environment
if [ -f "$HOME/.wljava_env" ]; then
    source "$HOME/.wljava_env"
    echo "✅ WebLogic Java environment activated"
else
    echo "❌ ERROR: WebLogic environment file not found at $HOME/.wljava_env"
    echo "Please run the WebLogic environment setup first: ./setup.sh and choose option 2"
    exit 1
fi

# Get the WebLogic domain home directory
DOMAIN_HOME="${DOMAIN_HOME:-"$ORACLE_HOME/user_projects/domains/P2-DEV"}"

# Check if the domain exists
if [ ! -d "$DOMAIN_HOME" ]; then
    echo "❌ ERROR: WebLogic domain not found at $DOMAIN_HOME"
    echo "Please create a WebLogic domain first using the domain creation script"
    exit 1
fi

# Check for the startWebLogic script
START_SCRIPT="$DOMAIN_HOME/bin/startWebLogic.sh"
if [ ! -f "$START_SCRIPT" ]; then
    echo "❌ ERROR: startWebLogic.sh not found at $START_SCRIPT"
    exit 1
fi

# Start WebLogic
echo "Starting WebLogic Server..."
echo "Domain: $DOMAIN_HOME"
echo "Using JAVA_HOME: $JAVA_HOME"

# Set necessary environment variables for Apple Silicon Macs
if [ "$(uname -m)" = "arm64" ]; then
    export BYPASS_CPU_CHECK=true
    export BYPASS_PREFLIGHT=true
    export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"
fi

# Run the WebLogic start script
nohup "$START_SCRIPT" > "$HOME/weblogic-startup-$(date +%Y%m%d-%H%M%S).log" 2>&1 &

echo "✅ WebLogic startup initiated. Server will be available at: http://localhost:7001/console"
echo "Username: weblogic"
echo "Password: welcome1 (if using the default configuration)"
echo ""
echo "Startup log: $HOME/weblogic-startup-$(date +%Y%m%d-%H%M%S).log"
