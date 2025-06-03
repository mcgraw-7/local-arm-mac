#!/bin/zsh
# Verify and enforce Oracle WebLogic standardized directory structure
# This script checks for proper installation paths and provides guidance
# for standardized directory structure

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define the standardized Oracle WebLogic directory structure
ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
WLSERVER="${ORACLE_HOME}/wlserver"
DOMAIN_HOME="${ORACLE_HOME}/user_projects/domains/P2-DEV"
JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"

echo "${BLUE}=== Oracle WebLogic Directory Standardization Verification ===${NC}"
echo "This script checks that WebLogic is installed in the standardized location."

# Check if Oracle Home exists
echo -n "Checking Oracle Home directory: "
if [ -d "$ORACLE_HOME" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
    echo "${YELLOW}Oracle Home directory must be at:${NC}"
    echo "$ORACLE_HOME"
    echo ""
    echo "${YELLOW}Creating this directory structure requires:${NC}"
    echo "mkdir -p $ORACLE_HOME"
    echo ""
    echo "${YELLOW}If WebLogic is installed in a different location, you need to move it:${NC}"
    echo "mv /path/to/your/current/weblogic $ORACLE_HOME"
fi

# Check if WebLogic Server exists
echo -n "Checking WebLogic Server directory: "
if [ -d "$WLSERVER" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
    echo "${YELLOW}WebLogic Server directory must be at:${NC}"
    echo "$WLSERVER"
    
    # Look for WebLogic in other locations
    echo "${BLUE}Searching for WebLogic installations in other locations...${NC}"
    WL_LOCATIONS=$(find $HOME/dev -type d -name "wlserver" 2>/dev/null)
    
    if [ -n "$WL_LOCATIONS" ]; then
        echo "${YELLOW}Found WebLogic installations in non-standard locations:${NC}"
        echo "$WL_LOCATIONS"
        echo ""
        echo "${YELLOW}You must move WebLogic to the standardized directory:${NC}"
        echo "mkdir -p $ORACLE_HOME"
        for loc in $WL_LOCATIONS; do
            DIR=$(dirname $loc)
            echo "mv $DIR/* $ORACLE_HOME/"
        done
    else
        echo "${YELLOW}No WebLogic installations found in your dev directory.${NC}"
        echo "You need to install WebLogic at: $ORACLE_HOME"
    fi
fi

# Check if Domain exists
echo -n "Checking WebLogic Domain: "
if [ -d "$DOMAIN_HOME" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
    echo "${YELLOW}WebLogic Domain must be at:${NC}"
    echo "$DOMAIN_HOME"
    
    # Look for domains in other locations
    echo "${BLUE}Searching for WebLogic domains in other locations...${NC}"
    DOMAIN_LOCATIONS=$(find $HOME/dev -type d -path "*/user_projects/domains/*" 2>/dev/null)
    
    if [ -n "$DOMAIN_LOCATIONS" ]; then
        echo "${YELLOW}Found WebLogic domains in non-standard locations:${NC}"
        echo "$DOMAIN_LOCATIONS"
        echo ""
        echo "${YELLOW}You must move these domains to the standardized directory:${NC}"
        echo "mkdir -p $(dirname $DOMAIN_HOME)"
        echo "mv /path/to/your/domain $DOMAIN_HOME"
    else
        echo "${YELLOW}No WebLogic domains found in your dev directory.${NC}"
        echo "You need to create a domain at: $DOMAIN_HOME"
        echo "Use the create-domain-m3.sh script to create a properly configured domain."
    fi
fi

# Check for Oracle JDK
echo -n "Checking Oracle JDK: "
if [ -d "$JDK_PATH" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
    echo "${YELLOW}Oracle JDK must be installed at:${NC}"
    echo "$JDK_PATH"
    echo "You must install the official Oracle JDK 1.8.0_45, not an OpenJDK variant."
fi

echo ""
echo "${BLUE}=== Directory Structure Requirements ===${NC}"
echo "WebLogic ${RED}must${NC} be installed in the Oracle standardized directory:"
echo "$ORACLE_HOME"
echo "No deviations from this directory structure are permitted."
echo ""
echo "All scripts in this repository enforce this requirement to ensure"
echo "proper functionality and compatibility with VA systems."
