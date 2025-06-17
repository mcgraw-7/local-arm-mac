#!/bin/zsh
# Script to check VBMS applications compatibility with WebLogic on Apple Silicon
# This script will check both the environment and VBMS application requirements

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VBMS_HOME="${HOME}/dev/vbms-core"
ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
DOMAIN_HOME="${ORACLE_HOME}/user_projects/domains/P2-DEV"

echo "${BLUE}====================================================${NC}"
echo "${BLUE}VBMS Application Compatibility Check${NC}"
echo "${BLUE}====================================================${NC}"

# Step 1: Run the Apple Silicon compatibility check
if [ -f "${HOME}/dev/local-arm-mac/scripts/utils/check-apple-silicon.sh" ]; then
    echo "${BLUE}Running Apple Silicon compatibility check...${NC}"
    "${HOME}/dev/local-arm-mac/scripts/utils/check-apple-silicon.sh"
else
    echo "${YELLOW}⚠️  Apple Silicon compatibility check script not found${NC}"
    echo "Consider installing the local-arm-mac repository"
    echo "git clone https://github.com/your-repo/local-arm-mac.git ~/dev/local-arm-mac"
fi

# Step 2: Check VBMS application requirements
echo ""
echo "${BLUE}Checking VBMS application requirements...${NC}"

# Check if VBMS directory exists
if [ -d "$VBMS_HOME" ]; then
    echo "${GREEN}✅ Found VBMS home directory at: ${VBMS_HOME}${NC}"
    
    # Check for key VBMS directories
    if [ -d "${VBMS_HOME}/vbms" ]; then
        echo "${GREEN}✅ VBMS core modules found${NC}"
    else
        echo "${RED}❌ VBMS core modules not found in ${VBMS_HOME}/vbms${NC}"
    fi
    
    # Check for build files in the VBMS directory
    if [ -f "${VBMS_HOME}/Dockerfile" ]; then
        echo "${GREEN}✅ VBMS Dockerfile found${NC}"
    else
        echo "${RED}❌ VBMS Dockerfile not found${NC}"
    fi
else
    echo "${RED}❌ VBMS home directory not found at: ${VBMS_HOME}${NC}"
    echo "Please ensure you have cloned the VBMS repository to ~/dev/vbms-core"
fi

# Step 3: Check WebLogic and Domain setup for VBMS
echo ""
echo "${BLUE}Checking WebLogic setup for VBMS...${NC}"

# Check WebLogic installation
if [ -d "$ORACLE_HOME" ]; then
    echo "${GREEN}✅ Found Oracle home at: ${ORACLE_HOME}${NC}"
    
    # Check for WebLogic server
    if [ -d "${ORACLE_HOME}/wlserver" ]; then
        echo "${GREEN}✅ WebLogic server installation found${NC}"
    else
        echo "${RED}❌ WebLogic server not found in ${ORACLE_HOME}/wlserver${NC}"
    fi
    
    # Check for domain
    if [ -d "$DOMAIN_HOME" ]; then
        echo "${GREEN}✅ WebLogic domain found at: ${DOMAIN_HOME}${NC}"
        
        # Check domain configuration
        if [ -f "${DOMAIN_HOME}/config/config.xml" ]; then
            echo "${GREEN}✅ Domain configuration found${NC}"
        else
            echo "${RED}❌ Domain configuration file not found${NC}"
        fi
    else
        echo "${RED}❌ WebLogic domain not found at: ${DOMAIN_HOME}${NC}"
        echo "Consider creating a domain with create-domain-m3.sh from local-arm-mac"
    fi
else
    echo "${RED}❌ Oracle home not found at: ${ORACLE_HOME}${NC}"
    echo "Please install WebLogic in the standardized directory"
fi

# Step 4: Check for VBMS deployment files
echo ""
echo "${BLUE}Checking for VBMS deployment files...${NC}"

# Look for EAR files in dev directory
EAR_FILES=$(find "${HOME}/dev" -name "vbms*.ear" -maxdepth 1)
if [ -n "$EAR_FILES" ]; then
    echo "${GREEN}✅ VBMS EAR files found:${NC}"
    echo "$EAR_FILES"
else
    echo "${YELLOW}⚠️  No VBMS EAR files found in ${HOME}/dev${NC}"
    echo "You may need to build the VBMS application first"
fi

# Step 5: Check for Oracle DB configuration
echo ""
echo "${BLUE}Checking Oracle DB configuration for VBMS...${NC}"

# Check if Oracle DB is running
if docker info &>/dev/null; then
    ORACLE_CONTAINER=$(docker ps | grep -i oracle | grep -i database)
    if [ -n "$ORACLE_CONTAINER" ]; then
        echo "${GREEN}✅ Oracle database container is running:${NC}"
        echo "$ORACLE_CONTAINER"
    else
        echo "${RED}❌ Oracle database container is not running${NC}"
        echo "Use va_start_oracle_db function or manage-oracle-db.sh to start it"
    fi
else
    echo "${RED}❌ Docker is not running${NC}"
    if [ "$(uname -m)" = "arm64" ]; then
        echo "Make sure Colima is running on Apple Silicon"
    else
        echo "Please start Docker Desktop"
    fi
fi

# Print summary and next steps
echo ""
echo "${BLUE}====================================================${NC}"
echo "${BLUE}VBMS Application Compatibility Summary${NC}"
echo "${BLUE}====================================================${NC}"

echo "Next steps for VBMS on WebLogic:"
echo ""
echo "1. Ensure all compatibility checks pass"
echo "2. Start Oracle DB with va_start_oracle_db"
echo "3. Start WebLogic with va_start_weblogic"
echo "4. Deploy VBMS with va_deploy_vbms"
echo ""
echo "Helper functions are available in your .zshrc if you've run the setup.sh script"
echo "from the local-arm-mac repository."
echo "${BLUE}====================================================${NC}"
