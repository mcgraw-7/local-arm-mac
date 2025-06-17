#!/bin/zsh
# Script to verify WebLogic domain configuration with Oracle Database
# Updated June 4, 2025 - Fixed container detection for vbms-dev-docker-19c

ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
DOMAIN_HOME="${ORACLE_HOME}/user_projects/domains/P2-DEV"

echo "====================================================="
echo "WebLogic Domain Oracle DB Verification"
echo "====================================================="

# Check if Docker is running
if ! docker info &>/dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

# Check if running on Apple Silicon and Colima is installed/running
if [ "$(uname -m)" = "arm64" ]; then
    echo "Detected Apple Silicon Mac"
    
    # Check for Colima
    if ! command -v colima &> /dev/null; then
        echo "❌ Colima is not installed, which is required for Oracle on Apple Silicon"
        echo "Please follow the installation guide at:"
        echo "https://github.com/department-of-veterans-affairs/bip-developer-guides/wiki/Oracle-Database-On-M-Series-Macs"
        echo ""
        echo "You can install Colima with: brew install colima"
        exit 1
    fi
    
    # Check if Colima is running - simpler approach
    COLIMA_STATUS=$(colima status 2>&1)
    
    if [[ "$COLIMA_STATUS" == *"not running"* ]]; then
        echo "❌ Colima is not running. Oracle database requires Colima on Apple Silicon."
        echo "Run this command to start Colima with the correct settings:"
        echo "colima start -c 4 -m 12 -a x86_64"
        exit 1
    else
        echo "✅ Colima is running, continuing with verification"
    fi
fi

# Check if WebLogic domain exists
if [ ! -f "${DOMAIN_HOME}/config/config.xml" ]; then
    echo "❌ WebLogic domain not found at: ${DOMAIN_HOME}"
    echo "Please create the domain first using create-domain-m3.sh"
    echo "WebLogic must be installed in the Oracle standardized directory: ${ORACLE_HOME}"
    exit 1
fi

# Check Oracle DB container running status
# Updated pattern to detect Oracle DB containers
echo "Checking Oracle database container status..."
if [ "$(uname -m)" = "arm64" ]; then
    DOCKER_CONTEXT=$(docker context show 2>/dev/null)
    if [ "$DOCKER_CONTEXT" != "colima" ]; then
        echo "⚠️  Docker context is '$DOCKER_CONTEXT', but should be 'colima' for Apple Silicon!"
        echo "Run: docker context use colima"
    fi
fi
# Find any running container exposing port 1521
ORACLE_CONTAINER=$(docker ps --filter 'publish=1521' --format '{{.ID}} {{.Names}} {{.Image}}')
if [ -z "$ORACLE_CONTAINER" ]; then
    # Fallback: match common names
    ORACLE_CONTAINER=$(docker ps | grep -i -E 'oracle|database|vbms|oracledb')
fi
if [ -z "$ORACLE_CONTAINER" ]; then
    echo "❌ Oracle database container is NOT running"
    echo "This will cause issues with VBMS applications that require database access"
    
    # Check if container exists but is stopped
    STOPPED_CONTAINER=$(docker ps -a | grep -i -E 'oracle|vbms')
    if [ -n "$STOPPED_CONTAINER" ]; then
        echo "Found stopped Oracle database container:"
        echo "$STOPPED_CONTAINER"
        echo ""
        CONTAINER_NAME=$(echo "$STOPPED_CONTAINER" | awk '{print $NF}')
        echo "To start it, run: docker start $CONTAINER_NAME"
    else
        echo "No Oracle database container found. You may need to create one."
    fi
    
    echo -n "Would you like to start the Oracle database container now? (y/n): "
    read START_DB
    if [[ "$START_DB" =~ ^[Yy]$ ]]; then
        if [ -n "$CONTAINER_NAME" ]; then
            echo "Starting container: $CONTAINER_NAME"
            docker start "$CONTAINER_NAME"
            
            # Check if it started successfully
            sleep 5
            if docker ps | grep -q "$CONTAINER_NAME"; then
                echo "✅ Successfully started Oracle database container"
            else
                echo "❌ Failed to start Oracle database container"
            fi
        else
            echo "No existing container to start. Looking for Oracle database images..."
            
            # Check for Oracle database images
            ORACLE_IMAGES=$(docker images | grep -i -E 'oracle|oracledb|vbms')
            if [ -n "$ORACLE_IMAGES" ]; then
                echo "Found Oracle images:"
                echo "$ORACLE_IMAGES"
                echo ""
                echo "Please run the appropriate docker run command to start a container"
            else
                echo "❌ No Oracle database images found."
                echo "You need to download the official Oracle Database image."
                echo ""
                echo "After downloading, you can create and start a container with:"
                echo "docker run -d --name vbms-dev-docker-19c -p 1521:1521 <oracle_image_name>"
            fi
        fi
    fi
else
    echo "✅ Oracle database container is running:"
    echo "$ORACLE_CONTAINER"
    CONTAINER_ID=$(echo "$ORACLE_CONTAINER" | awk '{print $1}')
    PORT_MAPPINGS=$(docker port "$CONTAINER_ID")
    echo "Database port mappings:"
    echo "$PORT_MAPPINGS"
    # Check for readiness in logs
    DB_READY=$(docker logs $CONTAINER_ID 2>&1 | grep -c 'DATABASE IS READY TO USE')
    if [ "$DB_READY" -eq 0 ]; then
        echo "⚠️  Database container is running but may not be ready yet."
        echo "Check logs with: docker logs $CONTAINER_ID | grep -i 'ready'"
    else
        echo "✅ Database is ready to use"
    fi
fi

# Check if WebLogic has JDBC data sources configured
echo ""
echo "Checking WebLogic JDBC configuration..."
if [ -d "${DOMAIN_HOME}/config/jdbc" ]; then
    JDBC_FILES=$(ls -1 "${DOMAIN_HOME}/config/jdbc" 2>/dev/null)
    if [ -n "$JDBC_FILES" ] && ! grep -q "readme" <<< "$JDBC_FILES"; then
        echo "✅ JDBC configurations found:"
        echo "$JDBC_FILES"
    else
        echo "❌ No valid JDBC configurations found"
        echo "Found a readme.txt file, but no actual JDBC connection files"
        echo "You need to configure JDBC data sources for your applications"
        echo ""
        echo "To create JDBC data sources for WebLogic:"
        echo "1. Make sure WebLogic Admin Server is running"
        echo "2. Use the provided script: ${HOME}/dev/configure-jdbc.sh"
        echo "   OR"
        echo "3. Configure manually in WebLogic Admin Console"
        echo "   - Access at: http://localhost:7001/console"
        echo "   - Navigate to Services > Data Sources > New"
    fi
else
    echo "❌ No JDBC configuration directory found"
    echo "Your domain might not be configured to use databases"
fi

echo ""
echo "====================================================="
echo "WebLogic Database Verification Complete"
echo "====================================================="