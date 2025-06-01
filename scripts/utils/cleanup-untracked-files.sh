#!/bin/zsh
# Script to clean up unnecessary files that shouldn't be in the repository

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}====================================================${NC}"
echo "${BLUE}Cleaning up unnecessary files${NC}"
echo "${BLUE}====================================================${NC}"

# Define directories to check
VBMS_UI_DIR="../folder-location/folder-location-ui"
VBMS_INSTALL_DIR="../vbms-install-weblogic"
VBMS_DIR="../vbms"

# Files to clean up
echo "${YELLOW}Checking for files to clean up...${NC}"

# Check and clean yarn related files
if [ -f "${VBMS_UI_DIR}/src/yarn-error.log" ]; then
    echo "${YELLOW}Removing ${VBMS_UI_DIR}/src/yarn-error.log${NC}"
    rm -f "${VBMS_UI_DIR}/src/yarn-error.log"
    echo "${GREEN}✅ Removed yarn error log${NC}"
fi

if [ -f "${VBMS_UI_DIR}/yarn.lock" ]; then
    echo "${YELLOW}Are you sure you want to remove ${VBMS_UI_DIR}/yarn.lock? It might be needed for builds (y/n): ${NC}"
    read CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        rm -f "${VBMS_UI_DIR}/yarn.lock"
        echo "${GREEN}✅ Removed yarn.lock${NC}"
    else
        echo "${BLUE}Skipped removal of yarn.lock${NC}"
    fi
fi

# Check and clean WebLogic related files
if [ -f "${VBMS_INSTALL_DIR}/hazelcastLog.txt" ]; then
    echo "${YELLOW}Removing ${VBMS_INSTALL_DIR}/hazelcastLog.txt${NC}"
    rm -f "${VBMS_INSTALL_DIR}/hazelcastLog.txt"
    echo "${GREEN}✅ Removed Hazelcast log${NC}"
fi

if [ -f "${VBMS_INSTALL_DIR}/src/main/resources/domain.xml.bak" ]; then
    echo "${YELLOW}Removing ${VBMS_INSTALL_DIR}/src/main/resources/domain.xml.bak${NC}"
    rm -f "${VBMS_INSTALL_DIR}/src/main/resources/domain.xml.bak"
    echo "${GREEN}✅ Removed domain.xml backup${NC}"
fi

# Check for large installer files
if [ -f "${VBMS_INSTALL_DIR}/src/main/resources/fmw_12.2.1.4.0_wls_lite_generic.jar" ]; then
    echo "${YELLOW}Found large WebLogic installer file: ${VBMS_INSTALL_DIR}/src/main/resources/fmw_12.2.1.4.0_wls_lite_generic.jar${NC}"
    echo "${YELLOW}This file is very large and shouldn't be committed. Remove it? (y/n): ${NC}"
    read CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        rm -f "${VBMS_INSTALL_DIR}/src/main/resources/fmw_12.2.1.4.0_wls_lite_generic.jar"
        echo "${GREEN}✅ Removed WebLogic installer jar${NC}"
    else
        echo "${BLUE}Skipped removal. Consider moving this file outside the repository.${NC}"
    fi
fi

if [ -f "${VBMS_INSTALL_DIR}/src/main/resources/fmw_12214_readme.html" ]; then
    echo "${YELLOW}Removing ${VBMS_INSTALL_DIR}/src/main/resources/fmw_12214_readme.html${NC}"
    rm -f "${VBMS_INSTALL_DIR}/src/main/resources/fmw_12214_readme.html"
    echo "${GREEN}✅ Removed readme HTML${NC}"
fi

# Local properties file
if [ -f "${VBMS_INSTALL_DIR}/src/main/resources/local.properties" ]; then
    echo "${YELLOW}Found local.properties file: ${VBMS_INSTALL_DIR}/src/main/resources/local.properties${NC}"
    echo "${YELLOW}This might contain sensitive information. Want to check its contents? (y/n): ${NC}"
    read CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        cat "${VBMS_INSTALL_DIR}/src/main/resources/local.properties"
        echo ""
        echo "${YELLOW}Remove this file? (y/n): ${NC}"
        read REMOVE
        if [[ "$REMOVE" =~ ^[Yy]$ ]]; then
            rm -f "${VBMS_INSTALL_DIR}/src/main/resources/local.properties"
            echo "${GREEN}✅ Removed local.properties${NC}"
        else
            echo "${BLUE}Skipped removal. Consider adding to .gitignore.${NC}"
        fi
    else
        echo "${BLUE}Skipped checking contents. Consider adding to .gitignore.${NC}"
    fi
fi

# AspectJ crash dump files
for file in "${VBMS_DIR}"/ajcore.*.txt; do
    if [ -f "$file" ]; then
        echo "${YELLOW}Removing $file${NC}"
        rm -f "$file"
        echo "${GREEN}✅ Removed AspectJ crash dump${NC}"
    fi
done

echo ""
echo "${BLUE}====================================================${NC}"
echo "${GREEN}Cleanup complete!${NC}"
echo "${BLUE}====================================================${NC}"
echo ""
echo "A .gitignore file has been created in the local-arm-mac repository"
echo "to prevent these files from being tracked in the future."
echo ""
echo "Remember to commit the .gitignore file to the repository."
