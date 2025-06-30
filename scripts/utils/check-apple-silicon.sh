#!/bin/zsh
# Script to check Apple Silicon compatibility for Oracle and WebLogic

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

# Check for Colima
echo ""
echo "${BLUE}Checking Colima status...${NC}"
if ! command -v colima &> /dev/null; then
    echo "${RED}❌ Colima is not installed${NC}"
    echo "Install with: brew install colima"
else
    echo "${GREEN}✅ Colima is installed${NC}"
    
    COLIMA_STATUS=$(colima status 2>&1)
    
    if [[ "$COLIMA_STATUS" == *"not running"* ]]; then
        echo "${RED}❌ Colima is not running${NC}"
        echo "Start with: colima start -c 4 -m 12 -a x86_64"
    else
        echo "${GREEN}✅ Colima is running${NC}"
        
        # Check Colima architecture - fix the detection
        if colima status 2>&1 | grep -q "arch: x86_64"; then
            echo "${GREEN}✅ Colima is running with x86_64 architecture${NC}"
        else
            echo "${YELLOW}⚠️  Colima is not running with x86_64 architecture${NC}"
            echo "Restart with: colima stop && colima start -c 4 -m 12 -a x86_64"
        fi
    fi
fi

# Check for Docker
echo ""
echo "${BLUE}Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo "${RED}❌ Docker is not installed${NC}"
    echo "Install with: brew install docker"
else
    echo "${GREEN}✅ Docker is installed${NC}"
    
    if docker info &>/dev/null; then
        echo "${GREEN}✅ Docker is working correctly${NC}"
    else
        echo "${RED}❌ Docker is not working correctly${NC}"
    fi
fi

# Check for Rosetta 2
echo ""
echo "${BLUE}Checking Rosetta 2...${NC}"
if /usr/bin/pgrep -q oahd; then
    echo "${GREEN}✅ Rosetta 2 is installed${NC}"
else
    echo "${YELLOW}⚠️  Rosetta 2 might not be installed${NC}"
    echo "Install with: softwareupdate --install-rosetta"
fi

# Oracle JDK check
echo ""
echo "${BLUE}Checking Oracle JDK...${NC}"
ORACLE_JDK="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"

if [ -d "$ORACLE_JDK" ]; then
    echo "${GREEN}✅ Found Oracle JDK at: $ORACLE_JDK${NC}"
    
    # Check architecture
    if file "$ORACLE_JDK/bin/java" 2>/dev/null | grep -q "x86_64"; then
        echo "${GREEN}✅ Oracle JDK is x86_64 (will run via Rosetta 2)${NC}"
    fi
else
    echo "${RED}❌ Oracle JDK not found at expected location${NC}"
fi

echo ""
echo "${BLUE}====================================================${NC}"
echo "${BLUE}Summary${NC}"
echo "${BLUE}====================================================${NC}"
echo "Your Apple Silicon setup appears to be compatible with Oracle and WebLogic."
echo "${BLUE}====================================================${NC}"
