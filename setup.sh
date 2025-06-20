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
echo "1. Check Apple Silicon compatibility"
echo "2. Verify Oracle WebLogic standardized directory structure"
echo "3. Configure Java environment (limited access, no sudo)"
echo "4. Configure WebLogic-specific environment"
echo "5. Verify Java standardization"
echo "6. Manage Oracle Database (with Apple Silicon support)"
echo "7. Verify Oracle DB container for WebLogic"
echo "8. Create WebLogic domain with Oracle DB verification"
echo "9. Add VA Environment helper functions"
echo "10. Add WebLogic status helper function"
echo "11. Add VBMS deployment helper function"
echo "12. Add WebLogic start with Oracle DB verification helper functions"
echo "13. Update scripts (non-sudo mode)"
echo "14. Clean up temporary files and artifacts"
echo "15. View README Documentation"
echo "16. Exit"

echo -n "Select an option (1-16): "
read option

case $option in
    1)
        echo "Checking Apple Silicon compatibility..."
        echo "${BLUE}This will check your environment for Apple Silicon compatibility with Oracle and WebLogic${NC}"
        "$(dirname "$0")/scripts/utils/check-apple-silicon.sh"
        ;;
    2)
        echo "Verifying Oracle WebLogic standardized directory structure..."
        echo "${BLUE}This will check if WebLogic is installed in the standardized directory${NC}"
        "$(dirname "$0")/scripts/utils/verify-oracle-directory.sh"
        ;;
    3)
        echo "${YELLOW}WARNING: This will modify multiple files including .zshrc and create Java wrapper scripts${NC}"
        echo -n "Do you want to continue? (y/n): "
        read confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Configuring Java environment..."
            "$(dirname "$0")/scripts/java/limited-access-java-env.sh"
        else
            echo "Operation cancelled."
        fi
        ;;
    4)
        echo "${YELLOW}WARNING: This will modify .zshrc and create WebLogic environment files${NC}"
        echo "The following will be added to your .zshrc:"
        echo "${BLUE}"
        echo '# WebLogic Java environment helper function'
        echo 'wl_java() {'
        echo '    if [ -f "$HOME/.wljava_env" ]; then'
        echo '        source "$HOME/.wljava_env"'
        echo '        echo "WebLogic Java environment activated"'
        echo '    else'
        echo '        echo "ERROR: WebLogic Java environment file not found"'
        echo '    fi'
        echo '}'
        echo "${NC}"
        echo -n "Do you want to continue? (y/n): "
        read confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Configuring WebLogic-specific environment..."
            "$(dirname "$0")"/scripts/weblogic/setup-wl-java.sh
        else
            echo "Operation cancelled."
        fi
        ;;
    5)
        echo "Verifying Java standardization..."
        "$(dirname "$0")/scripts/utils/verify-standardization.sh"
        ;;
    6)
        echo "Managing Oracle Database (with Apple Silicon support)..."
        echo "${BLUE}This will help you manage Oracle Database with specific support for Apple Silicon${NC}"
        "$(dirname "$0")/scripts/weblogic/manage-oracle-db.sh"
        ;;
    7)
        echo "Verifying Oracle DB container for WebLogic..."
        echo "${BLUE}This will check if Oracle DB is properly configured for WebLogic${NC}"
        "$(dirname "$0")/scripts/weblogic/verify-oracle-db.sh"
        ;;
    8)
        echo "Creating WebLogic domain with Oracle DB verification..."
        echo "${BLUE}This will create a WebLogic domain after verifying Oracle DB container is running${NC}"
        "$(dirname "$0")/scripts/weblogic/create-domain-m3-fixed.sh"
        ;;
    9)
        echo "Adding VA Environment helper functions..."
        echo "${BLUE}This will add the va_env() function to your .zshrc file${NC}"
        "$(dirname "$0")/scripts/utils/add-va-env-function.sh"
        ;;
    10)
        echo "Adding WebLogic status helper function..."
        echo "${BLUE}This will add the va_weblogic_status() function to your .zshrc file${NC}"
        "$(dirname "$0")/scripts/utils/add-va-weblogic-status-function.sh"
        ;;
    11)
        echo "Adding VBMS deployment helper function..."
        echo "${BLUE}This will add the va_deploy_vbms() function to your .zshrc file${NC}"
        "$(dirname "$0")/scripts/utils/add-va-deploy-vbms-function.sh"
        ;;
    12)
        echo "Adding WebLogic start with Oracle DB verification helper functions..."
        echo "${BLUE}This will add va_start_weblogic() and va_start_oracle_db() functions to your .zshrc file${NC}"
        "$(dirname "$0")/scripts/utils/add-va-start-weblogic-function.sh"
        ;;
    13)
        echo "${YELLOW}WARNING: This will update multiple script files in your system${NC}"
        echo -n "Do you want to continue? (y/n): "
        read confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Updating scripts (non-sudo mode)..."
            "$(dirname "$0")/scripts/utils/update-scripts-without-sudo.sh"
        else
            echo "Operation cancelled."
        fi
        ;;
    14)
        echo "Cleaning up temporary files and artifacts..."
        echo "${BLUE}This will help remove temporary files that should not be in the Git repository${NC}"
        "$(dirname "$0")/scripts/utils/cleanup-artifacts.sh"
        ;;
    15)
        echo "Displaying README documentation..."
        echo "${BLUE}This will display the README file with setup instructions${NC}"
        # Try to use a markdown viewer if available, otherwise use less/cat
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
    16)
        echo "${YELLOW}Exiting setup script${NC}"
        exit 0
        ;;
    *)
        echo "${RED}❌ Invalid option. Please try again.${NC}"
        exit 1
        ;;
esac

echo "${GREEN}Setup completed!${NC}"
