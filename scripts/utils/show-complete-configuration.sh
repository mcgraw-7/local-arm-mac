#!/bin/zsh
# Show Complete Configuration Script
# This script provides a comprehensive output of all system configuration
# relevant to WebLogic, Java, Maven, and OS environment

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print a section header
print_section() {
    echo "${BLUE}========== $1 ==========${NC}"
}

# Function to print a subsection header
print_subsection() {
    echo "${CYAN}--- $1 ---${NC}"
}

echo "${BLUE}===================================================================${NC}"
echo "${BLUE}                 COMPLETE CONFIGURATION REPORT                     ${NC}"
echo "${BLUE}===================================================================${NC}"
echo ""
echo "This report provides detailed information about your current configuration"
echo "for Oracle WebLogic, Java, and related components."
echo ""

# -------------------------------------
# OPERATING SYSTEM DETAILS
# -------------------------------------
print_section "OPERATING SYSTEM CONFIGURATION"

print_subsection "System Information"
echo "OS Name:      $(sw_vers -productName)"
echo "OS Version:   $(sw_vers -productVersion)"
echo "Build:        $(sw_vers -buildVersion)"
echo "Architecture: $(uname -m)"
echo "Kernel:       $(uname -r)"

print_subsection "CPU Information"
sysctl -n machdep.cpu.brand_string
echo "Cores:        $(sysctl -n hw.physicalcpu)"
echo "Threads:      $(sysctl -n hw.logicalcpu)"

print_subsection "Memory Information"
TOTAL_MEM=$(sysctl -n hw.memsize)
TOTAL_MEM_GB=$((TOTAL_MEM / 1073741824))
echo "Total Memory: $TOTAL_MEM_GB GB"

print_subsection "Rosetta 2 Status"
if [ "$(uname -m)" = "arm64" ]; then
    if pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
        echo "${GREEN}✅ Rosetta 2 is installed${NC}"
    else
        echo "${RED}❌ Rosetta 2 is NOT installed${NC}"
        echo "${YELLOW}⚠️  For running WebLogic, Rosetta 2 is recommended${NC}"
        echo "    Install with: softwareupdate --install-rosetta"
    fi
else
    echo "Not applicable (not running on Apple Silicon)"
fi

# -------------------------------------
# JAVA CONFIGURATION
# -------------------------------------
print_section "JAVA CONFIGURATION"

print_subsection "Java Version"
java_version=$(java -version 2>&1)
echo "$java_version"

print_subsection "Java Home"
echo "JAVA_HOME: $JAVA_HOME"
echo "Default java: $(which java)"
echo "Java path: $(type -a java)"

print_subsection "Java Runtime Details"
if [[ "$java_version" == *"1.8"* ]]; then
    # For Java 8
    echo -n "JVM Type: "
    if [[ "$java_version" == *"HotSpot"* ]]; then
        echo "HotSpot VM"
    elif [[ "$java_version" == *"OpenJDK"* ]]; then
        echo "OpenJDK VM"
    else
        echo "Unknown VM"
    fi

    # Try to get JVM flags
    echo "JVM Flags:"
    java -XX:+PrintFlagsFinal -version 2>&1 | grep -E "UseCompressedOops|MaxHeapSize|InitialHeapSize" | head -3
fi

# -------------------------------------
# WEBLOGIC CONFIGURATION
# -------------------------------------
print_section "WEBLOGIC CONFIGURATION"

print_subsection "WebLogic Installation"
ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
WEBLOGIC_HOME="${ORACLE_HOME}/wlserver"

if [ -d "$ORACLE_HOME" ]; then
    echo "${GREEN}✅ Oracle Middleware home found: $ORACLE_HOME${NC}"
    
    # Try to determine WebLogic version
    if [ -f "${WEBLOGIC_HOME}/server/lib/weblogic.jar" ]; then
        echo -n "WebLogic Version: "
        if [ -f "${ORACLE_HOME}/registry.xml" ]; then
            grep -o "WebLogic Server [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" "${ORACLE_HOME}/registry.xml" | head -1
        else
            echo "Unknown (registry.xml not found)"
        fi
    else
        echo "${RED}❌ WebLogic Server installation appears incomplete${NC}"
    fi
else
    echo "${RED}❌ Oracle Middleware home not found at standard location${NC}"
fi

print_subsection "WebLogic Domain Configuration"

# Try to find domain directories
DOMAIN_DIRS="${ORACLE_HOME}/user_projects/domains"
if [ -d "$DOMAIN_DIRS" ]; then
    echo "Available domains:"
    for domain in "$DOMAIN_DIRS"/*; do
        if [ -d "$domain" ]; then
            domain_name=$(basename "$domain")
            if [ -f "$domain/config/config.xml" ]; then
                admin_port=$(grep -o "<listen-port>[0-9]\+</listen-port>" "$domain/config/config.xml" | head -1 | grep -o "[0-9]\+")
                echo "${GREEN}✅ $domain_name${NC} (Admin port: $admin_port)"
            else
                echo "$domain_name (Config not found)"
            fi
        fi
    done
else
    echo "${RED}❌ No domains directory found at $DOMAIN_DIRS${NC}"
fi

# -------------------------------------
# MAVEN CONFIGURATION
# -------------------------------------
print_section "MAVEN CONFIGURATION"

print_subsection "Maven Installation"
if command -v mvn >/dev/null 2>&1; then
    echo "${GREEN}✅ Maven installed${NC}"
    echo "Maven version: $(mvn -v | grep -E 'Apache Maven' | head -1)"
    echo "Maven home: $(mvn -v | grep -E 'Maven home' | head -1)"
else
    echo "${RED}❌ Maven not found in PATH${NC}"
fi

print_subsection "Maven Environment Variables"
echo "M2_HOME: $M2_HOME"
if [ -f "$HOME/.m2/settings.xml" ]; then
    echo "Maven settings: $HOME/.m2/settings.xml (exists)"
    # Count repositories defined
    repo_count=$(grep -c "<repository>" "$HOME/.m2/settings.xml")
    echo "Defined repositories: $repo_count"
else
    echo "Maven settings: Not found"
fi

# -------------------------------------
# ENVIRONMENT VARIABLES
# -------------------------------------
print_section "ENVIRONMENT VARIABLES"

print_subsection "Path"
echo "$PATH" | tr ':' '\n' | sed 's/^/  /'

print_subsection "Java Related Variables"
declare -p | grep -E "JAVA|JDK|ORACLE|WL_|WEBLOGIC|DOMAIN" | sed 's/^/  /'

print_subsection "Other Relevant Variables"
declare -p | grep -E "PROXY|HTTP_|HTTPS_|NO_PROXY" | sed 's/^/  /'

# -------------------------------------
# HOST CONFIGURATION
# -------------------------------------
print_section "HOST CONFIGURATION"

print_subsection "WebLogic Domain Hosts"
if [ -f "/etc/hosts" ]; then
    echo "WebLogic-related entries in /etc/hosts:"
    grep -E 'weblogic|oracle|claims|vbms|localhost' /etc/hosts | sed 's/^/  /'
else
    echo "${RED}❌ Cannot access /etc/hosts file${NC}"
fi

# -------------------------------------
# NETWORK CONFIGURATION
# -------------------------------------
print_section "NETWORK CONFIGURATION"

print_subsection "Listening Ports"
echo "Ports related to WebLogic or Oracle services:"
netstat -an | grep LISTEN | grep -E '7001|7002|1521|5500|5520' | sed 's/^/  /'

print_subsection "Proxy Configuration"
echo "HTTP_PROXY: $HTTP_PROXY"
echo "HTTPS_PROXY: $HTTPS_PROXY"
echo "NO_PROXY: $NO_PROXY"

# -------------------------------------
# SHELL CONFIGURATION
# -------------------------------------
print_section "SHELL CONFIGURATION"

print_subsection "Shell Details"
echo "Current shell: $SHELL"
echo "Login shell: $(finger $USER | grep 'Shell:' | cut -d: -f3)"

print_subsection "Shell Configuration Files"
echo "ZSH config files:"
for file in ~/.zshrc ~/.zshenv ~/.zprofile ~/.zlogin ~/.zlogout; do
    if [ -f "$file" ]; then
        echo "  $file (exists, $(wc -l < "$file") lines)"
        
        # Check if it contains WebLogic/Oracle configurations
        if grep -q -E "ORACLE|WEBLOGIC|WL_|DOMAIN|JAVA_HOME" "$file"; then
            echo "  └─ Contains Oracle/WebLogic/Java configurations"
        fi
    else
        echo "  $file (does not exist)"
    fi
done

echo ""
echo "${BLUE}===================================================================${NC}"
echo "${BLUE}                 END OF CONFIGURATION REPORT                       ${NC}"
echo "${BLUE}===================================================================${NC}"
