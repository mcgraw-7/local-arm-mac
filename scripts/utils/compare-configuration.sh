#!/bin/zsh
# Configuration Comparison Script
# This script compares your current configuration with the required configuration
# for WebLogic, Java, Maven, and other components

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Function to print a section header
print_section() {
    echo "${BLUE}========== $1 ==========${NC}"
}

# Function to print comparison
print_comparison() {
    local item="$1"
    local required="$2"
    local current="$3"
    local result="$4"
    
    printf "%-25s | %-30s | %-30s | " "$item" "$required" "$current"
    
    if [ "$result" = "PASS" ]; then
        echo "${GREEN}✅ PASS${NC}"
    elif [ "$result" = "WARN" ]; then
        echo "${YELLOW}⚠️  WARNING${NC}"
    else
        echo "${RED}❌ FAIL${NC}"
    fi
}

# Function to print comparison table header
print_table_header() {
    printf "${CYAN}%-25s | %-30s | %-30s | %-10s${NC}\n" "Component" "Required" "Current" "Status"
    printf "${GRAY}%-25s-|-%-30s-|-%-30s-|-%-10s${NC}\n" "-------------------------" "--------------------------" "--------------------------" "----------"
}

echo "${BLUE}===================================================================${NC}"
echo "${BLUE}                CONFIGURATION COMPARISON REPORT                    ${NC}"
echo "${BLUE}===================================================================${NC}"
echo ""
echo "This report compares your current configuration with the required"
echo "configuration for a proper WebLogic development environment."
echo ""
echo "Script version: 1.0.1 (Fixed parameters bug)"
echo ""

# -------------------------------------
# OPERATING SYSTEM REQUIREMENTS
# -------------------------------------
print_section "OPERATING SYSTEM REQUIREMENTS"
print_table_header

# Architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH_STATUS="PASS"
    ARCH_NOTE=""
elif [ "$ARCH" = "arm64" ]; then
    ARCH_STATUS="WARN"
    ARCH_NOTE="(Requires Rosetta 2)"
else
    ARCH_STATUS="FAIL"
    ARCH_NOTE="(Unsupported)"
fi
print_comparison "Architecture" "Intel x86_64 preferred" "$ARCH $ARCH_NOTE" "$ARCH_STATUS"

# macOS Version
OS_VERSION=$(sw_vers -productVersion)
OS_MAJOR=$(echo "$OS_VERSION" | cut -d. -f1)
OS_MINOR=$(echo "$OS_VERSION" | cut -d. -f2)

if [ "$OS_MAJOR" -ge 11 ] || ( [ "$OS_MAJOR" -eq 10 ] && [ "$OS_MINOR" -ge 15 ] ); then
    OS_STATUS="PASS"
else
    OS_STATUS="WARN"
fi
print_comparison "macOS Version" "10.15 or later" "$OS_VERSION" "$OS_STATUS"

# Memory
TOTAL_MEM=$(sysctl -n hw.memsize)
TOTAL_MEM_GB=$((TOTAL_MEM / 1073741824))
if [ "$TOTAL_MEM_GB" -ge 16 ]; then
    MEM_STATUS="PASS"
elif [ "$TOTAL_MEM_GB" -ge 8 ]; then
    MEM_STATUS="WARN"
else
    MEM_STATUS="FAIL"
fi
print_comparison "Memory" "16 GB or more" "$TOTAL_MEM_GB GB" "$MEM_STATUS"

# Rosetta 2 (only check on Apple Silicon)
if [ "$ARCH" = "arm64" ]; then
    if pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
        ROSETTA_STATUS="PASS"
        ROSETTA_CURRENT="Installed"
    else
        ROSETTA_STATUS="FAIL"
        ROSETTA_CURRENT="Not installed"
    fi
    print_comparison "Rosetta 2" "Required for Apple Silicon" "$ROSETTA_CURRENT" "$ROSETTA_STATUS"
fi

# -------------------------------------
# JAVA REQUIREMENTS
# -------------------------------------
print_section "JAVA REQUIREMENTS"
print_table_header

# Java Version
JAVA_VERSION=$(java -version 2>&1 | head -1)
# Directly check for your specific version which we know is installed
if [[ "$JAVA_VERSION" == *"java version \"1.8.0_202\""* ]]; then
    JAVA_VERSION_STATUS="PASS"
elif [[ "$JAVA_VERSION" == *"1.8"* ]]; then
    JAVA_VERSION_STATUS="WARN"
else
    JAVA_VERSION_STATUS="FAIL"
fi
print_comparison "Java Version" "Oracle JDK 1.8.0_202" "$JAVA_VERSION" "$JAVA_VERSION_STATUS"

# Java Home
EXPECTED_JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
if [ "$JAVA_HOME" = "$EXPECTED_JAVA_HOME" ]; then
    JAVA_HOME_STATUS="PASS"
elif [[ "$JAVA_HOME" == *"jdk1.8"* ]]; then
    JAVA_HOME_STATUS="WARN"
else
    JAVA_HOME_STATUS="FAIL"
fi
print_comparison "JAVA_HOME" "$EXPECTED_JAVA_HOME" "$JAVA_HOME" "$JAVA_HOME_STATUS"

# Java binary location
JAVA_BIN=$(type -p java)
if [[ "$JAVA_BIN" == *"jdk1.8.0_202"* ]]; then
    JAVA_BIN_STATUS="PASS"
elif [[ "$JAVA_BIN" == *"jdk1.8"* ]]; then
    JAVA_BIN_STATUS="WARN"
else
    JAVA_BIN_STATUS="FAIL"
fi
print_comparison "Java binary" "$EXPECTED_JAVA_HOME/bin/java" "$JAVA_BIN" "$JAVA_BIN_STATUS"

# -------------------------------------
# WEBLOGIC REQUIREMENTS
# -------------------------------------
print_section "WEBLOGIC REQUIREMENTS"
print_table_header

# Oracle Home
EXPECTED_ORACLE_HOME="$HOME/dev/Oracle/Middleware/Oracle_Home"
if [ "$ORACLE_HOME" = "$EXPECTED_ORACLE_HOME" ] && [ -d "$ORACLE_HOME" ]; then
    ORACLE_HOME_STATUS="PASS"
    ORACLE_HOME_CURRENT="$ORACLE_HOME (Exists)"
elif [ -n "$ORACLE_HOME" ]; then
    ORACLE_HOME_STATUS="WARN"
    ORACLE_HOME_CURRENT="$ORACLE_HOME (Non-standard)"
else
    ORACLE_HOME_STATUS="FAIL"
    ORACLE_HOME_CURRENT="Not set"
fi
print_comparison "ORACLE_HOME" "$EXPECTED_ORACLE_HOME" "$ORACLE_HOME_CURRENT" "$ORACLE_HOME_STATUS"

# WebLogic Home
EXPECTED_WL_HOME="$EXPECTED_ORACLE_HOME/wlserver"
if [ "$WL_HOME" = "$EXPECTED_WL_HOME" ] && [ -d "$WL_HOME" ]; then
    WL_HOME_STATUS="PASS"
    WL_HOME_CURRENT="$WL_HOME (Exists)"
elif [ -n "$WL_HOME" ]; then
    WL_HOME_STATUS="WARN"
    WL_HOME_CURRENT="$WL_HOME (Non-standard)"
else
    WL_HOME_STATUS="FAIL"
    WL_HOME_CURRENT="Not set"
fi
print_comparison "WL_HOME" "$EXPECTED_WL_HOME" "$WL_HOME_CURRENT" "$WL_HOME_STATUS"

# Domain Home
if [ -n "$DOMAIN_HOME" ] && [ -d "$DOMAIN_HOME" ]; then
    DOMAIN_HOME_STATUS="PASS"
    DOMAIN_HOME_CURRENT="$DOMAIN_HOME (Exists)"
elif [ -n "$DOMAIN_HOME" ]; then
    DOMAIN_HOME_STATUS="WARN"
    DOMAIN_HOME_CURRENT="$DOMAIN_HOME (Not found)"
else
    DOMAIN_HOME_STATUS="FAIL"
    DOMAIN_HOME_CURRENT="Not set"
fi
print_comparison "DOMAIN_HOME" "Any valid domain path" "$DOMAIN_HOME_CURRENT" "$DOMAIN_HOME_STATUS"

# P2-DEV Domain
P2_DEV_DIR="$EXPECTED_ORACLE_HOME/user_projects/domains/P2-DEV"
if [ -d "$P2_DEV_DIR" ]; then
    P2_DEV_STATUS="PASS"
    P2_DEV_CURRENT="Found at $P2_DEV_DIR"
else
    P2_DEV_STATUS="WARN"
    P2_DEV_CURRENT="Not found"
fi
print_comparison "P2-DEV Domain" "Recommended for VBMS" "$P2_DEV_CURRENT" "$P2_DEV_STATUS"

# WebLogic classpath
if [[ "$CLASSPATH" == *"weblogic.jar"* ]]; then
    CLASSPATH_STATUS="PASS"
    CLASSPATH_CURRENT="Contains weblogic.jar"
else
    CLASSPATH_STATUS="WARN"
    CLASSPATH_CURRENT="Missing weblogic.jar"
fi
print_comparison "WebLogic Classpath" "Should include weblogic.jar" "$CLASSPATH_CURRENT" "$CLASSPATH_STATUS"

# -------------------------------------
# MAVEN REQUIREMENTS
# -------------------------------------
print_section "MAVEN REQUIREMENTS"
print_table_header

# Maven Installation
if command -v mvn >/dev/null 2>&1; then
    MVN_VERSION=$(mvn -v | grep -E 'Apache Maven' | head -1)
    if [[ "$MVN_VERSION" == *"3.9"* ]]; then
        MVN_STATUS="PASS"
    elif [[ "$MVN_VERSION" == *"3."* ]]; then
        MVN_STATUS="PASS"
    else
        MVN_STATUS="WARN"
    fi
    print_comparison "Maven Version" "Apache Maven 3.x" "$MVN_VERSION" "$MVN_STATUS"
    
    # Maven home
    MVN_HOME=$(mvn -v | grep 'Maven home' | sed 's/Maven home: //')
    if [ -n "$MVN_HOME" ] && [ -d "$MVN_HOME" ]; then
        MVN_HOME_STATUS="PASS"
    else
        MVN_HOME_STATUS="WARN"
    fi
    print_comparison "Maven Home" "Any valid path" "$MVN_HOME" "$MVN_HOME_STATUS"
    
    # Maven settings
    if [ -f "$HOME/.m2/settings.xml" ]; then
        SETTINGS_STATUS="PASS"
        SETTINGS_CURRENT="$HOME/.m2/settings.xml (Exists)"
    else
        SETTINGS_STATUS="WARN"
        SETTINGS_CURRENT="Not found"
    fi
    print_comparison "Maven Settings" "$HOME/.m2/settings.xml" "$SETTINGS_CURRENT" "$SETTINGS_STATUS"
else
    print_comparison "Maven Installation" "Required" "Not installed" "FAIL"
fi

# -------------------------------------
# NETWORK REQUIREMENTS
# -------------------------------------
print_section "NETWORK REQUIREMENTS"
print_table_header

# Host entries
if grep -q "claims01.p2.vbms.va.gov" /etc/hosts; then
    HOSTS_STATUS="PASS"
    HOSTS_CURRENT="Entry found"
else
    HOSTS_STATUS="WARN"
    HOSTS_CURRENT="Entry missing"
fi
print_comparison "P2 Host Entry" "claims01.p2.vbms.va.gov" "$HOSTS_CURRENT" "$HOSTS_STATUS"

# Admin port
if netstat -an | grep -q "LISTEN.*\.7001 "; then
    PORT_STATUS="PASS"
    PORT_CURRENT="7001 (Listening)"
else
    PORT_STATUS="WARN"
    PORT_CURRENT="7001 (Not listening)"
fi
print_comparison "WebLogic Admin Port" "7001 (should be listening)" "$PORT_CURRENT" "$PORT_STATUS"

echo ""
echo "${BLUE}===================================================================${NC}"
echo "${BLUE}                   END OF COMPARISON REPORT                        ${NC}"
echo "${BLUE}===================================================================${NC}"
echo ""
echo "${YELLOW}NOTE:${NC} This report compares your environment with the recommended setup."
echo "      WARNINGS aren't necessarily a problem if your environment uses"
echo "      non-standard but intentional configurations."
