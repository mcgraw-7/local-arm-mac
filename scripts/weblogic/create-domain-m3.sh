#!/bin/zsh
# WebLogic Domain Creation Script for VBMS on M3 Mac with Oracle DB Verification
# This script creates a WebLogic domain after successful installation

set -e

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

echo "====================================================="
echo "WebLogic Domain Creation for VBMS on M3 Mac"
echo "====================================================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in PATH"
    echo "Please install Docker Desktop and try again"
    exit 1
fi

# Check if Oracle DB container is running
echo "Checking Oracle database container status..."
ORACLE_CONTAINER=$(docker ps | grep -i oracle | grep -i database)
if [ -z "$ORACLE_CONTAINER" ]; then
    echo "❌ WARNING: Oracle database container is not running!"
    echo "The Oracle database is required for WebLogic domain to function properly with VBMS."
    
    read -p "Do you want to start the Oracle database container now? (y/n): " START_DB
    if [[ "$START_DB" =~ ^[Yy]$ ]]; then
        echo "Starting Oracle database container..."
        
        # First try to start an existing but stopped container
        if docker start oracle-database &>/dev/null; then
            echo "✅ Started existing Oracle database container"
        else
            echo "No existing Oracle database container found, checking for VBMS Oracle image..."
            
            # Check if the VBMS Oracle image exists
            if docker images | grep -q "vbms/oracle"; then
                echo "Found VBMS Oracle image, starting new container..."
                docker run -d --name oracle-database -p 1521:1521 vbms/oracle:latest
                echo "✅ Started new Oracle database container"
            else
                echo "❌ VBMS Oracle database image not found"
                echo "Please build or pull the Oracle database image first"
                echo "Continuing domain creation, but some features may not work"
            fi
        fi
        
        echo "Waiting for database initialization..."
        echo "This may take some time..."
        sleep 45
    else
        echo "⚠️ Proceeding without Oracle database. Some WebLogic features may not work properly."
    fi
else
    echo "✅ Oracle database container is running: $ORACLE_CONTAINER"
fi

# Check if WebLogic is installed
if [ ! -d "${ORACLE_HOME}/wlserver" ]; then
    echo "❌ WebLogic not installed at: ${ORACLE_HOME}/wlserver"
    echo "Please run the installation script first."
    exit 1
else
    echo "✅ Found WebLogic installation at: ${ORACLE_HOME}/wlserver"
fi

# Check if Java is available from specified JDK
if [ ! -d "$JDK_PATH" ]; then
    echo "❌ Specified JDK not found at: $JDK_PATH"
    
    # Try to find Java 8 as a fallback
    if /usr/libexec/java_home -v 1.8 &>/dev/null; then
        JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
        echo "✅ Using system Java 8: $JAVA_HOME"
    else
        echo "❌ Java 8 not available. Domain creation cannot continue."
        exit 1
    fi
else
    JAVA_HOME="$JDK_PATH"
    echo "✅ Using specified JDK: $JAVA_HOME"
fi

# Export environment variables
export JAVA_HOME
export PATH="${JAVA_HOME}/bin:${PATH}"
export ORACLE_HOME="${ORACLE_HOME}"
export MW_HOME="${ORACLE_HOME}"
export WL_HOME="${ORACLE_HOME}/wlserver"
export DOMAINS="${ORACLE_HOME}/user_projects/domains"

# Verify Java version
echo "Using Java:"
java -version

# Check if domain already exists
if [ -f "${DOMAIN_HOME}/config/config.xml" ]; then
    echo "⚠️ WebLogic domain already exists at ${DOMAIN_HOME}"
    echo "Would you like to remove it and create a new one? [y/n]:"
    read -r REMOVE_DOMAIN
    
    if [[ "$REMOVE_DOMAIN" == "y" ]]; then
        echo "Removing existing domain..."
        rm -rf "${DOMAIN_HOME}"
        echo "✅ Removed existing domain"
    else
        echo "Using existing domain (skipping domain creation)"
        CREATE_DOMAIN=false
    fi
else
    CREATE_DOMAIN=true
fi

# Create domain if needed
if [ "$CREATE_DOMAIN" != "false" ]; then
    echo "\n====================================================="
    echo "Creating WebLogic domain..."
    echo "====================================================="
    echo "Domain Home: ${DOMAIN_HOME}"
    echo "Domain Name: ${DOMAIN_NAME}"
    echo "Admin Server: ${ADMIN_SERVER_NAME} on port ${ADMIN_PORT}"
    echo "====================================================="
    
    # Create domain parent directories
    mkdir -p "${DOMAIN_HOME}"
    
    # Find weblogic.jar in the expected location
    WEBLOGIC_JAR="${WL_HOME}/server/lib/weblogic.jar"
    
    if [ ! -f "$WEBLOGIC_JAR" ]; then
        echo "❌ Could not find weblogic.jar at ${WEBLOGIC_JAR}"
        exit 1
    fi
    echo "Found weblogic.jar at: $WEBLOGIC_JAR"
    
    # Create domain creation Python script
    DOMAIN_SCRIPT="/tmp/create_domain.py"

    cat > "${DOMAIN_SCRIPT}" << EOF
# Domain creation script for WebLogic
import os, sys

# Read command line arguments
domainHome = os.environ.get('DOMAIN_HOME')
domainName = os.environ.get('DOMAIN_NAME')
adminName = os.environ.get('ADMIN_SERVER_NAME')
adminUsername = os.environ.get('ADMIN_USERNAME')
adminPassword = os.environ.get('ADMIN_PASSWORD')
adminPort = int(os.environ.get('ADMIN_PORT'))

print('Creating domain with:')
print('Domain Home: ' + domainHome)
print('Domain Name: ' + domainName)
print('Admin Server: ' + adminName)

# Load the template
readTemplate('${WL_HOME}/common/templates/wls/wls.jar')

# Configure the Administration Server
cd('Servers/AdminServer')
set('ListenPort', adminPort)
set('Name', adminName)

# Define the user password for weblogic
cd('/Security/${DOMAIN_NAME}/User/weblogic')
cmo.setName(adminUsername)
cmo.setPassword(adminPassword)

# Set production mode
setOption('ServerStartMode', 'prod')

# Set Apple Silicon compatibility flags
if 'arm64' in os.popen('uname -m').read():
    print('ARM64 architecture detected, setting compatibility flags')
    setOption('JavaVendor', 'Sun')
    setOption('JavaHome', '${JAVA_HOME}')
    setOption('AppLogDir', '${DOMAIN_HOME}/servers/${ADMIN_SERVER_NAME}/logs')
    setOption('JavaHome', '${JAVA_HOME}')

# Write the domain and close the template
setOption('OverwriteDomain', 'true')
writeDomain(domainHome)
closeTemplate()

# Exit WLST
exit()
EOF

    echo "Created domain creation script at: ${DOMAIN_SCRIPT}"
    
    # Run WLST with the domain creation script
    echo "\nRunning domain creation script...\n"
    
    # Set Apple Silicon specific configs if needed
    if [ "$(uname -m)" = "arm64" ]; then
        export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Dcom.sun.management.jmxremote"
    fi
    
    # Run the WLST script to create the domain
    ${ORACLE_HOME}/oracle_common/common/bin/wlst.sh ${DOMAIN_SCRIPT}
    
    # Check if domain creation was successful
    if [ -f "${DOMAIN_HOME}/config/config.xml" ]; then
        echo "✅ Domain created successfully at: ${DOMAIN_HOME}"
        
        # Create apps directory if it doesn't exist
        mkdir -p ${APPS_DIR}
        echo "✅ Created apps directory at: ${APPS_DIR}"
        
        # Create boot.properties file for automated startup
        mkdir -p ${DOMAIN_HOME}/servers/${ADMIN_SERVER_NAME}/security
        cat > ${DOMAIN_HOME}/servers/${ADMIN_SERVER_NAME}/security/boot.properties << EOF
username=${ADMIN_USERNAME}
password=${ADMIN_PASSWORD}
EOF
        echo "✅ Created boot.properties for automatic login"
        
        # Set execute permissions on domain scripts
        chmod +x ${DOMAIN_HOME}/bin/*.sh
        echo "✅ Set execute permissions on domain scripts"
        
    else
        echo "❌ Domain creation failed!"
        exit 1
    fi
fi

# Print next steps
echo "\n====================================================="
echo "Domain Creation Completed"
echo "====================================================="
echo "To start the WebLogic Admin Server, run:"
echo "${DOMAIN_HOME}/bin/startWebLogic.sh"
echo ""
echo "Or use the convenience script:"
echo "${HOME}/dev/local-arm-mac/scripts/weblogic/start-weblogic.sh"
echo ""
echo "Admin Console URL: http://${ADMIN_HOST}:${ADMIN_PORT}/console"
echo "Username: ${ADMIN_USERNAME}"
echo "Password: ${ADMIN_PASSWORD}"
echo "====================================================="
