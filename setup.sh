#!/bin/zsh
# Main setup script for Java/WebLogic environment standardization
# This script serves as the entry point for configuring the Java environment for WebLogic
# development on Apple Silicon Macs without requiring sudo access.

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}=== Java/WebLogic Environment Standardization Setup ===${NC}"
echo "This script will help you set up your Java environment for WebLogic development on Apple Silicon Mac."

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
echo "1. Configure Java environment (limited access, no sudo)"
echo "2. Configure WebLogic-specific environment"
echo "3. Verify Java standardization"
echo "4. Update scripts (non-sudo mode)"
echo "5. Run with Oracle JDK wrapper"
echo "6. Exit"

echo -n "Select an option (1-6): "
read option

case $option in
    1)
        echo "Configuring Java environment..."
        "$(dirname "$0")/scripts/java/limited-access-java-env.sh"
        ;;
    2)
        echo "Configuring WebLogic-specific environment..."
        "$(dirname "$0")/scripts/weblogic/setup-wl-java.sh"
        ;;
    3)
        echo "Verifying Java standardization..."
        "$(dirname "$0")/scripts/utils/verify-standardization.sh"
        ;;
    4)
        echo "Updating scripts (non-sudo mode)..."
        "$(dirname "$0")/scripts/utils/update-scripts-without-sudo.sh"
        ;;
    5)
        echo "Setting up Oracle JDK wrapper..."
        "$(dirname "$0")/scripts/java/run-with-oracle-jdk.sh"
        echo "Copying run-with-oracle-jdk.sh to ~/dev for easy access..."
        cp "$(dirname "$0")/scripts/java/run-with-oracle-jdk.sh" ~/dev/
        chmod +x ~/dev/run-with-oracle-jdk.sh
        ;;
    6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "${RED}Invalid option. Please try again.${NC}"
        exit 1
        ;;
esac

echo "${GREEN}Setup completed!${NC}"
