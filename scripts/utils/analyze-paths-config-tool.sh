#!/bin/zsh
# Path Analysis Configuration Tool
# This script analyzes system paths and categorizes them for Maven, Java, and Oracle
# to help verify against documentation and ensure proper configuration

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

# Function to print a path with status
print_path() {
    local path="$1"
    local path_status="$2"
    local description="$3"
    
    if [ "$path_status" = "exists" ]; then
        echo "${GREEN}✅ $path${NC}"
    elif [ "$path_status" = "missing" ]; then
        echo "${RED}❌ $path${NC}"
    elif [ "$path_status" = "optional" ]; then
        echo "${YELLOW}⚠️  $path${NC}"
    else
        echo "  $path"
    fi
    
    if [ -n "$description" ]; then
        echo "    $description"
    fi
}

echo "${BLUE}===================================================================${NC}"
echo "${BLUE}                 PATH ANALYSIS CONFIGURATION TOOL                  ${NC}"
echo "${BLUE}===================================================================${NC}"
echo ""
echo "This tool analyzes system paths and categorizes them for:"
echo "• Maven configuration and repositories"
echo "• Java installations and environment"
echo "• Oracle WebLogic and database components"
echo ""

# -------------------------------------
# MAVEN PATH ANALYSIS
# -------------------------------------
print_section "MAVEN PATH ANALYSIS"

print_subsection "Maven Installation Paths"
# Check Maven installation
if command -v mvn >/dev/null 2>&1; then
    MVN_PATH=$(which mvn)
    MVN_HOME=$(mvn -v | grep "Maven home" | awk '{print $3}')
    print_path "$MVN_PATH" "exists" "Maven executable location"
    print_path "$MVN_HOME" "exists" "Maven home directory"
else
    print_path "mvn command" "missing" "Maven not found in PATH"
fi

print_subsection "Maven Configuration Paths"
# Maven settings and repository paths
MAVEN_SETTINGS="$HOME/.m2/settings.xml"
MAVEN_REPO="$HOME/.m2/repository"
MAVEN_LOCAL_REPO="$HOME/.m2/repository"

print_path "$MAVEN_SETTINGS" "$([ -f "$MAVEN_SETTINGS" ] && echo "exists" || echo "missing")" "Maven settings.xml file"
print_path "$MAVEN_REPO" "$([ -d "$MAVEN_REPO" ] && echo "exists" || echo "missing")" "Maven local repository"
print_path "$MAVEN_LOCAL_REPO" "$([ -d "$MAVEN_LOCAL_REPO" ] && echo "exists" || echo "missing")" "Maven local repository (alternative path)"

print_subsection "Maven Repository URLs"
if [ -f "$MAVEN_SETTINGS" ]; then
    echo "Configured repositories in settings.xml:"
    # Use a more robust approach to extract repository URLs
    if grep -q "<repository>" "$MAVEN_SETTINGS"; then
        # Extract URLs from repository sections
        awk '/<repository>/,/<\/repository>/ {
            if ($0 ~ /<url>/) {
                gsub(/.*<url>/, "")
                gsub(/<\/url>.*/, "")
                gsub(/^[ \t]+/, "")
                gsub(/[ \t]+$/, "")
                if (length($0) > 0) {
                    print "  - " $0
                }
            }
        }' "$MAVEN_SETTINGS"
    else
        echo "  - No custom repositories found (using Maven Central)"
    fi
    
    # Also check for mirror configurations
    if grep -q "<mirror>" "$MAVEN_SETTINGS"; then
        echo ""
        echo "Maven mirrors configured:"
        awk '/<mirror>/,/<\/mirror>/ {
            if ($0 ~ /<url>/) {
                gsub(/.*<url>/, "")
                gsub(/<\/url>.*/, "")
                gsub(/^[ \t]+/, "")
                gsub(/[ \t]+$/, "")
                if (length($0) > 0) {
                    print "  - " $0
                }
            }
        }' "$MAVEN_SETTINGS"
    fi
else
    echo "${YELLOW}⚠️  No settings.xml found - using default Maven Central${NC}"
fi

# -------------------------------------
# JAVA PATH ANALYSIS
# -------------------------------------
print_section "JAVA PATH ANALYSIS"

print_subsection "Java Installation Paths"
# Check Java installations
JAVA_PATH=$(which java)
JAVA_HOME_VALUE="$JAVA_HOME"
JDK_8_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk"
JDK_11_PATH="$HOME/dev/jdk-11.0.26.jdk"
JDK_8_ALT_PATH="$HOME/dev/jdk1.8.0_181"

print_path "$JAVA_PATH" "$([ -n "$JAVA_PATH" ] && echo "exists" || echo "missing")" "Java executable location"
print_path "$JAVA_HOME_VALUE" "$([ -n "$JAVA_HOME_VALUE" ] && echo "exists" || echo "missing")" "JAVA_HOME environment variable"
print_path "$JDK_8_PATH" "$([ -d "$JDK_8_PATH" ] && echo "exists" || echo "missing")" "Standard JDK 8 installation (Oracle)"
print_path "$JDK_11_PATH" "$([ -d "$JDK_11_PATH" ] && echo "exists" || echo "missing")" "JDK 11 installation (local)"
print_path "$JDK_8_ALT_PATH" "$([ -d "$JDK_8_ALT_PATH" ] && echo "exists" || echo "optional")" "Alternative JDK 8 installation (local)"

print_subsection "Java Version Information"
if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -1)
    echo "Current Java version: $JAVA_VERSION"
    
    # Check if it's the expected Java 8
    if [[ "$JAVA_VERSION" == *"1.8"* ]]; then
        echo "${GREEN}✅ Java 8 detected - compatible with WebLogic${NC}"
    else
        echo "${YELLOW}⚠️  Non-Java 8 version detected - may cause WebLogic issues${NC}"
    fi
else
    echo "${RED}❌ Java not found in PATH${NC}"
fi

print_subsection "Java Environment Variables"
echo "JAVA_HOME: $JAVA_HOME"
echo "JAVA_OPTS: $JAVA_OPTS"
echo "JRE_HOME: $JRE_HOME"

# -------------------------------------
# ORACLE PATH ANALYSIS
# -------------------------------------
print_section "ORACLE PATH ANALYSIS"

print_subsection "Oracle Middleware Paths"
# Oracle WebLogic paths
ORACLE_HOME="$HOME/dev/Oracle/Middleware/Oracle_Home"
WEBLOGIC_HOME="$ORACLE_HOME/wlserver"
ORACLE_COMMON="$ORACLE_HOME/oracle_common"
ORACLE_INVENTORY="$HOME/dev/Oracle/oraInventory"

print_path "$ORACLE_HOME" "$([ -d "$ORACLE_HOME" ] && echo "exists" || echo "missing")" "Oracle Middleware home (required)"
print_path "$WEBLOGIC_HOME" "$([ -d "$WEBLOGIC_HOME" ] && echo "exists" || echo "missing")" "WebLogic Server home"
print_path "$ORACLE_COMMON" "$([ -d "$ORACLE_COMMON" ] && echo "exists" || echo "missing")" "Oracle Common home"
print_path "$ORACLE_INVENTORY" "$([ -d "$ORACLE_INVENTORY" ] && echo "exists" || echo "optional")" "Oracle Inventory directory"

print_subsection "WebLogic Domain Paths"
# WebLogic domain paths
DOMAIN_BASE="$ORACLE_HOME/user_projects/domains"
DOMAIN_CONFIG="$DOMAIN_BASE/*/config/config.xml"

if [ -d "$DOMAIN_BASE" ]; then
    echo "Available WebLogic domains:"
    for domain in "$DOMAIN_BASE"/*; do
        if [ -d "$domain" ]; then
            domain_name=$(basename "$domain")
            if [ -f "$domain/config/config.xml" ]; then
                print_path "$domain" "exists" "Domain: $domain_name"
            else
                print_path "$domain" "optional" "Domain: $domain_name (incomplete)"
            fi
        fi
    done
else
    print_path "$DOMAIN_BASE" "missing" "No WebLogic domains directory found"
fi

print_subsection "Oracle Database Paths"
# Oracle database paths
ORACLE_DB_CONTAINER="oracle-db"
ORACLE_DB_DATA="$HOME/dev/oracle-data"
DOCKER_COMPOSE_PATH="$HOME/dev/docker-compose.yml"

print_path "$ORACLE_DB_DATA" "$([ -d "$ORACLE_DB_DATA" ] && echo "exists" || echo "optional")" "Oracle database data directory"
print_path "$DOCKER_COMPOSE_PATH" "$([ -f "$DOCKER_COMPOSE_PATH" ] && echo "exists" || echo "optional")" "Docker Compose file for Oracle DB"

# Check if Oracle DB container is running
if command -v docker >/dev/null 2>&1; then
    if docker ps | grep -q "$ORACLE_DB_CONTAINER"; then
        print_path "Oracle DB Container" "exists" "Container is running"
    else
        print_path "Oracle DB Container" "optional" "Container not running"
    fi
else
    print_path "Docker" "missing" "Docker not available"
fi

# -------------------------------------
# VBMS SPECIFIC PATHS
# -------------------------------------
print_section "VBMS SPECIFIC PATHS"

print_subsection "VBMS Application Paths"
# VBMS application paths
VBMS_CORE="$HOME/dev/vbms-core"
VBMS_UI="$HOME/dev/bip-vbms-core-vet-info-profile-ui"
VBMS_API="$HOME/dev/bip-veteran-api"
VBMS_ANALYTICS="$HOME/dev/vbms-core/vbms-analytics"

print_path "$VBMS_CORE" "$([ -d "$VBMS_CORE" ] && echo "exists" || echo "optional")" "VBMS Core application"
print_path "$VBMS_UI" "$([ -d "$VBMS_UI" ] && echo "exists" || echo "optional")" "VBMS UI application"
print_path "$VBMS_API" "$([ -d "$VBMS_API" ] && echo "exists" || echo "optional")" "VBMS API application"
print_path "$VBMS_ANALYTICS" "$([ -d "$VBMS_ANALYTICS" ] && echo "exists" || echo "optional")" "VBMS Analytics"

print_subsection "Deployment Paths"
# Deployment paths
DEPLOYMENTS_DIR="$HOME/dev/deployments"
APPS_DIR="$HOME/dev/apps"

print_path "$DEPLOYMENTS_DIR" "$([ -d "$DEPLOYMENTS_DIR" ] && echo "exists" || echo "optional")" "WebLogic deployments directory"
print_path "$APPS_DIR" "$([ -d "$APPS_DIR" ] && echo "exists" || echo "optional")" "Applications directory"

# -------------------------------------
# ENVIRONMENT PATH ANALYSIS
# -------------------------------------
print_section "ENVIRONMENT PATH ANALYSIS"

print_subsection "PATH Environment Variable"
echo "Current PATH entries:"
echo "$PATH" | tr ':' '\n' | sed 's/^/  /' | while read path_entry; do
    if [ -n "$path_entry" ]; then
        # Skip Oracle_Home/bin as it's not a standard Oracle WebLogic directory
        if [[ "$path_entry" == *"Oracle_Home/bin"* ]]; then
            continue
        fi
        if [ -d "$path_entry" ]; then
            echo "${GREEN}  ✅ $path_entry${NC}"
        else
            echo "${RED}  ❌ $path_entry (not found)${NC}"
        fi
    fi
done

print_subsection "Key Environment Variables"
echo "ORACLE_HOME: $ORACLE_HOME"
echo "WEBLOGIC_HOME: $WEBLOGIC_HOME"
echo "M2_HOME: $M2_HOME"
echo "JAVA_HOME: $JAVA_HOME"
echo "DOMAIN_HOME: $DOMAIN_HOME"

# -------------------------------------
# DOCUMENTATION VERIFICATION
# -------------------------------------
print_section "DOCUMENTATION VERIFICATION"

print_subsection "Required Paths for Documentation"
echo "Paths that should be verified against documentation:"
echo ""
echo "${CYAN}Maven Paths:${NC}"
echo "  • Maven executable: $MVN_PATH"
echo "  • Maven home: $MVN_HOME"
echo "  • Maven settings: $MAVEN_SETTINGS"
echo "  • Maven repository: $MAVEN_REPO"
echo ""
echo "${CYAN}Java Paths:${NC}"
echo "  • Java executable: $JAVA_PATH"
echo "  • JAVA_HOME: $JAVA_HOME_VALUE"
echo "  • JDK 8 standard: $JDK_8_PATH"
echo "  • JDK 11 local: $JDK_11_PATH"
echo ""
echo "${CYAN}Oracle Paths:${NC}"
echo "  • ORACLE_HOME: $ORACLE_HOME"
echo "  • WEBLOGIC_HOME: $WEBLOGIC_HOME"
echo "  • Oracle Common: $ORACLE_COMMON"
echo "  • Domain base: $DOMAIN_BASE"
echo "  • Oracle Inventory: $ORACLE_INVENTORY"

# -------------------------------------
# SUMMARY AND RECOMMENDATIONS
# -------------------------------------
print_section "SUMMARY AND RECOMMENDATIONS"

echo "${BLUE}Path Analysis Summary:${NC}"
echo ""

# Count existing vs missing paths
MAVEN_PATHS_EXIST=0
MAVEN_PATHS_MISSING=0
JAVA_PATHS_EXIST=0
JAVA_PATHS_MISSING=0
ORACLE_PATHS_EXIST=0
ORACLE_PATHS_MISSING=0

# Maven path counts
if [ -n "$MVN_PATH" ]; then MAVEN_PATHS_EXIST=$((MAVEN_PATHS_EXIST + 1)); else MAVEN_PATHS_MISSING=$((MAVEN_PATHS_MISSING + 1)); fi
if [ -n "$MVN_HOME" ]; then MAVEN_PATHS_EXIST=$((MAVEN_PATHS_EXIST + 1)); else MAVEN_PATHS_MISSING=$((MAVEN_PATHS_MISSING + 1)); fi
if [ -f "$MAVEN_SETTINGS" ]; then MAVEN_PATHS_EXIST=$((MAVEN_PATHS_EXIST + 1)); else MAVEN_PATHS_MISSING=$((MAVEN_PATHS_MISSING + 1)); fi

# Java path counts
if [ -n "$JAVA_PATH" ]; then JAVA_PATHS_EXIST=$((JAVA_PATHS_EXIST + 1)); else JAVA_PATHS_MISSING=$((JAVA_PATHS_MISSING + 1)); fi
if [ -n "$JAVA_HOME_VALUE" ]; then JAVA_PATHS_EXIST=$((JAVA_PATHS_EXIST + 1)); else JAVA_PATHS_MISSING=$((JAVA_PATHS_MISSING + 1)); fi
if [ -d "$JDK_8_PATH" ]; then JAVA_PATHS_EXIST=$((JAVA_PATHS_EXIST + 1)); else JAVA_PATHS_MISSING=$((JAVA_PATHS_MISSING + 1)); fi

# Oracle path counts
if [ -d "$ORACLE_HOME" ]; then ORACLE_PATHS_EXIST=$((ORACLE_PATHS_EXIST + 1)); else ORACLE_PATHS_MISSING=$((ORACLE_PATHS_MISSING + 1)); fi
if [ -d "$WEBLOGIC_HOME" ]; then ORACLE_PATHS_EXIST=$((ORACLE_PATHS_EXIST + 1)); else ORACLE_PATHS_MISSING=$((ORACLE_PATHS_MISSING + 1)); fi
if [ -d "$ORACLE_COMMON" ]; then ORACLE_PATHS_EXIST=$((ORACLE_PATHS_EXIST + 1)); else ORACLE_PATHS_MISSING=$((ORACLE_PATHS_MISSING + 1)); fi

echo "Maven Configuration: ${GREEN}$MAVEN_PATHS_EXIST${NC} paths found, ${RED}$MAVEN_PATHS_MISSING${NC} missing"
echo "Java Configuration:  ${GREEN}$JAVA_PATHS_EXIST${NC} paths found, ${RED}$JAVA_PATHS_MISSING${NC} missing"
echo "Oracle Configuration: ${GREEN}$ORACLE_PATHS_EXIST${NC} paths found, ${RED}$ORACLE_PATHS_MISSING${NC} missing"

echo ""
echo "${BLUE}Recommendations:${NC}"
echo ""

if [ $MAVEN_PATHS_MISSING -gt 0 ]; then
    echo "${YELLOW}⚠️  Maven configuration needs attention:${NC}"
    echo "  • Run: ./scripts/utils/check-maven-config.sh"
    echo "  • Verify Maven installation and settings.xml"
fi

if [ $JAVA_PATHS_MISSING -gt 0 ]; then
    echo "${YELLOW}⚠️  Java configuration needs attention:${NC}"
    echo "  • Run: ./scripts/java/verify-java-limited.sh"
    echo "  • Ensure JAVA_HOME is properly set"
    echo "  • Verify JDK 8 installation for WebLogic compatibility"
fi

if [ $ORACLE_PATHS_MISSING -gt 0 ]; then
    echo "${YELLOW}⚠️  Oracle configuration needs attention:${NC}"
    echo "  • Run: ./scripts/utils/verify-oracle-directory.sh"
    echo "  • Ensure WebLogic is installed in standard location"
    echo "  • Verify Oracle Middleware structure"
fi

if [ $MAVEN_PATHS_MISSING -eq 0 ] && [ $JAVA_PATHS_MISSING -eq 0 ] && [ $ORACLE_PATHS_MISSING -eq 0 ]; then
    echo "${GREEN}✅ All critical paths are properly configured!${NC}"
fi

echo ""
echo "${BLUE}===================================================================${NC}"
echo "${BLUE}                 PATH ANALYSIS COMPLETE                           ${NC}"
echo "${BLUE}===================================================================${NC}"
echo ""
echo "Use this output to verify against your documentation and ensure"
echo "all paths are correctly configured for your development environment."
echo ""
echo "For detailed configuration checks, run:"
echo "  • ./scripts/utils/show-complete-configuration.sh"
echo "  • ./scripts/utils/verify-standardization.sh"
echo "  • ./scripts/utils/compare-configuration.sh" 