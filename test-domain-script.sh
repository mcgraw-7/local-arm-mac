#!/bin/zsh
# WebLogic Domain Creation Script Validator
# This tests the domain creation script in various modes

# Set color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}====================================================${NC}"
echo "${BLUE}WebLogic Domain Creation Script Validation Tool${NC}"
echo "${BLUE}====================================================${NC}"
echo ""

# Script location
SCRIPT_DIR="$(dirname "$0")"
DOMAIN_SCRIPT="${SCRIPT_DIR}/scripts/weblogic/create-domain-m3.sh"

if [ ! -f "$DOMAIN_SCRIPT" ]; then
    echo "${RED}❌ Error: Domain creation script not found at:${NC}"
    echo "$DOMAIN_SCRIPT"
    exit 1
fi

echo "${GREEN}✅ Found domain script at: ${DOMAIN_SCRIPT}${NC}"

# Check script permissions
if [ ! -x "$DOMAIN_SCRIPT" ]; then
    echo "${YELLOW}⚠️ Script is not executable. Setting permissions...${NC}"
    chmod +x "$DOMAIN_SCRIPT"
    echo "${GREEN}✅ Made script executable${NC}"
else
    echo "${GREEN}✅ Script is executable${NC}"
fi

# Check for Colima detection snippet
echo ""
echo "${BLUE}Validating Colima detection code...${NC}"
COLIMA_CHECK=$(grep -E "COLIMA_STATUS=\\$\(colima status 2>&1\)" "$DOMAIN_SCRIPT")

if [ -n "$COLIMA_CHECK" ]; then
    echo "${GREEN}✅ Found proper Colima status detection code${NC}"
else
    echo "${RED}❌ Could not find proper Colima status detection code${NC}"
fi

COLIMA_PATTERN_CHECK=$(grep -E "\"\\\$COLIMA_STATUS\" == \*\"not running\"\*" "$DOMAIN_SCRIPT")

if [ -n "$COLIMA_PATTERN_CHECK" ]; then
    echo "${GREEN}✅ Found fixed pattern matching for Colima status${NC}"
else
    echo "${RED}❌ Could not find fixed pattern matching for Colima status${NC}"
fi

# Check for debug function
echo ""
echo "${BLUE}Validating debug capabilities...${NC}"
DEBUG_FUNCTION=$(grep -E "debug_msg\(\)" "$DOMAIN_SCRIPT")

if [ -n "$DEBUG_FUNCTION" ]; then
    echo "${GREEN}✅ Found debug_msg function${NC}"
else
    echo "${RED}❌ Could not find debug_msg function${NC}"
fi

# Check for command line parameters
echo ""
echo "${BLUE}Validating script parameters...${NC}"
DRY_RUN_CHECK=$(grep -E "\-\-dry-run" "$DOMAIN_SCRIPT")

if [ -n "$DRY_RUN_CHECK" ]; then
    echo "${GREEN}✅ Found --dry-run parameter support${NC}"
else
    echo "${RED}❌ Could not find --dry-run parameter support${NC}"
fi

# Check for improved error handling
echo ""
echo "${BLUE}Validating error handling...${NC}"
TRAP_CHECK=$(grep -E "trap " "$DOMAIN_SCRIPT")

if [ -n "$TRAP_CHECK" ]; then
    echo "${GREEN}✅ Found trap handler for error scenarios${NC}"
else
    echo "${YELLOW}⚠️ No trap handler found for error scenarios${NC}"
fi

# Prompt for additional tests
echo ""
echo "${BLUE}Would you like to run the script in dry-run mode? (y/n)${NC}"
read -r RUN_DRY_RUN

if [[ "$RUN_DRY_RUN" =~ ^[Yy]$ ]]; then
    echo ""
    echo "${BLUE}Running domain creation script in DRY RUN mode...${NC}"
    "$DOMAIN_SCRIPT" --dry-run
fi

echo ""
echo "${BLUE}====================================================${NC}"
echo "${BLUE}Script validation complete${NC}"
echo "${BLUE}====================================================${NC}"
