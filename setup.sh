#!/bin/zsh
# Main setup script for Java/WebLogic environment standardization
# This script serves as the entry point for configuring the Java environment for WebLogic
# development on Apple Silicon Macs without requiring sudo access.

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo "${BLUE}===================================================================${NC}"
echo "${BLUE}         Java/WebLogic Environment Standardization Setup            ${NC}"
echo "${BLUE}===================================================================${NC}"

# All documentation is in the README.md file

echo "This script will help you set up your Java environment for WebLogic development."

# Detect Apple Silicon Mac
if [ "$(uname -m)" = "arm64" ]; then
    echo "${YELLOW}==============================================${NC}"
    echo "${YELLOW}⚠️  DETECTED APPLE SILICON MAC (M1/M2/M3) ⚠️${NC}"
    echo "${YELLOW}==============================================${NC}"
    echo "Running WebLogic on Apple Silicon requires special configuration."
    echo ""
    echo "${BLUE}Recommendations for Apple Silicon:${NC}"
    echo "• Use option 14 to check your Apple Silicon compatibility now"
    echo "• Use option 13 to manage Oracle DB with Colima support"
    echo "• Verify Rosetta 2 is installed (softwareupdate --install-rosetta)"
    echo "• Ensure you have at least 16GB RAM for optimal performance"
    echo "• For detailed guidance, see: ${BLUE}docs/apple-silicon-compatibility.md${NC}"
    echo ""
fi

echo "${YELLOW}IMPORTANT:${NC} WebLogic must be installed in the Oracle standardized directory:"
echo "${HOME}/dev/Oracle/Middleware/Oracle_Home"
echo "No deviations from this directory structure are permitted."

# Check if Oracle JDK exists
ORACLE_JDK="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"
echo -n "Checking Oracle JDK installation: "
if [ -d "$ORACLE_JDK" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
    echo "${YELLOW}Oracle JDK 1.8.0_45 is required but not installed at the expected location:${NC}"
    echo "$ORACLE_JDK"
    echo "Please install it and run this script again."
    exit 1
fi

# Make scripts executable
echo "Making scripts executable..."
find "$(dirname "$0")/scripts" -type f -name "*.sh" -exec chmod +x {} \;
echo "${GREEN}✅ Scripts are now executable${NC}"

# Setup options
echo "${BLUE}=== Setup Options ===${NC}"
echo "1. Path Analysis (analyze system paths for Maven, Java, Oracle)"
echo "2. Check Apple Silicon compatibility"
echo "3. Verify VA Core environment standardization"
echo "4. Verify Oracle directory structure"
echo "5. View README Documentation"
echo "6. Exit"

echo -n "Select an option (1-6): "
read option

case $option in
    1)
        echo "Running Path Analysis Configuration Tool..."
        "$(dirname "$0")/scripts/utils/analyze-paths-config-tool.sh"
        ;;
    2)
        echo "Checking Apple Silicon compatibility..."
        "$(dirname "$0")/scripts/utils/check-apple-silicon.sh"
        ;;
    3)
        echo "Verifying VA Core environment standardization..."
        "$(dirname "$0")/scripts/utils/verify-standardization.sh"
        ;;
    4)
        echo "Verifying Oracle directory structure..."
        "$(dirname "$0")/scripts/utils/verify-oracle-directory.sh"
        ;;
    5)
        echo "Displaying README documentation..."
        if command -v glow &> /dev/null; then
            glow "$(dirname "$0")/README.md"
        elif command -v mdless &> /dev/null; then
            mdless "$(dirname "$0")/README.md"
        elif command -v bat &> /dev/null; then
            bat "$(dirname "$0")/README.md"
        elif command -v less &> /dev/null; then
            less "$(dirname "$0")/README.md"
        else
            cat "$(dirname "$0")/README.md"
        fi
        ;;
    6)
        echo "${YELLOW}Exiting setup script${NC}"
        exit 0
        ;;
    *)
        echo "${RED}Invalid option. Please select a valid option (1-6).${NC}"
        ;;
esac

echo "${GREEN}Setup completed!${NC}"
