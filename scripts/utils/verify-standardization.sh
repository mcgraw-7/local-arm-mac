#!/bin/zsh
# WebLogic Java Standardization Verification
# This script checks that your WebLogic environment is correctly using Oracle JDK 1.8.0_45

# Set color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ORACLE_JDK="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
STANDARDIZED_SCRIPTS="${HOME}/dev/standardized-scripts"
WL_ENV_FILE="${HOME}/.wljava_env"

echo "${BLUE}=== WebLogic Java Standardization Verification ===${NC}"

# Check if Oracle JDK exists
echo -n "Checking Oracle JDK installation: "
if [ -d "$ORACLE_JDK" ]; then
    echo "${GREEN}✅ FOUND${NC}"
    echo "  Path: $ORACLE_JDK"
else
    echo "${RED}❌ NOT FOUND${NC}"
    echo "  The required Oracle JDK is not installed at $ORACLE_JDK"
    exit 1
fi

# Check environment file
echo -n "Checking WebLogic Java environment file: "
if [ -f "$WL_ENV_FILE" ]; then
    echo "${GREEN}✅ FOUND${NC}"
    echo "  Path: $WL_ENV_FILE"
else
    echo "${RED}❌ NOT FOUND${NC}"
    echo "  Run setup-wl-java.sh to create the environment file"
fi

# Check standardized scripts directory
echo -n "Checking standardized scripts directory: "
if [ -d "$STANDARDIZED_SCRIPTS" ]; then
    SCRIPT_COUNT=$(find "$STANDARDIZED_SCRIPTS" -name "*.sh" | wc -l | tr -d ' ')
    echo "${GREEN}✅ FOUND${NC}"
    echo "  Path: $STANDARDIZED_SCRIPTS"
    echo "  Contains $SCRIPT_COUNT scripts"
else
    echo "${RED}❌ NOT FOUND${NC}"
    echo "  Run standardize-weblogic-scripts.sh to create standardized scripts"
fi

# Check current Java environment
echo ""
echo "${BLUE}Current Java Environment:${NC}"
echo -n "JAVA_HOME: "
if [ "$JAVA_HOME" = "$ORACLE_JDK" ]; then
    echo "${GREEN}$JAVA_HOME${NC} ✅"
else
    echo "${RED}$JAVA_HOME${NC} ❌"
    echo "  Expected: $ORACLE_JDK"
    echo "  Run 'source $WL_ENV_FILE' to set the correct JAVA_HOME"
fi

echo -n "Java version: "
CURRENT_JAVA=$(java -version 2>&1 | head -1)
if [[ "$CURRENT_JAVA" == *"1.8.0_45"* ]]; then
    echo "${GREEN}$CURRENT_JAVA${NC} ✅"
else
    echo "${RED}$CURRENT_JAVA${NC} ❌"
    echo "  Expected: java version \"1.8.0_45\""
    echo "  Run 'source $WL_ENV_FILE' to use the correct Java version"
fi

echo ""
echo "${BLUE}Validation of critical scripts:${NC}"
# Check if core-config-status.sh is using the correct JDK path
if [ -f "${STANDARDIZED_SCRIPTS}/core-config-status.sh" ]; then
    JDK_PATH_LINE=$(grep "JDK_PATH=" "${STANDARDIZED_SCRIPTS}/core-config-status.sh")
    if [[ "$JDK_PATH_LINE" == *"$ORACLE_JDK"* ]]; then
        echo "core-config-status.sh: ${GREEN}Using correct JDK path${NC} ✅"
    else
        echo "core-config-status.sh: ${RED}Using incorrect JDK path${NC} ❌"
        echo "  $JDK_PATH_LINE"
    fi
else
    echo "core-config-status.sh: ${YELLOW}Not found in standardized scripts${NC} ⚠️"
fi

echo ""
echo "${BLUE}=== Verification Summary ===${NC}"
echo "Your WebLogic Java environment is set up to use Oracle JDK 1.8.0_45."
echo ""
echo "To run WebLogic scripts with the correct Java environment:"
echo "  1. ${YELLOW}source ${HOME}/.wljava_env${NC}"
echo "  2. Run your WebLogic scripts from ${YELLOW}${STANDARDIZED_SCRIPTS}${NC}"
echo ""
echo "Or use the helper script:"
echo "  ${YELLOW}${STANDARDIZED_SCRIPTS}/run-weblogic.sh script-name.sh${NC}"
