#!/bin/zsh
# WebLogic Domain Creation Script for VBMS on M3 Mac with Oracle DB Verification
# This script creates a WebLogic domain after successful installation
# Version: 2.0 - Fixed for Apple Silicon and troubleshooting

# Parse command line arguments
DRY_RUN=false
DEBUG=true
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "Running in DRY RUN mode - no changes will be made"
fi

if [[ "$1" == "--debug" ]] || [[ "$2" == "--debug" ]]; then
    DEBUG=true
    echo "Running in DEBUG mode - verbose output enabled"
fi

# Set important variables
ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
DOMAIN_HOME="${ORACLE_HOME}/user_projects/domains/P2-DEV"
APPS_DIR="${ORACLE_HOME}/apps"
DOMAIN_NAME="P2-DEV"
ADMIN_USERNAME="weblogic"
ADMIN_PASSWORD="weblogic1"
ADMIN_PORT="7001"
ADMIN_HOST="localhost"
ADMIN_SERVER_NAME="AdminServer"
JDK_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home"
LOG_FILE="/tmp/create-domain-$$.log"

# Debug function with timestamps
debug_msg() {
    if [ "$DEBUG" = "true" ]; then
        echo "[$(date +%T)] 🔍 DEBUG: $1" | tee -a $LOG_FILE
    fi
}

error_msg() {
    echo "[$(date +%T)] ❌ ERROR: $1" | tee -a $LOG_FILE
    echo "Check log file for details: $LOG_FILE"
}

warn_msg() {
    echo "[$(date +%T)] ⚠️ WARNING: $1" | tee -a $LOG_FILE
}

success_msg() {
    echo "[$(date +%T)] ✅ SUCCESS: $1" | tee -a $LOG_FILE
}

# Trap function to provide diagnostic info on exit
cleanup() {
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        echo "Script exited with code $EXIT_CODE" | tee -a $LOG_FILE
        echo "Last 10 lines of log:" | tee -a $LOG_FILE
        tail -10 $LOG_FILE | tee -a $LOG_FILE
    fi
}

trap cleanup EXIT

# Start logging
echo "====================================================" | tee -a $LOG_FILE
echo "WebLogic Domain Creation for VBMS on M3 Mac" | tee -a $LOG_FILE
echo "Started at: $(date)" | tee -a $LOG_FILE
echo "====================================================" | tee -a $LOG_FILE

debug_msg "Script started"
debug_msg "OS type: $(uname -s)"
debug_msg "Architecture: $(uname -m)"
debug_msg "Variables initialized"
debug_msg "ORACLE_HOME=$ORACLE_HOME"
debug_msg "DOMAIN_HOME=$DOMAIN_HOME"

# Check if Docker is available
debug_msg "Checking for Docker..."
if ! command -v docker &> /dev/null; then
    error_msg "Docker is not installed or not in PATH"
    echo "Please install Docker Desktop and try again" | tee -a $LOG_FILE
    exit 1
fi
debug_msg "Docker is installed"

# Check Docker daemon is responsive
debug_msg "Checking if Docker daemon is responsive..."
if ! docker info &>/dev/null; then
    error_msg "Docker daemon is not responding"
    
    # Check if running on Apple Silicon and suggest Colima
    if [ "$(uname -m)" = "arm64" ]; then
        echo "On Apple Silicon Mac, make sure Colima is running:" | tee -a $LOG_FILE
        echo "colima start --arch x86_64 -c 4 -m 12" | tee -a $LOG_FILE
    else
        echo "Make sure Docker Desktop is running" | tee -a $LOG_FILE
    fi
    exit 1
fi
success_msg "Docker daemon is responsive"

# Check for Colima if on Apple Silicon
if [ "$(uname -m)" = "arm64" ]; then
    debug_msg "Apple Silicon detected, checking Colima..."
    
    if ! command -v colima &> /dev/null; then
        warn_msg "Colima is not installed, which is recommended for Apple Silicon"
        echo "You can install Colima with: brew install colima" | tee -a $LOG_FILE
    else
        debug_msg "Colima is installed, checking status"
        
        # Check if Colima is running - using the updated pattern match approach
        COLIMA_STATUS=$(colima status 2>&1)
        debug_msg "Colima status raw output: $COLIMA_STATUS"
        
        if [[ "$COLIMA_STATUS" == *"not running"* ]]; then
            warn_msg "Colima is not running"
            echo "Would you like to start Colima with recommended settings? [y/n]:" | tee -a $LOG_FILE
            read -r START_COLIMA
            
            if [[ "$START_COLIMA" =~ ^[Yy]$ ]]; then
                echo "Starting Colima with recommended settings..." | tee -a $LOG_FILE
                colima start --arch x86_64 -c 4 -m 12
                
                # Verify Colima started successfully
                if [ $? -eq 0 ]; then
                    success_msg "Colima started successfully"
                else
                    error_msg "Failed to start Colima"
                    exit 1
                fi
            else
                warn_msg "Proceeding without Colima. This may cause issues with Docker on Apple Silicon."
            fi
        else
            success_msg "Colima is running"
        fi
    fi
fi

# Check if Oracle DB container is running
echo "Checking Oracle database container status..." | tee -a $LOG_FILE
debug_msg "Running: docker ps | grep -i oracle | grep -i database"
ORACLE_CONTAINER=$(docker ps | grep -i oracle | grep -i database)
debug_msg "ORACLE_CONTAINER='$ORACLE_CONTAINER'"

if [ -z "$ORACLE_CONTAINER" ]; then
    warn_msg "Oracle database container is not running!"
    echo "The Oracle database is required for WebLogic domain to function properly with VBMS." | tee -a $LOG_FILE
    
    echo "Do you want to start the Oracle database container now? [y/n]:" | tee -a $LOG_FILE
    read -r START_DB
    if [[ "$START_DB" =~ ^[Yy]$ ]]; then
        echo "Starting Oracle database container..." | tee -a $LOG_FILE
        
        # First try to start an existing but stopped container
        STOPPED_CONTAINER=$(docker ps -a | grep -i oracle | grep -i database | awk '{print $1}' | head -1)
        
        if [ -n "$STOPPED_CONTAINER" ]; then
            debug_msg "Found stopped container: $STOPPED_CONTAINER"
            echo "Starting existing Oracle container: $STOPPED_CONTAINER" | tee -a $LOG_FILE
            docker start $STOPPED_CONTAINER
            
            if [ $? -eq 0 ]; then
                success_msg "Started existing Oracle database container"
            else
                error_msg "Failed to start existing Oracle container"
                # Continue anyway as this is not fatal
            fi
        else
            debug_msg "No existing Oracle container found, checking for images"
            echo "No existing Oracle database container found, checking for images..." | tee -a $LOG_FILE
            
            # Check if the Oracle image exists
            if docker images | grep -q -E "oracle.*19\.3\.0|vbms/oracle"; then
                success_msg "Found Oracle database image"
                
                # Try to use the standard Oracle image first, then fallback to VBMS image
                if docker images | grep -q "oracledb19c/oracle.19.3.0-ee"; then
                    echo "Using official Oracle 19c image..." | tee -a $LOG_FILE
                    docker run -d --name oracle-database -p 1521:1521 oracledb19c/oracle.19.3.0-ee
                elif docker images | grep -q "vbms/oracle"; then
                    echo "Using VBMS Oracle image..." | tee -a $LOG_FILE
                    docker run -d --name oracle-database -p 1521:1521 vbms/oracle:latest
                fi
                
                if [ $? -eq 0 ]; then
                    success_msg "Started new Oracle database container"
                else
                    error_msg "Failed to start new Oracle container"
                    # Continue anyway as this is not fatal
                fi
                
                echo "Waiting for database initialization..." | tee -a $LOG_FILE
                echo "This may take some time..." | tee -a $LOG_FILE
                sleep 20
            else
                warn_msg "Oracle database image not found"
                echo "You only need to download the image once with:" | tee -a $LOG_FILE
                echo "docker pull -a oracledb19c/oracle.19.3.0-ee" | tee -a $LOG_FILE
                echo "" | tee -a $LOG_FILE
                warn_msg "Continuing domain creation, but database features won't work"
            fi
        fi
    else
        warn_msg "Proceeding without Oracle database. Some WebLogic features may not work properly."
    fi
else
    success_msg "Oracle database container is running: $ORACLE_CONTAINER"
fi

# Check if WebLogic is installed in the standardized Oracle directory
debug_msg "Checking WebLogic installation path: ${ORACLE_HOME}/wlserver"
debug_msg "Directory exists: $(if [ -d "${ORACLE_HOME}/wlserver" ]; then echo "Yes"; else echo "No"; fi)"

if [ ! -d "${ORACLE_HOME}/wlserver" ]; then
    error_msg "WebLogic not installed at: ${ORACLE_HOME}/wlserver"
    echo "WebLogic must be installed in the Oracle standardized directory: ${ORACLE_HOME}" | tee -a $LOG_FILE
    echo "No deviations from this directory structure are permitted." | tee -a $LOG_FILE
    
    # Instead of exiting, ask if we should proceed with dry run anyway
    if [ "$DRY_RUN" = "true" ]; then
        warn_msg "In DRY RUN mode - continuing despite missing WebLogic installation"
    else
        echo "Would you like to continue anyway (not recommended)? [y/n]:" | tee -a $LOG_FILE
        read -r CONTINUE_ANYWAY
        
        if [[ ! "$CONTINUE_ANYWAY" =~ ^[Yy]$ ]]; then
            echo "Please install WebLogic in the correct location first." | tee -a $LOG_FILE
            exit 1
        else
            warn_msg "Continuing despite missing WebLogic installation. This will likely fail."
        fi
    fi
else
    success_msg "Found WebLogic installation at: ${ORACLE_HOME}/wlserver"
fi

# Check if Java is available from specified JDK
debug_msg "Checking for JDK at $JDK_PATH"
debug_msg "JDK directory exists: $(if [ -d "$JDK_PATH" ]; then echo "Yes"; else echo "No"; fi)"

if [ ! -d "$JDK_PATH" ]; then
    warn_msg "Specified JDK not found at: $JDK_PATH"
    
    # Try to find Java 8 as a fallback
    debug_msg "Trying to find Java 8 as fallback"
    if /usr/libexec/java_home -v 1.8 &>/dev/null; then
        JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
        success_msg "Using system Java 8: $JAVA_HOME"
    else
        warn_msg "Java 8 not available. Using whatever Java is in PATH."
        
        # Check if any Java is available
        if command -v java &>/dev/null; then
            JAVA_PATH=$(which java)
            JAVA_HOME=${JAVA_PATH%/bin/java}
            warn_msg "Using Java from PATH: $JAVA_HOME"
            
            # Check Java version
            JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d '"' -f 2)
            debug_msg "Java version: $JAVA_VERSION"
            
            # Warn if not Java 8
            if [[ ! "$JAVA_VERSION" =~ ^1\.8\. ]]; then
                warn_msg "Using non-Java 8 version: $JAVA_VERSION. This may cause issues with WebLogic."
            fi
        else
            error_msg "No Java found in PATH. Domain creation cannot continue."
            exit 1
        fi
    fi
else
    JAVA_HOME="$JDK_PATH"
    success_msg "Using specified JDK: $JAVA_HOME"
fi

# Export environment variables
export JAVA_HOME
export PATH="${JAVA_HOME}/bin:${PATH}"
export ORACLE_HOME="${ORACLE_HOME}"
export MW_HOME="${ORACLE_HOME}"
export WL_HOME="${ORACLE_HOME}/wlserver"
export DOMAINS="${ORACLE_HOME}/user_projects/domains"

# Verify Java version
echo "Using Java:" | tee -a $LOG_FILE
java -version 2>&1 | tee -a $LOG_FILE
debug_msg "Java version check complete"

# Define CREATE_DOMAIN variable explicitly to avoid unbound variable errors
CREATE_DOMAIN=true

# Check if domain already exists
if [ -f "${DOMAIN_HOME}/config/config.xml" ]; then
    warn_msg "WebLogic domain already exists at ${DOMAIN_HOME}"
    if [ "$DRY_RUN" = "true" ]; then
        debug_msg "DRY RUN - would prompt to remove existing domain"
    else
        echo "Would you like to remove it and create a new one? [y/n]:" | tee -a $LOG_FILE
        read -r REMOVE_DOMAIN
        
        if [[ "$REMOVE_DOMAIN" =~ ^[Yy]$ ]]; then
            echo "Removing existing domain..." | tee -a $LOG_FILE
            rm -rf "${DOMAIN_HOME}"
            success_msg "Removed existing domain"
        else
            echo "Using existing domain (skipping domain creation)" | tee -a $LOG_FILE
            CREATE_DOMAIN=false
        fi
    fi
else
    debug_msg "No existing domain found, will create new one"
    CREATE_DOMAIN=true
fi

debug_msg "CREATE_DOMAIN=$CREATE_DOMAIN"

# Create domain if needed
if [ "$CREATE_DOMAIN" != "false" ]; then
    echo "\n====================================================" | tee -a $LOG_FILE
    echo "Creating WebLogic domain..." | tee -a $LOG_FILE
    echo "====================================================" | tee -a $LOG_FILE
    echo "Domain Home: ${DOMAIN_HOME}" | tee -a $LOG_FILE
    echo "Domain Name: ${DOMAIN_NAME}" | tee -a $LOG_FILE
    echo "Admin Server: ${ADMIN_SERVER_NAME} on port ${ADMIN_PORT}" | tee -a $LOG_FILE
    echo "====================================================" | tee -a $LOG_FILE
    
    # Create domain parent directories
    if [ "$DRY_RUN" = "true" ]; then
        debug_msg "DRY RUN - would create directory: ${DOMAIN_HOME}"
    else
        debug_msg "Creating domain directory: ${DOMAIN_HOME}"
        mkdir -p "${DOMAIN_HOME}"
        if [ $? -ne 0 ]; then
            error_msg "Failed to create domain directory: ${DOMAIN_HOME}"
            echo "Check permissions and try again." | tee -a $LOG_FILE
            exit 1
        fi
    fi
    
    # Find weblogic.jar in the expected location
    WEBLOGIC_JAR="${WL_HOME}/server/lib/weblogic.jar"
    
    if [ ! -f "$WEBLOGIC_JAR" ]; then
        warn_msg "Could not find weblogic.jar at ${WEBLOGIC_JAR}"
        
        # Try to find it in alternative locations
        debug_msg "Searching for weblogic.jar in alternative locations"
        ALT_JAR=$(find $ORACLE_HOME -name weblogic.jar -type f 2>/dev/null | head -1)
        
        if [ -n "$ALT_JAR" ]; then
            WEBLOGIC_JAR="$ALT_JAR"
            success_msg "Found alternative weblogic.jar at: $WEBLOGIC_JAR"
        else
            if [ "$DRY_RUN" = "true" ]; then
                warn_msg "DRY RUN - continuing despite missing weblogic.jar"
                WEBLOGIC_JAR="${WL_HOME}/server/lib/weblogic.jar"
            else
                error_msg "Could not find weblogic.jar anywhere in ${ORACLE_HOME}"
                exit 1
            fi
        fi
    else
        success_msg "Found weblogic.jar at: $WEBLOGIC_JAR"
    fi
    
    # Create domain creation Python script
    DOMAIN_SCRIPT="/tmp/create_domain_fixed.py"
    debug_msg "Creating domain script at: $DOMAIN_SCRIPT"

    cat > "${DOMAIN_SCRIPT}" << 'EOF'
# Domain creation script for WebLogic
import os, sys

# Get environment variables with fallbacks
def getEnv(key, default):
    value = os.environ.get(key)
    if value is None:
        print('WARNING: Environment variable {} not set, using default: {}'.format(key, default))
        return default
    return value

# Read environment variables
domainHome = getEnv('DOMAIN_HOME', '/Users/Username/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV')
domainName = getEnv('DOMAIN_NAME', 'P2-DEV')
adminName = getEnv('ADMIN_SERVER_NAME', 'AdminServer')
adminUsername = getEnv('ADMIN_USERNAME', 'weblogic')
adminPassword = getEnv('ADMIN_PASSWORD', 'weblogic1')
adminPort = int(getEnv('ADMIN_PORT', '7001'))
javaHome = getEnv('JAVA_HOME', '/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home')

print('Creating domain with:')
print('Domain Home: ' + domainHome)
print('Domain Name: ' + domainName)
print('Admin Server: ' + adminName)
print('Java Home: ' + javaHome)

# Detect architecture
import subprocess
arch = subprocess.check_output(['uname', '-m']).strip().decode('utf-8')
isArm = 'arm64' in arch

try:
    # Load the template
    print('Loading domain template...')
    templatePath = os.path.join(os.environ.get('WL_HOME', ''), 'common/templates/wls/wls.jar')
    print('Template path: ' + templatePath)
    readTemplate(templatePath)
    print('Template loaded successfully')
    
    # Configure the Administration Server
    print('Configuring admin server...')
    cd('Servers/AdminServer')
    set('ListenPort', adminPort)
    set('Name', adminName)
    
    # Define the user password for weblogic
    print('Setting admin credentials...')
    cd('/Security/' + domainName + '/User/weblogic')
    cmo.setName(adminUsername)
    cmo.setPassword(adminPassword)
    
    # Set production mode
    print('Setting production mode...')
    setOption('ServerStartMode', 'prod')
    
    # Set Apple Silicon compatibility flags
    if isArm:
        print('ARM64 architecture detected, setting compatibility flags')
        setOption('JavaVendor', 'Sun')
        setOption('JavaHome', javaHome)
        setOption('AppLogDir', os.path.join(domainHome, 'servers', adminName, 'logs'))
    
    # Write the domain and close the template
    print('Writing domain...')
    setOption('OverwriteDomain', 'true')
    writeDomain(domainHome)
    closeTemplate()
    print('Domain written successfully to ' + domainHome)
    
except Exception as e:
    print('ERROR: Exception occurred during domain creation:')
    print(str(e))
    sys.exit(1)

# Exit WLST
exit()
EOF

    debug_msg "Created domain creation script at: ${DOMAIN_SCRIPT}"
    
    # Run WLST with the domain creation script
    echo "\nRunning domain creation script..." | tee -a $LOG_FILE
    
    # Set Apple Silicon specific configs if needed
    if [ "$(uname -m)" = "arm64" ]; then
        export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Dcom.sun.management.jmxremote"
        debug_msg "Set CONFIG_JVM_ARGS for Apple Silicon: $CONFIG_JVM_ARGS"
    fi
    
    # Run the WLST script to create the domain
    if [ "$DRY_RUN" = "true" ]; then
        success_msg "DRY RUN - not executing WLST script"
    else
        # Check if the wlst.sh script exists
        WLST_SCRIPT="${ORACLE_HOME}/oracle_common/common/bin/wlst.sh"
        debug_msg "WLST script path: $WLST_SCRIPT" 
        debug_msg "WLST script exists: $(if [ -f "$WLST_SCRIPT" ]; then echo "Yes"; else echo "No"; fi)"
        
        if [ ! -f "$WLST_SCRIPT" ]; then
            warn_msg "WLST script not found at expected location: $WLST_SCRIPT"
            
            # Try to find wlst.sh elsewhere
            ALT_WLST=$(find $ORACLE_HOME -name wlst.sh -type f 2>/dev/null | head -1)
            
            if [ -n "$ALT_WLST" ]; then
                WLST_SCRIPT="$ALT_WLST"
                success_msg "Found alternative wlst.sh at: $WLST_SCRIPT"
            else
                error_msg "Could not find wlst.sh anywhere in ${ORACLE_HOME}"
                exit 1
            fi
        fi
        
        # Execute WLST with proper environment
        debug_msg "Executing: ${WLST_SCRIPT} ${DOMAIN_SCRIPT}" 
        echo "Executing WLST to create domain..." | tee -a $LOG_FILE
        "${WLST_SCRIPT}" "${DOMAIN_SCRIPT}" | tee -a $LOG_FILE
        
        # Capture exit code
        WLST_EXIT_CODE=${PIPESTATUS[0]}
        debug_msg "WLST exit code: $WLST_EXIT_CODE"
        
        if [ $WLST_EXIT_CODE -ne 0 ]; then
            error_msg "WLST domain creation failed with exit code: $WLST_EXIT_CODE"
            echo "Check the log file for details: $LOG_FILE" | tee -a $LOG_FILE
        else
            success_msg "WLST completed successfully"
        fi
    fi
    
    # Check if domain creation was successful
    if [ "$DRY_RUN" = "true" ]; then
        success_msg "DRY RUN - domain would be created at: ${DOMAIN_HOME}"
        success_msg "DRY RUN - would create apps directory at: ${APPS_DIR}"
        success_msg "DRY RUN - would create boot.properties for automatic login"
        success_msg "DRY RUN - would set execute permissions on domain scripts"
    elif [ -f "${DOMAIN_HOME}/config/config.xml" ]; then
        success_msg "Domain created successfully at: ${DOMAIN_HOME}"
        
        # Create apps directory if it doesn't exist
        debug_msg "Creating apps directory: $APPS_DIR"
        mkdir -p ${APPS_DIR}
        success_msg "Created apps directory at: ${APPS_DIR}"
        
        # Create boot.properties file for automated startup
        debug_msg "Creating boot.properties for automatic login"
        mkdir -p ${DOMAIN_HOME}/servers/${ADMIN_SERVER_NAME}/security
        cat > ${DOMAIN_HOME}/servers/${ADMIN_SERVER_NAME}/security/boot.properties << EOF
username=${ADMIN_USERNAME}
password=${ADMIN_PASSWORD}
EOF
        success_msg "Created boot.properties for automatic login"
        
        # Set execute permissions on domain scripts
        debug_msg "Setting execute permissions on domain scripts"
        chmod +x ${DOMAIN_HOME}/bin/*.sh
        success_msg "Set execute permissions on domain scripts"
        
    else
        error_msg "Domain creation failed!"
        error_msg "config.xml not found at ${DOMAIN_HOME}/config/config.xml"
        exit 1
    fi
fi

# Print next steps
echo "\n====================================================" | tee -a $LOG_FILE
echo "Domain Creation Completed" | tee -a $LOG_FILE
echo "====================================================" | tee -a $LOG_FILE
echo "To start the WebLogic Admin Server, run:" | tee -a $LOG_FILE
echo "${DOMAIN_HOME}/bin/startWebLogic.sh" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "Or use the convenience script:" | tee -a $LOG_FILE
echo "${HOME}/dev/local-arm-mac/scripts/weblogic/start-weblogic.sh" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "Admin Console URL: http://${ADMIN_HOST}:${ADMIN_PORT}/console" | tee -a $LOG_FILE
echo "Username: ${ADMIN_USERNAME}" | tee -a $LOG_FILE
echo "Password: ${ADMIN_PASSWORD}" | tee -a $LOG_FILE
echo "====================================================" | tee -a $LOG_FILE

success_msg "Script completed successfully!"
echo "Log file saved to: $LOG_FILE" | tee -a $LOG_FILE
