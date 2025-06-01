#!/bin/zsh
# Script to check and set up Apple Silicon compatibility for Oracle and WebLogic

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}====================================================${NC}"
echo "${BLUE}Apple Silicon Compatibility Check${NC}"
echo "${BLUE}====================================================${NC}"

# Check if running on Apple Silicon
if [ "$(uname -m)" != "arm64" ]; then
    echo "${YELLOW}Not running on Apple Silicon. This script is intended for Apple Silicon Macs.${NC}"
    exit 0
fi

echo "${GREEN}✅ Detected Apple Silicon Mac (arm64)${NC}"

# Check for Homebrew
echo ""
echo "${BLUE}Checking for Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo "${RED}❌ Homebrew is not installed${NC}"
    echo "Homebrew is recommended for installing required tools on macOS"
    echo "Install Homebrew with:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
else
    echo "${GREEN}✅ Homebrew is installed${NC}"
fi

# Check for Colima
echo ""
echo "${BLUE}Checking for Colima...${NC}"
if ! command -v colima &> /dev/null; then
    echo "${RED}❌ Colima is not installed${NC}"
    echo "Colima is required for running Oracle database on Apple Silicon"
    echo "You can install Colima with: brew install colima"
    COLIMA_MISSING=true
else
    echo "${GREEN}✅ Colima is installed${NC}"
    
    # Check Colima status
    echo ""
    echo "${BLUE}Checking Colima status...${NC}"
    if ! colima status 2>/dev/null | grep -q "Running"; then
        echo "${RED}❌ Colima is not running${NC}"
        echo "${YELLOW}Would you like to start Colima with recommended settings for Oracle? (y/n):${NC} "
        read START_COLIMA
        
        if [[ "$START_COLIMA" =~ ^[Yy]$ ]]; then
            echo "Starting Colima with recommended settings..."
            colima start -c 4 -m 12 -a x86_64
            
            # Check if start was successful
            if [ $? -eq 0 ]; then
                echo "${GREEN}✅ Colima started successfully${NC}"
            else
                echo "${RED}❌ Failed to start Colima${NC}"
            fi
        else
            echo "You can start Colima manually with:"
            echo "colima start -c 4 -m 12 -a x86_64"
        fi
    else
        echo "${GREEN}✅ Colima is running${NC}"
        
        # Check Colima architecture
        if colima status 2>/dev/null | grep -q "x86_64"; then
            echo "${GREEN}✅ Colima is running with x86_64 architecture (good for Oracle)${NC}"
        else
            echo "${RED}⚠️  Warning: Colima might not be running with x86_64 architecture${NC}"
            echo "Oracle database requires x86_64 architecture on Apple Silicon"
            echo "Consider restarting Colima with:"
            echo "colima stop && colima start -c 4 -m 12 -a x86_64"
        fi
    fi
fi

# Check for Docker
echo ""
echo "${BLUE}Checking for Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo "${RED}❌ Docker is not installed${NC}"
    echo "Docker is required for running Oracle database"
    echo "With Colima, Docker CLI should be installed separately:"
    echo "brew install docker"
else
    echo "${GREEN}✅ Docker is installed${NC}"
    
    # Check if Docker can connect to engine
    if docker info &>/dev/null; then
        echo "${GREEN}✅ Docker is working correctly${NC}"
    else
        echo "${RED}❌ Docker is not working correctly${NC}"
        if [ -n "$COLIMA_MISSING" ]; then
            echo "This is expected since Colima is not installed/running"
        else
            echo "Make sure Colima is running properly"
            echo "You might need to set the DOCKER_HOST environment variable"
        fi
    fi
fi

# Check for Rosetta 2
echo ""
echo "${BLUE}Checking for Rosetta 2...${NC}"
if /usr/bin/pgrep -q oahd; then
    echo "${GREEN}✅ Rosetta 2 is installed${NC}"
else
    echo "${YELLOW}⚠️  Rosetta 2 might not be installed${NC}"
    echo "Rosetta 2 is recommended for running x86_64 applications on Apple Silicon"
    echo "You can install Rosetta 2 with:"
    echo "softwareupdate --install-rosetta"
fi

# Oracle JDK check for arm64 compatibility
echo ""
echo "${BLUE}Checking for Oracle JDK compatibility...${NC}"

# Check for standard Oracle JDK location
ORACLE_JDK_PATH="${HOME}/dev/Oracle/jdk1.8.0_45"
if [ -d "$ORACLE_JDK_PATH" ]; then
    echo "${GREEN}✅ Found Oracle JDK at expected location: ${ORACLE_JDK_PATH}${NC}"
    
    # Check architecture compatibility
    if file "$ORACLE_JDK_PATH/bin/java" | grep -q "x86_64"; then
        echo "${YELLOW}⚠️  This is an x86_64 JDK running through Rosetta 2${NC}"
        echo "This should work but might have performance implications"
    fi
else
    echo "${YELLOW}⚠️  Oracle JDK not found at standard location: ${ORACLE_JDK_PATH}${NC}"
    echo "Make sure Oracle JDK is installed correctly"
fi

# Summary
echo ""
echo "${BLUE}====================================================${NC}"
echo "${BLUE}Compatibility Check Summary${NC}"
echo "${BLUE}====================================================${NC}"

echo "For optimal WebLogic and Oracle Database setup on Apple Silicon:"
echo ""
echo "1. Use Colima with x86_64 architecture for Oracle Database"
echo "   colima start -c 4 -m 12 -a x86_64"
echo ""
echo "2. Make sure Docker uses the --platform flag for Oracle images"
echo "   docker run --platform linux/amd64 ..."
echo ""
echo "3. Oracle JDK 1.8.0_45 will run via Rosetta 2 automatically"
echo ""
echo "4. For WebLogic domain creation, use the standardized scripts"
echo "   They contain the necessary fixes for Apple Silicon compatibility"
echo ""
echo "5. When issues occur, check if Colima is running correctly first"
echo "${BLUE}====================================================${NC}"
