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
ORACLE_JDK="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
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

echo "${BLUE}--- Testing Current Configuration ---${NC}"
echo "1. Verify Java Standardization"
echo "2. Verify Java Limited Access Setup"
echo "3. Check Apple Silicon Compatibility"
echo "4. Verify Oracle DB Container for WebLogic"
echo "5. Verify Oracle WebLogic Standardized Directory Structure"
echo "6. Check VBMS Compatibility"
echo "7. WebLogic Status Checker"

echo "${BLUE}--- Updating Existing Configuration ---${NC}"
echo "8. Configure Java Environment (Limited Access, No Sudo)"
echo "9. Configure WebLogic-specific Environment"
echo "10. Update Scripts (Non-Sudo Mode)"
echo "11. Run with Oracle JDK Wrapper"
echo "12. Add VA Environment Helper Functions"
echo "13. Add WebLogic Status Helper Function"
echo "14. Add VBMS Deployment Helper Function"
echo "15. Add WebLogic Start with Oracle DB Verification Functions"
echo "16. Fix JDK Path"
echo "17. Standardize WebLogic Scripts"

echo "${BLUE}--- Utility Scripts & Functions ---${NC}"
echo "18. Create WebLogic Domain with Oracle DB Verification"
echo "19. Manage Oracle Database (with Apple Silicon Support)"
echo "20. Start WebLogic with Checks"
echo "21. Clean Up Temporary Files and Artifacts"
echo "22. Clean Up Untracked Files"
echo "23. WebLogic Java Environment (Limited Access)"

echo "${BLUE}--- Other Options ---${NC}"
echo "24. View README Documentation"
echo "25. Exit"

echo -n "Select an option (1-25): "
read option

case $option in
    # Testing Current Configuration
    1)
        echo "Verifying Java standardization..."
        "$(dirname "$0")/scripts/utils/verify-standardization.sh"
        ;;
    2)
        echo "Verifying Java limited access setup..."
        echo "${BLUE}This will check that the Java wrapper scripts are correctly set up${NC}"
        "$(dirname "$0")/scripts/java/verify-java-limited.sh"
        ;;
    3)
        echo "Checking Apple Silicon compatibility..."
        echo "${BLUE}This will check your environment for Apple Silicon compatibility with Oracle and WebLogic${NC}"
        "$(dirname "$0")/scripts/utils/check-apple-silicon.sh"
        ;;
    4)
        echo "Verifying Oracle DB container for WebLogic..."
        echo "${BLUE}This will check if Oracle DB is properly configured for WebLogic${NC}"
        "$(dirname "$0")/scripts/weblogic/verify-oracle-db.sh"
        ;;
    5)
        echo "Verifying Oracle WebLogic standardized directory structure..."
        echo "${BLUE}This will check if WebLogic is installed in the standardized directory${NC}"
        "$(dirname "$0")/scripts/utils/verify-oracle-directory.sh"
        ;;
    6)
        echo "Checking VBMS compatibility..."
        echo "${BLUE}This will check if your environment is compatible with running VBMS applications${NC}"
        "$(dirname "$0")/scripts/vbms/check-vbms-compatibility.sh"
        ;;
    7)
        echo "Running WebLogic status checker..."
        if declare -f va_weblogic_status > /dev/null; then
            va_weblogic_status
        else
            echo "${YELLOW}WebLogic status function not found. Installing it first...${NC}"
            "$(dirname "$0")/scripts/utils/add-va-weblogic-status-function.sh"
            echo "Please run 'source ~/.zshrc' and try again."
        fi
        ;;
        
    # Updating Existing Configuration
    8)
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
    9)
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
    10)
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
    11)
        echo "Setting up Oracle JDK wrapper..."
        echo "${BLUE}This will create a script at ~/dev/run-with-oracle-jdk.sh to run commands with Oracle JDK${NC}"
        "$(dirname "$0")/scripts/java/run-with-oracle-jdk.sh"
        echo "Copying run-with-oracle-jdk.sh to ~/dev for easy access..."
        cp "$(dirname "$0")/scripts/java/run-with-oracle-jdk.sh" ~/dev/
        chmod +x ~/dev/run-with-oracle-jdk.sh
        echo "${GREEN}✅ Created wrapper script at ~/dev/run-with-oracle-jdk.sh${NC}"
        ;;
    12)
        echo "Adding VA Environment helper functions..."
        echo "${BLUE}This will add the va_env() function to your .zshrc file${NC}"
        "$(dirname "$0")/scripts/utils/add-va-env-function.sh"
        ;;
    13)
        echo "Adding WebLogic status helper function..."
        echo "${BLUE}This will add the va_weblogic_status() function to your .zshrc file${NC}"
        "$(dirname "$0")/scripts/utils/add-va-weblogic-status-function.sh"
        ;;
    14)
        echo "Adding VBMS deployment helper function..."
        echo "${BLUE}This will add the va_deploy_vbms() function to your .zshrc file${NC}"
        "$(dirname "$0")/scripts/utils/add-va-deploy-vbms-function.sh"
        ;;
    15)
        echo "Adding WebLogic start with Oracle DB verification helper functions..."
        echo "${BLUE}This will add va_start_weblogic() and va_start_oracle_db() functions to your .zshrc file${NC}"
        "$(dirname "$0")/scripts/utils/add-va-start-weblogic-function.sh"
        ;;
    16)
        echo "Fixing JDK path..."
        echo "${BLUE}This will correct invalid JDK paths in your environment${NC}"
        "$(dirname "$0")/scripts/utils/fix-jdk-path.sh"
        ;;
    17)
        echo "Standardizing WebLogic scripts..."
        echo "${BLUE}This will update WebLogic scripts with standardized headers and error handling${NC}"
        "$(dirname "$0")/scripts/weblogic/standardize-weblogic-scripts.sh"
        ;;
        
    # Utility Scripts & Functions
    18)
        echo "Creating WebLogic domain with Oracle DB verification..."
        echo "${BLUE}This will create a WebLogic domain after verifying Oracle DB container is running${NC}"
        echo "${YELLOW}Adding debug mode for better diagnostics. Use --debug for verbose output.${NC}"
        "$(dirname "$0")/scripts/weblogic/create-domain-m3.sh" --debug
        ;;
    19)
        echo "Managing Oracle Database (with Apple Silicon support)..."
        echo "${BLUE}This will help you manage Oracle Database with specific support for Apple Silicon${NC}"
        "$(dirname "$0")/scripts/weblogic/manage-oracle-db.sh"
        ;;
    20)
        echo "Starting WebLogic with checks..."
        echo "${BLUE}This will start WebLogic after performing necessary checks${NC}"
        "$(dirname "$0")/scripts/weblogic/start-weblogic-with-checks.sh"
        ;;
    21)
        echo "Cleaning up temporary files and artifacts..."
        echo "${BLUE}This will help remove temporary files that should not be in the Git repository${NC}"
        "$(dirname "$0")/scripts/utils/cleanup-artifacts.sh"
        ;;
    22)
        echo "Cleaning up untracked files..."
        echo "${BLUE}This will help remove untracked files that might be cluttering your repository${NC}"
        "$(dirname "$0")/scripts/utils/cleanup-untracked-files.sh"
        ;;
    23)
        echo "Setting up WebLogic Java environment (limited access)..."
        echo "${BLUE}This will set up a limited access WebLogic Java environment${NC}"
        "$(dirname "$0")/scripts/weblogic/weblogic-java-env-limited.sh"
        ;;
        
    # Other Options
    24)
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
    25)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "${RED}Invalid option. Please try again.${NC}"
        exit 1
        ;;
esac

echo "${GREEN}Setup completed!${NC}"
