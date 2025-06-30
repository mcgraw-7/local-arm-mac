#!/bin/zsh
# Add VA WebLogic Start Function to User Profile
# This script adds the va_start_weblogic() function to the user's .zshrc file

echo "=== Adding VA Start WebLogic Function ==="

# Create a temporary file for the new content
TEMP_FILE=$(mktemp)

# Check if function already exists
if grep -q "va_start_weblogic()" ~/.zshrc; then
    echo "Checking for existing va_start_weblogic() function in ~/.zshrc..."
    echo "Function already exists. Updating with latest version..."
    # Remove existing function
    sed '/va_start_weblogic()/,/^}/d' ~/.zshrc > "$TEMP_FILE"
    mv "$TEMP_FILE" ~/.zshrc
fi

# Add the updated function
echo "Adding va_start_weblogic() function to ~/.zshrc..."

cat >> ~/.zshrc << 'EOF'

# VA WebLogic Server start helper function
va_start_weblogic() {
    echo "Starting WebLogic server with environment verification..."
    
    # Check if running on Apple Silicon
    if [ "$(uname -m)" = "arm64" ]; then
        echo "Detected Apple Silicon Mac - setting required environment variables..."
        export BYPASS_CPU_CHECK=true
        export BYPASS_PREFLIGHT=true
        export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"
    fi
    
    # Verify Oracle DB container is running before starting WebLogic
    echo "Verifying Oracle DB container status..."
    
    # Simple, direct check for the container
    if docker ps | grep -q "vbms-dev-docker-19c"; then
        echo "✅ Oracle database container is running"
    else
        echo "⚠️  Warning: Oracle database container is NOT running"
        echo "This will cause issues with applications that require database access"
        echo "Consider starting Oracle DB first with: va_start_oracle_db"
        
        echo -n "Do you want to continue starting WebLogic anyway? (y/n): "
        read CONTINUE
        if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
            echo "WebLogic startup cancelled."
            return 1
        fi
    fi
    
    # Check if the repository exists
    if [ -f "$HOME/dev/local-arm-mac/scripts/weblogic/start-weblogic.sh" ]; then
        "$HOME/dev/local-arm-mac/scripts/weblogic/start-weblogic.sh"
    else
        echo "❌ ERROR: start-weblogic.sh script not found"
        echo "Please ensure you have the local-arm-mac repository in your ~/dev directory"
        return 1
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
    if docker ps | grep -q "vbms-dev-docker-19c"; then
        echo "✅ Oracle database container is already running"
    else
        # Check if container exists but is stopped
        CONTAINER_ID=$(docker ps -a | grep "vbms-dev-docker-19c" | awk '{print $1}')
        if [ -n "$CONTAINER_ID" ]; then
            echo "Starting stopped Oracle container: $CONTAINER_ID"
            docker start "$CONTAINER_ID"
            
            if [ $? -eq 0 ]; then
                echo "✅ Oracle database container started successfully"
                echo "The database may take a minute to fully initialize..."
                echo "You can check the container logs with: docker logs $CONTAINER_ID"
            else
                echo "❌ Failed to start Oracle database container"
                return 1
        fi
    else
        echo "❌ No Oracle database container found"
            echo "You need to create an Oracle database container first."
            echo "Options:"
            echo "1. Run Oracle database management script:"
            echo "   $HOME/dev/local-arm-mac/scripts/weblogic/manage-oracle-db.sh"
            echo "2. Or pull and run the official Oracle image:"
            echo "   docker pull oracledb19c/oracle.19.3.0-ee"
            echo "   docker run -d --name vbms-dev-docker-19c -p 1521:1521 oracledb19c/oracle.19.3.0-ee"
        return 1
    fi
    fi
}

EOF

    echo "✅ Added va_start_weblogic() function to .zshrc"
    
echo "\n=== Usage ==="
echo "To start WebLogic server, run:"
echo "  source ~/.zshrc   # To reload your shell configuration"
echo "  va_start_oracle_db  # To start the Oracle database (if needed)"
echo "  va_start_weblogic   # To start the WebLogic server"
echo "\nSetup completed!" 