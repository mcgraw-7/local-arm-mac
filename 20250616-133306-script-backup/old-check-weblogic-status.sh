#!/bin/zsh
# ==========================================================================
# WebLogic Comprehensive Status & Diagnostics Script
# Checks server status, analyzes common errors, and provides remediation steps
# ==========================================================================

# Set color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Status message functions
function print_banner() {
    echo ""
    echo "${BLUE}====================================================${NC}"
    echo "${BLUE}$1${NC}"
    echo "${BLUE}====================================================${NC}"
    echo ""
}

function print_section() {
    echo "${CYAN}----------------------------------------------------${NC}"
    echo "${CYAN}$1${NC}"
    echo "${CYAN}----------------------------------------------------${NC}"
}

function print_success() {
    echo "${GREEN}✅ $1${NC}"
}

function print_error() {
    echo "${RED}❌ $1${NC}"
}

function print_warning() {
    echo "${YELLOW}⚠️ $1${NC}"
}

function print_info() {
    echo "${BLUE}ℹ️ $1${NC}"
}

# Check if file exists and is readable
function check_file() {
    if [[ -r "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Dynamically determine Oracle Middleware and WebLogic paths
# Check for common installation patterns
function detect_oracle_paths() {
    local possible_paths=(
        "${HOME}/dev/Oracle/Middleware/Oracle_Home"
        "${HOME}/dev/Oracle/Middleware"
        "${HOME}/Oracle/Middleware/Oracle_Home"
        "${HOME}/Oracle/Middleware"
        "/u01/oracle/middleware"
    )
    
    for path in "${possible_paths[@]}"; do
        if [[ -d "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    # If we can't find a standard path, try to detect from running processes
    local wl_proc_path=$(ps -ef | grep java | grep weblogic | grep -v grep | awk '{print $8}' | xargs dirname 2>/dev/null || echo "")
    if [[ -n "$wl_proc_path" ]]; then
        # Try to get Oracle home from the running process
        local detected_path=$(echo "$wl_proc_path" | sed -E 's|(.*Middleware).*|\1|')
        if [[ -d "$detected_path" ]]; then
            echo "$detected_path"
            return 0
        fi
    fi
    
    # Default to the most common path if we can't detect it
    echo "${HOME}/dev/Oracle/Middleware"
}

# Dynamically determine domain path
function detect_domain_path() {
    local oracle_home="$1"
    local possible_domain_dirs=(
        "${oracle_home}/user_projects/domains"
        "${oracle_home}/Oracle_Home/user_projects/domains"
        "${oracle_home}/../domains"
        "${HOME}/dev/Oracle/domains"
    )
    
    # First check for domains directory
    local domains_dir=""
    for dir in "${possible_domain_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            domains_dir="$dir"
            break
        fi
    done
    
    if [[ -z "$domains_dir" ]]; then
        # Default
        domains_dir="${oracle_home}/user_projects/domains"
    fi
    
    # Now look for P2-DEV domain
    if [[ -d "${domains_dir}/P2-DEV" ]]; then
        echo "${domains_dir}/P2-DEV"
    elif [[ -d "${domains_dir}/base_domain" ]]; then
        echo "${domains_dir}/base_domain"
    else
        # Try to find any domain directory
        local first_domain=$(find "${domains_dir}" -maxdepth 1 -type d -not -path "${domains_dir}" | head -1)
        if [[ -n "$first_domain" ]]; then
            echo "$first_domain"
        else
            # Default
            echo "${domains_dir}/P2-DEV"
        fi
    fi
}

# Set important variables with auto-detection
ORACLE_HOME=$(detect_oracle_paths)
WL_HOME="${ORACLE_HOME}/wlserver"
if [[ ! -d "$WL_HOME" ]]; then
    WL_HOME="${ORACLE_HOME}/Oracle_Home/wlserver"
fi
DOMAIN_HOME=$(detect_domain_path "$ORACLE_HOME")
DOMAIN_NAME=$(basename "$DOMAIN_HOME")
ADMIN_SERVER="AdminServer"
ADMIN_PORT=7001

print_info "Using Oracle Home: $ORACLE_HOME"
print_info "Using WebLogic Home: $WL_HOME"
print_info "Using Domain Home: $DOMAIN_HOME"

LOG_DIR="${DOMAIN_HOME}/servers/${ADMIN_SERVER}/logs"
SERVER_LOG="${LOG_DIR}/${ADMIN_SERVER}.log"
SERVER_OUT="${LOG_DIR}/${ADMIN_SERVER}.out"
ERROR_COUNT=15  # Number of recent errors to show

# Status message functions
function print_banner() {
    echo ""
    echo "${BLUE}====================================================${NC}"
    echo "${BLUE}$1${NC}"
    echo "${BLUE}====================================================${NC}"
    echo ""
}

function print_section() {
    echo "${CYAN}----------------------------------------------------${NC}"
    echo "${CYAN}$1${NC}"
    echo "${CYAN}----------------------------------------------------${NC}"
}

function print_success() {
    echo "${GREEN}✅ $1${NC}"
}

function print_error() {
    echo "${RED}❌ $1${NC}"
}

function print_warning() {
    echo "${YELLOW}⚠️ $1${NC}"
}

function print_info() {
    echo "${BLUE}ℹ️ $1${NC}"
}

# Check if file exists and is readable
function check_file() {
    if [[ -r "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Check server status
function check_server_status() {
    print_section "WebLogic Process Status"
    
    # Check if Java process for WebLogic is running
    WL_PID=$(ps -ef | grep java | grep "$DOMAIN_HOME" | grep -v grep | awk '{print $2}')

    if [ -n "$WL_PID" ]; then
        print_success "WebLogic is RUNNING (PID: $WL_PID)"
        
        # Get uptime
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS approach
            START_TIME=$(ps -o lstart= -p $WL_PID)
            if [[ -n "$START_TIME" ]]; then
                print_info "Running since: $START_TIME"
            fi
        fi
        
        # Check memory usage
        MEM_USAGE=$(ps -o rss= -p $WL_PID)
        if [[ -n "$MEM_USAGE" ]]; then
            MEM_MB=$(( $MEM_USAGE / 1024 ))
            print_info "Memory usage: ${MEM_MB} MB"
        fi
        
        # Check if the admin port is listening
        if netstat -an | grep LISTEN | grep -q ".$ADMIN_PORT "; then
            print_success "WebLogic Admin Console is accessible at: http://localhost:$ADMIN_PORT/console"
        else
            print_warning "WebLogic process is running but port $ADMIN_PORT is not listening yet"
            print_info "The server may still be starting up. Please wait."
        fi
    else
        print_error "WebLogic is NOT RUNNING"
    fi
}

# Check Oracle database connection
function check_database() {
    print_section "Oracle Database Status"
    
    ORACLE_CONTAINER=$(docker ps | grep -i "oracle\|vbms-dev-docker" | grep -v grep)
    if [ -n "$ORACLE_CONTAINER" ]; then
        print_success "Oracle Database is running: $(echo $ORACLE_CONTAINER | awk '{print $NF}')"
    else
        print_error "Oracle Database is NOT RUNNING"
        print_info "Start the database with: docker-compose up -d"
    fi
}

# Check for Java compatibility issues
function check_java_compatibility() {
    print_section "Java Compatibility Check"
    
    # Get Java version
    JAVA_VERSION=$(java -version 2>&1 | head -1)
    print_info "Current Java version: $JAVA_VERSION"
    
    # Check for Apple Silicon compatibility issues
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            print_warning "Running on Apple Silicon ($ARCH)"
            print_info "WebLogic may have compatibility issues with some Java versions on Apple Silicon"
            
            # Check for Rosetta usage
            JAVA_ARCH=$(file $(which java) | grep -i architecture)
            if [[ "$JAVA_ARCH" == *"x86_64"* ]]; then
                print_info "Java is running via Rosetta 2 translation"
            elif [[ "$JAVA_ARCH" == *"arm64"* ]]; then
                print_info "Java is running natively on ARM64"
            fi
        else
            print_info "Running on Intel architecture ($ARCH)"
        fi
    fi
    
    # Check for known problematic class files
    if [[ -n "$WL_PID" ]]; then
        print_section "Checking for Known Class Loading Issues"
        if check_file "$SERVER_LOG"; then
            BOUNCY_ISSUES=$(grep -i "Unable to parse class file: .*bcprov" "$SERVER_LOG" | tail -5)
            if [[ -n "$BOUNCY_ISSUES" ]]; then
                print_error "Bouncy Castle Compatibility Issues Detected:"
                echo "$BOUNCY_ISSUES"
                print_info "Solution: The BouncyCastle version may be incompatible with your Java version."
                print_info "Try using bcprov-jdk15to18 instead of bcprov-jdk15on in your application."
            fi
        fi
    fi
}

# Analyze recent log errors
function analyze_logs() {
    print_section "Recent Error Analysis"
    
    if check_file "$SERVER_LOG"; then
        ERROR_LOGS=$(grep -i "<Error>" "$SERVER_LOG" | tail -$ERROR_COUNT)
        if [[ -n "$ERROR_LOGS" ]]; then
            print_error "Found recent errors in ${SERVER_LOG}:"
            echo "$ERROR_LOGS"
            
            # Look for specific error patterns and provide remediation
            if echo "$ERROR_LOGS" | grep -q "bcprov.*versions/15"; then
                print_warning "Java JDK compatibility issue detected with BouncyCastle provider"
                print_info "Remediation: Use an older version of BouncyCastle or update your deployment configuration"
                print_info "Consider adding -Djava.security.debug=jarverification to your JVM arguments for more details"
            fi
            
            if echo "$ERROR_LOGS" | grep -q "java.lang.NullPointerException"; then
                print_warning "NullPointerException detected during deployment"
                print_info "Remediation: Check application dependencies and configuration"
            fi
            
            if echo "$ERROR_LOGS" | grep -q "BEA-149265"; then
                print_warning "Deployment failure detected"
                print_info "Check application EAR/WAR structure and deployment descriptors"
            fi
        else
            print_success "No recent errors found in server logs"
        fi
    else
        print_warning "Cannot access log file: $SERVER_LOG"
    fi
    
    # Check stdout/stderr log for additional issues
    if check_file "$SERVER_OUT"; then
        JVM_ERRORS=$(grep -i -E "exception|error|fatal" "$SERVER_OUT" | tail -10)
        if [[ -n "$JVM_ERRORS" ]]; then
            print_warning "JVM-level issues detected:"
            echo "$JVM_ERRORS"
        fi
    fi
}

# Show deployed applications
function show_deployments() {
    print_section "Deployed Applications"
    
    if [[ -d "${DOMAIN_HOME}/deployments" ]]; then
        APPS=$(ls -la "${DOMAIN_HOME}/deployments" | grep -v "^d")
        if [[ -n "$APPS" ]]; then
            print_info "Deployed applications:"
            echo "$APPS"
        else
            print_info "No applications found in deployments directory"
        fi
    fi
    
    # Check for specific application directories
    VBMS_DIRS=$(find "${DOMAIN_HOME}/servers/${ADMIN_SERVER}/tmp/_WL_user" -name "vbms*" -type d 2>/dev/null)
    if [[ -n "$VBMS_DIRS" ]]; then
        print_info "VBMS application deployment directories:"
        echo "$VBMS_DIRS"
    fi
}

# Check system resources
function check_resources() {
    print_section "System Resources"
    
    # Check disk space
    print_info "Disk space usage:"
    df -h /Users | tail -1
    
    # Check memory
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS memory check
        print_info "Memory usage:"
        top -l 1 -n 0 | grep PhysMem
    fi
    
    # Check if resource constraints might be an issue
    if [[ -n "$WL_PID" ]]; then
        CPU_USAGE=$(ps -o %cpu -p $WL_PID | tail -1 | tr -d ' ')
        if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
            print_warning "WebLogic is using high CPU: ${CPU_USAGE}%"
        else
            print_info "WebLogic CPU usage: ${CPU_USAGE}%"
        fi
    fi
}

# Check configuration
function check_configuration() {
    print_section "WebLogic Configuration"
    
    # Check key configuration files
    CONFIG_FILE="${DOMAIN_HOME}/config/config.xml"
    if check_file "$CONFIG_FILE"; then
        print_success "Domain configuration exists"
        
        # Check for JVM settings that might affect compatibility
        JVM_ARGS_FILE="${DOMAIN_HOME}/bin/setDomainEnv.sh"
        if check_file "$JVM_ARGS_FILE"; then
            JVM_MEM_SETTINGS=$(grep -E "MEM_ARGS|JAVA_OPTIONS" "$JVM_ARGS_FILE" | grep -v "^#")
            if [[ -n "$JVM_MEM_SETTINGS" ]]; then
                print_info "JVM Memory Settings:"
                echo "$JVM_MEM_SETTINGS"
            fi
        fi
    else
        print_error "Domain configuration missing: $CONFIG_FILE"
    fi
}

# Add detailed BouncyCastle compatibility check
function check_bouncy_castle_compatibility() {
    print_section "BouncyCastle Compatibility Analysis"
    
    # Look for specific bcprov version used in app
    BCPROV_JARS=$(find "${DOMAIN_HOME}/servers/${ADMIN_SERVER}/tmp/_WL_user" -name "bcprov*.jar" 2>/dev/null)
    
    if [[ -n "$BCPROV_JARS" ]]; then
        print_info "Found BouncyCastle JARs:"
        echo "$BCPROV_JARS"
        
        print_warning "Your error indicates a mismatch between BouncyCastle JAR version and Java version"
        print_info "The bcprov-jdk15on-1.67.jar is having issues with META-INF/versions/15/ classes"
        print_info "This typically happens when running newer Java versions with older BC libraries"
        print_info "Recommendation: Update application to use bcprov-jdk15to18 instead of bcprov-jdk15on"
    else
        print_info "No BouncyCastle JARs found directly - may be embedded in application EARs/WARs"
    fi
}

# Check for deployment issues
function check_deployment_issues() {
    print_section "Deployment Issue Analysis"
    
    # Check for recent deployment attempts
    if check_file "$SERVER_LOG"; then
        DEPLOY_ATTEMPTS=$(grep -i "Deploying" "$SERVER_LOG" | tail -5)
        if [[ -n "$DEPLOY_ATTEMPTS" ]]; then
            print_info "Recent deployment attempts:"
            echo "$DEPLOY_ATTEMPTS"
        fi
        
        # Look for specific error patterns
        NPE_ERRORS=$(grep -i "NullPointerException" "$SERVER_LOG" | tail -5)
        if [[ -n "$NPE_ERRORS" ]]; then
            print_error "NullPointerException errors during deployment:"
            echo "$NPE_ERRORS"
            print_warning "This may be caused by:"
            print_info "1. Missing dependencies in the application"
            print_info "2. Incompatible library versions"
            print_info "3. Issues with deployment descriptors"
            print_info "4. Class loading conflicts between app and server"
        fi
    fi
}

# Main execution
print_banner "WebLogic Comprehensive Status Check"

check_server_status
check_database
check_java_compatibility
check_configuration
analyze_logs
check_bouncy_castle_compatibility
check_deployment_issues
show_deployments
check_resources

print_banner "Diagnostics Complete"

# Show helpful commands and remediation steps for the current issues
echo "Recommendations for your current errors:"
echo "1. The BouncyCastle error indicates Java compatibility issues with bcprov-jdk15on-1.67.jar"
echo "   - Consider updating your application to use bcprov-jdk15to18 instead"
echo "   - Or downgrade your Java version to match the BC provider version"
echo ""
echo "2. The deployment NullPointerException may be related to the BC issue or other dependency problems"
echo "   - Try removing and redeploying the application after fixing the BC issue"
echo "   - Check all library dependencies in your vbms-core-app EAR file"
echo ""
echo "Useful commands:"
echo "  Start WebLogic:     cd $DOMAIN_HOME/bin && ./startWebLogic.sh"
echo "  Stop WebLogic:      cd $DOMAIN_HOME/bin && ./stopWebLogic.sh"
echo "  View detailed logs: tail -f $SERVER_LOG"
echo "  Restart WebLogic:   cd $DOMAIN_HOME/bin && ./stopWebLogic.sh && ./startWebLogic.sh"
echo ""