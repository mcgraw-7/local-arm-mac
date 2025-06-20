#!/bin/zsh

# Check WebLogic Status Script
# This script checks:
# 1. WebLogic server status
# 2. Domain status
# 3. Deployed modules
# 4. JDBC data sources
# 5. JMS resources

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if WebLogic is installed
check_weblogic_install() {
    echo "Checking WebLogic installation..."
    
    # Check for WebLogic home
    if [ -z "$WL_HOME" ]; then
        if [ -d "$HOME/dev/Oracle/Middleware/Oracle_Home/wlserver" ]; then
            export WL_HOME="$HOME/dev/Oracle/Middleware/Oracle_Home/wlserver"
            echo -e "${GREEN}✅ Found WebLogic at: $WL_HOME${NC}"
        else
            echo -e "${RED}❌ WebLogic installation not found${NC}"
            echo "Please ensure WebLogic is installed at: $HOME/dev/Oracle/Middleware/Oracle_Home/wlserver"
            return 1
        fi
    else
        echo -e "${GREEN}✅ WebLogic home set to: $WL_HOME${NC}"
    fi

    # Check for Oracle Common
    if [ -d "$HOME/dev/Oracle/Middleware/Oracle_Home/oracle_common" ]; then
        export ORACLE_COMMON="$HOME/dev/Oracle/Middleware/Oracle_Home/oracle_common"
        echo -e "${GREEN}✅ Found Oracle Common at: $ORACLE_COMMON${NC}"
    else
        echo -e "${RED}❌ Oracle Common not found${NC}"
        return 1
    fi
}

# Function to check if domain exists
check_domain() {
    echo "Checking WebLogic domain..."
    
    # Check for domain directory
    if [ -z "$DOMAIN_HOME" ]; then
        if [ -d "$HOME/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV" ]; then
            export DOMAIN_HOME="$HOME/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV"
            echo -e "${GREEN}✅ Found domain at: $DOMAIN_HOME${NC}"
        else
            echo -e "${RED}❌ Domain not found${NC}"
            echo "Please ensure domain exists at: $HOME/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV"
            return 1
        fi
    else
        echo -e "${GREEN}✅ Domain home set to: $DOMAIN_HOME${NC}"
    fi
}

# Function to check server status
check_server_status() {
    echo "Checking WebLogic server status..."
    
    # Check if server is running
    if pgrep -f "weblogic.Server" > /dev/null; then
        echo -e "${GREEN}✅ WebLogic server is running${NC}"
        
        # Check if we can connect to the admin console
        if curl -s http://localhost:7001/console > /dev/null; then
            echo -e "${GREEN}✅ Admin console is accessible${NC}"
        else
            echo -e "${YELLOW}⚠️  Admin console is not accessible${NC}"
        fi
    else
        echo -e "${RED}❌ WebLogic server is not running${NC}"
    fi
}

# Function to check deployed applications
check_deployed_apps() {
    echo "Checking deployed applications..."
    
    # Check if WLST is available
    if [ -f "$ORACLE_COMMON/common/bin/wlst.sh" ]; then
        # Create temporary WLST script
        TEMP_SCRIPT=$(mktemp)
        cat > "$TEMP_SCRIPT" << 'EOF'
connect('weblogic', 'weblogic1', 't3://localhost:7001')
print('\nDeployed Applications:')
print('=====================')
apps = cmo.getAppDeployments()
if len(apps) == 0:
    print('No applications deployed')
else:
    for app in apps:
        print('Application: ' + app.getName())
        print('  State: ' + app.getState())
        print('  Health: ' + app.getHealth())
        print('  Type: ' + app.getType())
        print('  Source: ' + app.getSourcePath())
        print('  Target: ' + str(app.getTargets()))
        print('---')
exit()
EOF
        
        echo "Deployed Applications:"
        "$ORACLE_COMMON/common/bin/wlst.sh" "$TEMP_SCRIPT" 2>/dev/null | grep -v "Initializing WebLogic Scripting Tool"
        rm "$TEMP_SCRIPT"
    else
        echo -e "${YELLOW}⚠️  WLST not found at: $ORACLE_COMMON/common/bin/wlst.sh${NC}"
    fi
}

# Function to check JDBC data sources
check_jdbc() {
    echo "Checking JDBC data sources..."
    
    # Check if WLST is available
    if [ -f "$ORACLE_COMMON/common/bin/wlst.sh" ]; then
        # Create temporary WLST script
        TEMP_SCRIPT=$(mktemp)
        cat > "$TEMP_SCRIPT" << 'EOF'
connect('weblogic', 'weblogic1', 't3://localhost:7001')
print('\nJDBC Data Sources:')
print('=================')
cd('/JDBCSystemResources')
ds = ls()
if len(ds) == 0:
    print('No JDBC data sources found')
else:
    for d in ds:
        print('Data Source: ' + d)
        cd('/JDBCSystemResources/' + d)
        state = get('State')
        print('  State: ' + state)
        cd('/JDBCSystemResources/' + d + '/JDBCResource/' + d + '/JDBCDriverParams/' + d + '/Properties/' + d)
        props = ls()
        if len(props) > 0:
            print('  Properties:')
            for p in props:
                print('    ' + p + ': ' + get(p))
        print('---')
exit()
EOF
        
        echo "JDBC Data Sources:"
        "$ORACLE_COMMON/common/bin/wlst.sh" "$TEMP_SCRIPT" 2>/dev/null | grep -v "Initializing WebLogic Scripting Tool"
        rm "$TEMP_SCRIPT"
    else
        echo -e "${YELLOW}⚠️  WLST not found at: $ORACLE_COMMON/common/bin/wlst.sh${NC}"
    fi
}

# Function to check JMS resources
check_jms() {
    echo "Checking JMS resources..."
    
    # Check if WLST is available
    if [ -f "$ORACLE_COMMON/common/bin/wlst.sh" ]; then
        # Create temporary WLST script
        TEMP_SCRIPT=$(mktemp)
        cat > "$TEMP_SCRIPT" << 'EOF'
connect('weblogic', 'weblogic1', 't3://localhost:7001')
print('\nJMS Resources:')
print('=============')
cd('/JMSSystemResources')
jms = ls()
if len(jms) == 0:
    print('No JMS resources found')
else:
    for j in jms:
        print('JMS Module: ' + j)
        cd('/JMSSystemResources/' + j)
        state = get('State')
        print('  State: ' + state)
        cd('/JMSSystemResources/' + j + '/JMSResource/' + j)
        queues = ls('Queues')
        topics = ls('Topics')
        if len(queues) > 0:
            print('  Queues:')
            for q in queues:
                print('    - ' + q)
        if len(topics) > 0:
            print('  Topics:')
            for t in topics:
                print('    - ' + t)
        print('---')
exit()
EOF
        
        echo "JMS Resources:"
        "$ORACLE_COMMON/common/bin/wlst.sh" "$TEMP_SCRIPT" 2>/dev/null | grep -v "Initializing WebLogic Scripting Tool"
        rm "$TEMP_SCRIPT"
    else
        echo -e "${YELLOW}⚠️  WLST not found at: $ORACLE_COMMON/common/bin/wlst.sh${NC}"
    fi
}

# Main execution
echo "=== WebLogic Status Check ==="

# Check WebLogic installation
check_weblogic_install || exit 1

# Check domain
check_domain || exit 1

# Check server status
check_server_status

# Check deployed applications
check_deployed_apps

# Check JDBC data sources
check_jdbc

# Check JMS resources
check_jms

echo -e "\n${GREEN}=== Status Check Complete ===${NC}" 