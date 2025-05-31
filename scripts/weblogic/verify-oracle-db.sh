#!/bin/zsh
# Script to verify WebLogic domain configuration with Oracle Database

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

# Check if WebLogic domain exists
if [ ! -f "${DOMAIN_HOME}/config/config.xml" ]; then
    echo "❌ WebLogic domain not found at: ${DOMAIN_HOME}"
    echo "Please create the domain first using create-domain-m3.sh"
    exit 1
fi

# Check Oracle DB container running status
echo "Checking Oracle database container status..."
ORACLE_CONTAINER=$(docker ps | grep -i oracle | grep -i database)
if [ -z "$ORACLE_CONTAINER" ]; then
    echo "❌ Oracle database container is NOT running"
    echo "This will cause issues with VBMS applications that require database access"
    
    # Check if container exists but is stopped
    STOPPED_CONTAINER=$(docker ps -a | grep -i oracle | grep -i database)
    if [ -n "$STOPPED_CONTAINER" ]; then
        echo "Found stopped Oracle database container:"
        echo "$STOPPED_CONTAINER"
        echo ""
        echo "To start it, run: docker start $(echo "$STOPPED_CONTAINER" | awk '{print $1}')"
        CONTAINER_NAME=$(echo "$STOPPED_CONTAINER" | awk '{print $1}')
    else
        echo "No Oracle database container found. You may need to create one."
    fi
    
    read -p "Would you like to start the Oracle database container now? (y/n): " START_DB
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
            ORACLE_IMAGES=$(docker images | grep -i oracle)
            if [ -n "$ORACLE_IMAGES" ]; then
                echo "Found Oracle images:"
                echo "$ORACLE_IMAGES"
                echo ""
                echo "Please run the appropriate docker run command to start a container"
            else
                echo "❌ No Oracle database images found. Please obtain an appropriate Oracle database image."
            fi
        fi
    fi
else
    echo "✅ Oracle database container is running: $ORACLE_CONTAINER"
    
    # Get container port mappings
    CONTAINER_ID=$(echo "$ORACLE_CONTAINER" | awk '{print $1}')
    PORT_MAPPINGS=$(docker port "$CONTAINER_ID")
    echo "Database port mappings:"
    echo "$PORT_MAPPINGS"
fi

# Check if WebLogic has JDBC data sources configured
echo ""
echo "Checking WebLogic JDBC configuration..."
if [ -d "${DOMAIN_HOME}/config/jdbc" ]; then
    JDBC_FILES=$(ls -1 "${DOMAIN_HOME}/config/jdbc")
    if [ -n "$JDBC_FILES" ]; then
        echo "✅ JDBC configurations found:"
        echo "$JDBC_FILES"
    else
        echo "❌ No JDBC configurations found in domain"
        echo "Your applications might not be able to connect to the database"
    fi
else
    echo "❌ No JDBC configuration directory found"
    echo "Your domain might not be configured to use databases"
fi

echo ""
echo "====================================================="
echo "WebLogic Database Verification Complete"
echo "====================================================="
