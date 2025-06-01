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
                echo "❌ No Oracle database images found."
                echo "You only need to download the image once with:"
                echo "docker pull -a oracledb19c/oracle.19.3.0-ee"
                echo ""
                echo "After downloading, you can create and start a container with:"
                echo "docker run -d --name oracle-database -p 1521:1521 oracledb19c/oracle.19.3.0-ee"
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
