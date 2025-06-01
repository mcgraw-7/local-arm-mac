#!/bin/zsh
# Add VA WebLogic Start Function to User Profile
# This script adds the va_start_weblogic() function to the user's .zshrc file

echo "=== Adding VA Start WebLogic Function ==="

# Define the function to add
VA_START_WEBLOGIC_FUNCTION='
# VA WebLogic Server start helper function with Oracle DB verification and Apple Silicon support
va_start_weblogic() {
    echo "Starting WebLogic server with environment verification..."
    
    # Check if running on Apple Silicon
    if [ "$(uname -m)" = "arm64" ]; then
        echo "Detected Apple Silicon Mac - setting required environment variables..."
        export BYPASS_CPU_CHECK=true
        export BYPASS_PREFLIGHT=true
        export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"
        
        # Run quick Apple Silicon compatibility check
        if [ -f "$HOME/dev/local-arm-mac/scripts/utils/check-apple-silicon.sh" ]; then
            echo "Running Apple Silicon compatibility check..."
            "$HOME/dev/local-arm-mac/scripts/utils/check-apple-silicon.sh"
        else
            # Fallback to basic check if script not available
            # Check if Colima is installed and running (for Oracle DB)
            if command -v colima &> /dev/null; then
                COLIMA_STATUS=$(colima status 2>&1)
                
                if [[ "$COLIMA_STATUS" == *"not running"* ]]; then
                    echo "⚠️  Warning: Colima is not running. Oracle database might not be accessible."
                    echo "Consider running: colima start -c 4 -m 12 -a x86_64"
                else
                    echo "✅ Colima is running"
                fi
            fi
        fi
    fi
    
    # Verify Oracle DB container is running before starting WebLogic
    echo "Verifying Oracle DB container status..."
    ORACLE_CONTAINER=$(docker ps 2>/dev/null | grep -i oracle | grep -i database)
    if [ -z "$ORACLE_CONTAINER" ]; then
        echo "⚠️  Warning: Oracle database container is NOT running"
        echo "This will cause issues with applications that require database access"
        echo "Consider starting Oracle DB first with: va_start_oracle_db"
        
        echo -n "Do you want to continue starting WebLogic anyway? (y/n): "
        read CONTINUE
        if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
            echo "WebLogic startup cancelled."
            return 1
        fi
    else
        echo "✅ Oracle database container is running"
    fi
    
    # Check if the repository exists
    if [ -f "$HOME/dev/local-arm-mac/scripts/weblogic/start-weblogic.sh" ]; then
        "$HOME/dev/local-arm-mac/scripts/weblogic/start-weblogic.sh"
    else
        echo "❌ ERROR: start-weblogic.sh script not found"
        echo "Please ensure you have the local-arm-mac repository in your ~/dev directory"
    fi
}

# Oracle DB container startup helper
va_start_oracle_db() {
    echo "Starting Oracle database container..."
    
    # Check if Docker is running
    if ! docker info &>/dev/null; then
        echo "❌ Docker is not running."
        
        # Check if on Apple Silicon and recommend Colima
        if [ "$(uname -m)" = "arm64" ]; then
            if command -v colima &> /dev/null; then
                echo "Detected Apple Silicon Mac. Starting Colima..."
                colima start -c 4 -m 12 -a x86_64
                
                if [ $? -ne 0 ]; then
                    echo "❌ Failed to start Colima. Cannot proceed."
                    return 1
                fi
            else
                echo "❌ Colima is required on Apple Silicon but not installed."
                echo "Please install Colima with: brew install colima"
                return 1
            fi
        else
            echo "Please start Docker Desktop first."
            return 1
        fi
    fi
    
    # Look for Oracle container
    ORACLE_CONTAINER=$(docker ps -a | grep -i oracle | grep -i database)
    if [ -n "$ORACLE_CONTAINER" ]; then
        CONTAINER_ID=$(echo "$ORACLE_CONTAINER" | awk "{ print \$1 }")
        
        # Check if already running
        RUNNING=$(docker ps | grep "$CONTAINER_ID")
        if [ -n "$RUNNING" ]; then
            echo "✅ Oracle database container is already running: $CONTAINER_ID"
        else
            echo "Starting stopped Oracle container: $CONTAINER_ID"
            docker start "$CONTAINER_ID"
            
            if [ $? -eq 0 ]; then
                echo "✅ Oracle database container started successfully"
                echo "The database may take a minute to fully initialize..."
            else
                echo "❌ Failed to start Oracle database container"
                return 1
            fi
        fi
    else
        echo "❌ No Oracle database container found"
        echo "Run Oracle database management script first: option 12 in setup.sh"
        return 1
    fi
}
'

# Check if function already exists in .zshrc
echo "Checking for existing va_start_weblogic() function in $HOME/.zshrc..."
if grep -q "va_start_weblogic()" "$HOME/.zshrc"; then
    echo "✅ va_start_weblogic() function already exists in .zshrc"
else
    # Add function to .zshrc
    echo "Adding va_start_weblogic() function to $HOME/.zshrc..."
    echo "$VA_START_WEBLOGIC_FUNCTION" >> "$HOME/.zshrc"
    echo "✅ Added va_start_weblogic() function to .zshrc"
    
    # Show what was added
    echo ""
    echo "Function added:"
    echo "${VA_START_WEBLOGIC_FUNCTION}" | sed 's/^/    /'
fi

echo ""
echo "=== Usage ==="
echo "To start WebLogic server, run:"
echo "  source ~/.zshrc   # To reload your shell configuration"
echo "  va_start_weblogic  # To start the WebLogic server"
