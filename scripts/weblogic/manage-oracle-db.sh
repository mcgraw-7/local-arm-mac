#!/bin/zsh
# Oracle Database Container Management Script
# Used to download, create, start, and manage Oracle DB container

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default Oracle database container name
CONTAINER_NAME="oracle-database"
ORACLE_IMAGE="oracledb19c/oracle.19.3.0-ee"
ORACLE_PORT="1521"

echo "${BLUE}====================================================${NC}"
echo "${BLUE}Oracle Database Container Management${NC}"
echo "${BLUE}====================================================${NC}"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "${RED}❌ Error: Docker is not installed or not in PATH${NC}"
    echo "Please install Docker Desktop and try again"
    exit 1
fi

# Check if Docker is running
if ! docker info &>/dev/null; then
    echo "${RED}❌ Docker is not running. Please start Docker Desktop first.${NC}"
    exit 1
fi

# Display menu
echo "Oracle Database Container Management Options:"
echo ""
echo "1. Check Oracle database container status"
echo "2. Download Oracle database image (only needed once)"
echo "3. Start existing Oracle database container"
echo "4. Create new Oracle database container"
echo "5. Stop Oracle database container"
echo "6. View Oracle database logs"
echo "7. Exit"
echo ""
echo -n "Select an option (1-7): "
read OPTION

case $OPTION in
    1)  # Check Oracle database container status
        echo "${BLUE}Checking Oracle database container status...${NC}"

        # On Apple Silicon, check Docker context
        if [ "$(uname -m)" = "arm64" ]; then
            DOCKER_CONTEXT=$(docker context show 2>/dev/null)
            if [ "$DOCKER_CONTEXT" != "colima" ]; then
                echo "${YELLOW}⚠️  Docker context is '$DOCKER_CONTEXT', but should be 'colima' for Apple Silicon!${NC}"
                echo "Run: docker context use colima"
            fi
        fi

        # Find any running container exposing port 1521
        ORACLE_CONTAINER=$(docker ps --filter 'publish=1521' --format '{{.ID}} {{.Names}} {{.Image}}')
        if [ -z "$ORACLE_CONTAINER" ]; then
            # Fallback: match common names
            ORACLE_CONTAINER=$(docker ps | grep -i -E 'oracle|database|vbms|oracledb')
        fi
        if [ -n "$ORACLE_CONTAINER" ]; then
            echo "${GREEN}✅ Oracle database container is running: ${NC}"
            echo "$ORACLE_CONTAINER"
            CONTAINER_ID=$(echo "$ORACLE_CONTAINER" | awk '{print $1}')
            echo ""
            echo "${BLUE}Container details:${NC}"
            docker inspect --format='{{.Name}} - {{.Config.Image}} - {{.State.Status}} - Started: {{.State.StartedAt}}' $CONTAINER_ID
            echo ""
            echo "${BLUE}Port mappings:${NC}"
            docker port $CONTAINER_ID
            # Check for readiness in logs
            DB_READY=$(docker logs $CONTAINER_ID 2>&1 | grep -c 'DATABASE IS READY TO USE')
            if [ "$DB_READY" -eq 0 ]; then
                echo "${YELLOW}⚠️  Database container is running but may not be ready yet.${NC}"
                echo "Check logs with: docker logs $CONTAINER_ID | grep -i 'ready'"
            else
                echo "${GREEN}✅ Database is ready to use${NC}"
            fi
        else
            echo "${RED}❌ No running Oracle database container found${NC}"
            
            # Check for stopped containers
            STOPPED_CONTAINER=$(docker ps -a | grep -i oracle | grep -i database)
            if [ -n "$STOPPED_CONTAINER" ]; then
                echo ""
                echo "${YELLOW}Found stopped Oracle database container:${NC}"
                echo "$STOPPED_CONTAINER"
                echo ""
                echo "To start this container, select option 3 from the menu."
            else
                echo ""
                echo "${YELLOW}No Oracle database container found (stopped or running)${NC}"
                echo "To create a new container, first download the image (option 2) if you haven't already,"
                echo "then create a new container (option 4)."
            fi
        fi
        ;;
        
    2)  # Download Oracle database image
        echo "${BLUE}Checking for existing Oracle database images...${NC}"
        
        ORACLE_IMAGES=$(docker images | grep -i "$ORACLE_IMAGE")
        if [ -n "$ORACLE_IMAGES" ]; then
            echo "${GREEN}✅ Oracle database image already downloaded:${NC}"
            echo "$ORACLE_IMAGES"
            echo ""
            echo "You don't need to download it again."
        else
            echo "${YELLOW}Oracle database image not found locally. Downloading...${NC}"
            echo "(This will only need to be done once and may take some time)"
            echo ""
            
            docker pull -a $ORACLE_IMAGE
            
            # Check if download was successful
            if [ $? -eq 0 ]; then
                echo "${GREEN}✅ Oracle database image downloaded successfully${NC}"
            else
                echo "${RED}❌ Failed to download Oracle database image${NC}"
                echo "Please check your internet connection and try again."
                exit 1
            fi
        fi
        ;;
        
    3)  # Start existing Oracle database container
        echo "${BLUE}Checking for stopped Oracle database containers...${NC}"
        
        STOPPED_CONTAINER=$(docker ps -a | grep -i oracle | grep -i database | grep -i exited)
        if [ -n "$STOPPED_CONTAINER" ]; then
            CONTAINER_ID=$(echo "$STOPPED_CONTAINER" | awk '{print $1}')
            echo "${YELLOW}Found stopped Oracle database container: $CONTAINER_ID${NC}"
            echo "Starting container..."
            
            docker start $CONTAINER_ID
            
            # Check if start was successful
            if [ $? -eq 0 ]; then
                echo "${GREEN}✅ Oracle database container started successfully${NC}"
                echo "Waiting for database to initialize..."
                echo "This may take 30-60 seconds..."
                sleep 10
                echo "${YELLOW}Database is initializing in the background.${NC}"
                echo "You can check container logs with option 6."
            else
                echo "${RED}❌ Failed to start Oracle database container${NC}"
            fi
        else
            echo "${RED}❌ No stopped Oracle database containers found${NC}"
            echo "To create a new container, select option 4 from the menu."
        fi
        ;;
        
    4)  # Create new Oracle database container
        echo "${BLUE}Creating new Oracle database container...${NC}"
        
        # First check if container already exists
        EXISTING_CONTAINER=$(docker ps -a | grep -i "$CONTAINER_NAME")
        if [ -n "$EXISTING_CONTAINER" ]; then
            echo "${YELLOW}A container named '$CONTAINER_NAME' already exists:${NC}"
            echo "$EXISTING_CONTAINER"
            echo ""
            echo "${YELLOW}Would you like to remove it and create a new one? (y/n):${NC} "
            read REMOVE
            
            if [[ "$REMOVE" =~ ^[Yy]$ ]]; then
                echo "Removing existing container..."
                docker rm -f $CONTAINER_NAME
            else
                echo "${YELLOW}Operation cancelled. The existing container was not modified.${NC}"
                exit 0
            fi
        fi
        
        # Check if the image exists
        ORACLE_IMAGES=$(docker images | grep -i "$ORACLE_IMAGE")
        if [ -z "$ORACLE_IMAGES" ]; then
            echo "${YELLOW}Oracle database image not found. Downloading first...${NC}"
            docker pull -a $ORACLE_IMAGE
            
            if [ $? -ne 0 ]; then
                echo "${RED}❌ Failed to download Oracle database image${NC}"
                exit 1
            fi
        fi
        
        # Create the container
        echo "Creating and starting new Oracle database container..."
        docker run -d --name $CONTAINER_NAME -p $ORACLE_PORT:1521 $ORACLE_IMAGE
        
        # Check if creation was successful
        if [ $? -eq 0 ]; then
            echo "${GREEN}✅ Oracle database container created and started${NC}"
            echo "Waiting for database to initialize..."
            echo "This may take several minutes for first startup..."
            echo ""
            echo "${YELLOW}Database is initializing in the background.${NC}"
            echo "You can check container logs with option 6."
        else
            echo "${RED}❌ Failed to create Oracle database container${NC}"
        fi
        ;;
        
    5)  # Stop Oracle database container
        echo "${BLUE}Checking for running Oracle database containers...${NC}"
        
        RUNNING_CONTAINER=$(docker ps | grep -i oracle | grep -i database)
        if [ -n "$RUNNING_CONTAINER" ]; then
            CONTAINER_ID=$(echo "$RUNNING_CONTAINER" | awk '{print $1}')
            echo "${YELLOW}Found running Oracle database container: $CONTAINER_ID${NC}"
            echo "${RED}Warning: Stopping the container will interrupt any active database connections${NC}"
            echo "Are you sure you want to stop it? (y/n): "
            read STOP
            
            if [[ "$STOP" =~ ^[Yy]$ ]]; then
                echo "Stopping container..."
                docker stop $CONTAINER_ID
                
                # Check if stop was successful
                if [ $? -eq 0 ]; then
                    echo "${GREEN}✅ Oracle database container stopped successfully${NC}"
                else
                    echo "${RED}❌ Failed to stop Oracle database container${NC}"
                fi
            else
                echo "${YELLOW}Operation cancelled. The container continues to run.${NC}"
            fi
        else
            echo "${RED}❌ No running Oracle database containers found${NC}"
        fi
        ;;
        
    6)  # View Oracle database logs
        echo "${BLUE}Checking for Oracle database containers...${NC}"
        
        CONTAINER=$(docker ps -a | grep -i oracle | grep -i database)
        if [ -n "$CONTAINER" ]; then
            CONTAINER_ID=$(echo "$CONTAINER" | awk '{print $1}')
            echo "${YELLOW}Found Oracle database container: $CONTAINER_ID${NC}"
            echo "Last 50 log lines:"
            echo "${BLUE}---------------------------------------------------${NC}"
            docker logs --tail 50 $CONTAINER_ID
            echo "${BLUE}---------------------------------------------------${NC}"
            echo ""
            echo "To follow logs in real-time, use this command:"
            echo "docker logs -f $CONTAINER_ID"
        else
            echo "${RED}❌ No Oracle database containers found${NC}"
        fi
        ;;
        
    7)  # Exit
        echo "${YELLOW}Exiting Oracle database management${NC}"
        exit 0
        ;;
        
    *)  # Invalid option
        echo "${RED}❌ Invalid option. Please try again.${NC}"
        exit 1
        ;;
esac

echo ""
echo "${BLUE}====================================================${NC}"
echo "${GREEN}Operation complete${NC}"
echo "${BLUE}====================================================${NC}"
