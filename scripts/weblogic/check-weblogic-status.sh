#!/bin/zsh
# check-weblogic-status.sh - Quick diagnostic script to check WebLogic environment on Apple Silicon (M1/M2/M3) Mac
# without modifying or restarting the environment

# Color definitions for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set environment variables with standardized paths
export MIDDLEWARE_HOME=${HOME}/dev/Oracle/Middleware/Oracle_Home
export MW_HOME=$MIDDLEWARE_HOME
export DOMAIN_HOME=$MIDDLEWARE_HOME/user_projects/domains/P2-DEV
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=$JAVA_HOME/bin:$PATH
ADMIN_PORT=7001
NM_PORT=5556

echo -e "${BLUE}========================================================================${NC}"
echo -e "${GREEN}WebLogic Status Check Tool for Apple Silicon Mac${NC}"
echo -e "${BLUE}========================================================================${NC}"

# Check if a port is in use
check_port_in_use() {
  local port=$1
  lsof -i:$port > /dev/null 2>&1
  return $?
}

# Check if WebLogic is running
check_weblogic() {
  ps -ef | grep -v grep | grep "weblogic.Server" > /dev/null
  return $?
}

# Check if Node Manager is running
check_nodemanager() {
  ps -ef | grep -v grep | grep "NodeManager" > /dev/null
  return $?
}

# Check for BouncyCastle libraries (common source of conflicts)
check_bouncy_castle() {
  echo -e "${BLUE}Checking for BouncyCastle libraries...${NC}"
  
  # Find WebLogic's BouncyCastle version
  WL_BC_JAR=$(find "$MW_HOME" -name "bcprov-jdk15on*.jar" | head -1)
  
  if [ -n "$WL_BC_JAR" ]; then
    WL_BC_VERSION=$(echo "$WL_BC_JAR" | sed -E 's/.*bcprov-jdk15on-([0-9.]+)\.jar/\1/')
    echo -e "${GREEN}WebLogic BouncyCastle version:${NC} $WL_BC_VERSION ($WL_BC_JAR)"
  else
    echo -e "${YELLOW}No WebLogic BouncyCastle library found${NC}"
  fi
  
  # Check for any deployed app using a different BouncyCastle version
  if [ -d "$DEPLOYED_DIR" ]; then
    echo -e "${BLUE}Checking deployed applications for BouncyCastle libraries...${NC}"
    APP_BC_JARS=$(find "$DEPLOYED_DIR" -name "bcprov-jdk15on*.jar" 2>/dev/null)
    
    if [ -n "$APP_BC_JARS" ]; then
      echo -e "${YELLOW}Found BouncyCastle libraries in deployed applications:${NC}"
      echo "$APP_BC_JARS" | while read -r jar_path; do
        APP_BC_VERSION=$(echo "$jar_path" | sed -E 's/.*bcprov-jdk15on-([0-9.]+)\.jar/\1/')
        APP_NAME=$(echo "$jar_path" | awk -F'/' '{print $(NF-3)}')
        echo -e "  - $APP_NAME: version $APP_BC_VERSION"
        
        if [ -n "$WL_BC_VERSION" ] && [ "$APP_BC_VERSION" != "$WL_BC_VERSION" ]; then
          echo -e "  ${RED}⚠ Version conflict with WebLogic ($WL_BC_VERSION)${NC}"
          echo -e "    This may cause ClassCastExceptions or NoSuchMethodErrors"
        fi
      done
    else
      echo -e "${GREEN}✓ No BouncyCastle libraries found in deployed applications${NC}"
    fi
  fi
}

# Function to analyze thread dumps if requested
analyze_thread_dump() {
  if [ -z "$WEBLOGIC_PID" ] || ! ps -p "$WEBLOGIC_PID" > /dev/null 2>&1; then
    echo -e "${RED}WebLogic process is not running. Cannot generate thread dump.${NC}"
    return 1
  fi
  
  echo -e "${BLUE}Generating WebLogic thread dump for analysis...${NC}"
  THREAD_DUMP_FILE="/tmp/weblogic_thread_dump_$(date +%Y%m%d_%H%M%S).txt"
  
  if command -v jstack > /dev/null 2>&1; then
    jstack -l $WEBLOGIC_PID > "$THREAD_DUMP_FILE" 2>/dev/null
    if [ $? -eq 0 ] && [ -s "$THREAD_DUMP_FILE" ]; then
      echo -e "${GREEN}Thread dump successfully generated at:${NC} $THREAD_DUMP_FILE"
      
      # Count number of threads
      THREAD_COUNT=$(grep -c "^\"" "$THREAD_DUMP_FILE")
      echo -e "Total threads: $THREAD_COUNT"
      
      # Check for deadlocks
      if grep -q "Found .* deadlock" "$THREAD_DUMP_FILE"; then
        echo -e "${RED}⚠ DEADLOCK DETECTED! See thread dump for details.${NC}"
        grep -A 50 "Found .* deadlock" "$THREAD_DUMP_FILE"
      else
        echo -e "${GREEN}✓ No deadlocks detected${NC}"
      fi
      
      # Look for BLOCKED threads
      BLOCKED_COUNT=$(grep -c "State: BLOCKED" "$THREAD_DUMP_FILE")
      if [ $BLOCKED_COUNT -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found $BLOCKED_COUNT blocked threads${NC}"
        echo -e "Sample of blocked threads:"
        grep -A 2 -B 1 "State: BLOCKED" "$THREAD_DUMP_FILE" | head -10
      else
        echo -e "${GREEN}✓ No blocked threads detected${NC}"
      fi
      
      # Show most common thread states
      echo -e "${BLUE}Thread state summary:${NC}"
      grep "State: " "$THREAD_DUMP_FILE" | sort | uniq -c | sort -nr
      
      return 0
    else
      echo -e "${YELLOW}Failed to generate thread dump with jstack${NC}"
    fi
  else
    echo -e "${YELLOW}jstack not available. Cannot generate thread dump.${NC}"
  fi
  
  return 1
}

# Check WebLogic process
echo -e "${BLUE}Checking for WebLogic processes...${NC}"
if check_weblogic; then
  echo -e "${GREEN}✓ WebLogic server process is running${NC}"
  # Get the process details
  WEBLOGIC_PID=$(ps -ef | grep -v grep | grep "weblogic.Server" | awk '{print $2}')
  echo -e "  Process ID: $WEBLOGIC_PID"
  
  # Check how long it has been running
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS - use ps -o etime
    UPTIME=$(ps -o etime= -p $WEBLOGIC_PID)
    echo -e "  Process uptime: $UPTIME"
  fi
  
  # Check memory usage - expanded with more metrics
  RSS_KB=$(ps -o rss= -p $WEBLOGIC_PID)
  RSS_MB=$(($RSS_KB / 1024))
  VSZ_KB=$(ps -o vsz= -p $WEBLOGIC_PID)
  VSZ_MB=$(($VSZ_KB / 1024))
  
  echo -e "  Memory usage (RSS): $RSS_MB MB"
  echo -e "  Virtual memory size: $VSZ_MB MB"
  
  # Try to get Java heap info using jstat if available
  if command -v jstat >/dev/null 2>&1; then
    echo -e "${BLUE}Analyzing JVM heap metrics...${NC}"
    JSTAT_OUTPUT=$(jstat -gc $WEBLOGIC_PID 2>/dev/null)
    if [ $? -eq 0 ]; then
      echo -e "  JVM Heap Summary:"
      # Parse used and total heap
      HEAP_USED=$(jstat -gc $WEBLOGIC_PID | tail -1 | awk '{print ($3+$4+$6+$8)/1024}')
      HEAP_TOTAL=$(jstat -gc $WEBLOGIC_PID | tail -1 | awk '{print ($1+$2+$5+$7)/1024}')
      HEAP_PERCENT=$((${HEAP_USED%.*}*100/${HEAP_TOTAL%.*}))
      
      echo -e "  - Heap used: ${HEAP_USED%.*} MB of ${HEAP_TOTAL%.*} MB (${HEAP_PERCENT}%)"
      
      # Check if heap usage is high
      if [ $HEAP_PERCENT -gt 80 ]; then
        echo -e "  ${YELLOW}⚠ High heap usage detected (${HEAP_PERCENT}%)${NC}"
      fi
      
      # Get garbage collection info
      GC_COUNT=$(jstat -gc $WEBLOGIC_PID | tail -1 | awk '{print $13+$15}')
      GC_TIME=$(jstat -gc $WEBLOGIC_PID | tail -1 | awk '{print $14+$16}')
      
      echo -e "  - GC count: $GC_COUNT"
      echo -e "  - Total GC time: $GC_TIME seconds"
    else
      echo -e "  ${YELLOW}Unable to get detailed JVM metrics${NC}"
    fi
  fi
else
  echo -e "${RED}✗ No WebLogic server process found${NC}"
fi

# Check Node Manager process
echo -e "${BLUE}Checking for NodeManager process...${NC}"
if check_nodemanager; then
  echo -e "${GREEN}✓ NodeManager process is running${NC}"
  # Get the process details
  NM_PID=$(ps -ef | grep -v grep | grep "NodeManager" | awk '{print $2}')
  echo -e "  Process ID: $NM_PID"
else
  echo -e "${RED}✗ No NodeManager process found${NC}"
fi

# Check ports
echo -e "${BLUE}Checking WebLogic ports...${NC}"
echo -n "  Admin Server port (7001): "
if check_port_in_use 7001; then
  echo -e "${GREEN}IN USE ✓${NC}"
  ADMIN_PORT_PID=$(lsof -ti:7001)
  echo -e "    Used by process: $ADMIN_PORT_PID"
else
  echo -e "${RED}NOT IN USE ✗${NC}"
fi

echo -n "  Node Manager port (5556): "
if check_port_in_use 5556; then
  echo -e "${GREEN}IN USE ✓${NC}"
  NM_PORT_PID=$(lsof -ti:5556)
  echo -e "    Used by process: $NM_PORT_PID"
else
  echo -e "${RED}NOT IN USE ✗${NC}"
fi

# Check HTTP connectivity
echo -e "${BLUE}Checking HTTP connectivity to WebLogic...${NC}"
HTTP_RESULT=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:7001/ 2>/dev/null || echo "Connection failed")
if [[ "$HTTP_RESULT" == "200" ]]; then
  echo -e "${GREEN}✓ WebLogic HTTP endpoint is responding (HTTP 200)${NC}"
elif [[ "$HTTP_RESULT" == "404" ]]; then
  echo -e "${GREEN}✓ WebLogic is responding with HTTP 404 (normal for root context)${NC}"
elif [[ "$HTTP_RESULT" =~ ^[0-9]+$ ]]; then
  echo -e "${YELLOW}⚠ WebLogic HTTP endpoint returned status code: $HTTP_RESULT${NC}"
else
  echo -e "${RED}✗ Unable to connect to WebLogic HTTP endpoint${NC}"
fi

# Check admin console
echo -e "${BLUE}Checking Admin Console availability...${NC}"
CONSOLE_RESULT=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:7001/console/ 2>/dev/null || echo "Connection failed")
if [[ "$CONSOLE_RESULT" == "200" || "$CONSOLE_RESULT" == "302" ]]; then
  echo -e "${GREEN}✓ Admin Console appears to be available${NC}"
else
  echo -e "${RED}✗ Admin Console is not responding correctly${NC}"
fi

# Check deployment status if WebLogic is running
if check_weblogic; then
  echo -e "${BLUE}Checking deployed applications...${NC}"
  
  # Check directory for deployed apps
  DEPLOYED_DIR="$DOMAIN_HOME/servers/AdminServer/tmp/_WL_user"
  if [ -d "$DEPLOYED_DIR" ]; then
    # Skip . and .. directory entries when counting apps
    DEPLOYED_APPS=$(find "$DEPLOYED_DIR" -maxdepth 1 -type d | grep -v "^\.$\|^\.\.$" | wc -l)
    echo -e "${GREEN}Found $DEPLOYED_APPS deployed application(s):${NC}"
    # List only actual application directories, not . and ..
    find "$DEPLOYED_DIR" -maxdepth 1 -type d | grep -v "$DEPLOYED_DIR$" | while read -r app_dir; do
      app_name=$(basename "$app_dir")
      app_size=$(du -sh "$app_dir" | cut -f1)
      echo -e "  - $app_name ($app_size)"
    done
    
    # Specifically check for VBMS apps
    echo -e "${BLUE}Looking for VBMS applications...${NC}"
    if ls -la "$DEPLOYED_DIR" | grep -i "vbms-core" > /dev/null; then
      echo -e "${GREEN}✓ vbms-core app appears to be deployed${NC}"
      
      # Check HTTP endpoint for vbms-core
      VBMS_CORE_RESULT=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:7001/vbms-core/ 2>/dev/null || echo "Connection failed")
      if [[ "$VBMS_CORE_RESULT" =~ ^[23][0-9][0-9]$ ]]; then
        echo -e "  ${GREEN}✓ vbms-core app is responding (HTTP $VBMS_CORE_RESULT)${NC}"
      else
        echo -e "  ${RED}✗ vbms-core app is not responding correctly${NC}"
      fi
    else
      echo -e "${RED}✗ vbms-core app does not appear to be deployed${NC}"
    fi
    
    if ls -la "$DEPLOYED_DIR" | grep -i "vbms-ui" > /dev/null; then
      echo -e "${GREEN}✓ vbms-ui app appears to be deployed${NC}"
      
      # Check HTTP endpoint for vbms-ui
      VBMS_UI_RESULT=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:7001/vbms-ui/ 2>/dev/null || echo "Connection failed")
      if [[ "$VBMS_UI_RESULT" =~ ^[23][0-9][0-9]$ ]]; then
        echo -e "  ${GREEN}✓ vbms-ui app is responding (HTTP $VBMS_UI_RESULT)${NC}"
      else
        echo -e "  ${RED}✗ vbms-ui app is not responding correctly${NC}"
      fi
    else
      echo -e "${RED}✗ vbms-ui app does not appear to be deployed${NC}"
    fi
  else
    echo -e "${RED}✗ No deployed applications directory found${NC}"
  fi
fi

# Check recent logs
echo -e "${BLUE}Checking recent WebLogic logs...${NC}"
LOG_FILE="$DOMAIN_HOME/servers/AdminServer/logs/AdminServer.log"
if [ -f "$LOG_FILE" ]; then
  echo -e "${GREEN}✓ Log file found: $LOG_FILE${NC}"
  echo -e "${YELLOW}Last 5 log entries:${NC}"
  tail -5 "$LOG_FILE"
  
  # Check for errors in the logs - more precise filtering to avoid false positives
  echo -e "${BLUE}Checking for recent errors in logs...${NC}"
  
  # Filter out known informational messages that contain "error" or "exception" but aren't actual errors
  # BEA-190156 is "no compliance or validation errors found"
  # Also filter out severity-value: 64 which is INFO level
  ERROR_COUNT=$(grep -i "error\|exception\|failure" "$LOG_FILE" | grep -v "BEA-190156" | grep -v "\[severity-value: 64\]" | grep -E 'ERROR|ALERT|CRITICAL|SEVERE|WARNING|<Error>' | tail -50 | wc -l)
  
  if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "${RED}Found $ERROR_COUNT recent true errors/exceptions in the logs.${NC}"
    echo -e "${YELLOW}Most recent errors:${NC}"
    grep -i "error\|exception\|failure" "$LOG_FILE" | grep -v "BEA-190156" | grep -v "\[severity-value: 64\]" | grep -E 'ERROR|ALERT|CRITICAL|SEVERE|WARNING|<Error>' | tail -3
  else
    echo -e "${GREEN}✓ No significant errors found in the logs${NC}"
  fi
else
  echo -e "${RED}✗ Log file not found at $LOG_FILE${NC}"
fi

# Run a basic BouncyCastle check
check_bouncy_castle

echo -e "${BLUE}========================================================================${NC}"
echo -e "${GREEN}Status Check Complete${NC}"
echo -e "${BLUE}========================================================================${NC}"

# Add an optional interactive menu for advanced diagnostics
echo -e "${BLUE}Would you like to perform additional diagnostics? [y/N]${NC}"
read -r perform_diagnostics

if [[ "$perform_diagnostics" =~ ^[Yy]$ ]]; then
  echo -e "${BLUE}========================================================================${NC}"
  echo -e "${GREEN}Advanced Diagnostics${NC}"
  echo -e "${BLUE}========================================================================${NC}"
  echo -e "1) Generate and analyze thread dump"
  echo -e "2) Check WebLogic JDBC connection pools"
  echo -e "3) Run WebLogic native diagnostic commands"
  echo -e "4) Check for BouncyCastle library conflicts"
  echo -e "5) Exit"
  echo -e "${BLUE}========================================================================${NC}"
  
  read -r -p "Select an option [1-5]: " diagnostic_option
  
  case $diagnostic_option in
    1)
      analyze_thread_dump
      ;;
    2)
      echo -e "${YELLOW}To check JDBC connection pools, please visit:${NC}"
      echo -e "http://localhost:7001/console -> Services -> Data Sources"
      ;;
    3)
      echo -e "${YELLOW}To run WebLogic diagnostics, use WLST:${NC}"
      echo -e "$MIDDLEWARE_HOME/oracle_common/common/bin/wlst.sh"
      ;;
    4)
      check_bouncy_castle
      ;;
    *)
      echo -e "${GREEN}Exiting diagnostics.${NC}"
      ;;
  esac
fi

# Check if everything is working
if check_weblogic && check_port_in_use 7001 && [[ "$HTTP_RESULT" == "200" || "$HTTP_RESULT" == "404" ]]; then
  echo -e "${GREEN}WebLogic appears to be running normally.${NC}"
  echo -e "Admin Console: http://localhost:7001/console/"
  
  # Check if VBMS apps are deployed
  if find "$DEPLOYED_DIR" 2>/dev/null | grep -i "vbms-core" > /dev/null && \
     find "$DEPLOYED_DIR" 2>/dev/null | grep -i "vbms-ui" > /dev/null; then
    echo -e "${GREEN}VBMS applications are deployed:${NC}"
    echo -e "- vbms-core: http://localhost:7001/vbms-core/"
    echo -e "- vbms-ui: http://localhost:7001/vbms-ui/"
  else
    echo -e "${YELLOW}VBMS applications are not yet deployed.${NC}"
    echo -e "To deploy VBMS applications with BouncyCastle conflict resolution,"
    echo -e "use the VBMS deployment scripts from this repository."
  fi
else
  echo -e "${RED}WebLogic may not be functioning correctly.${NC}"
  echo -e "${YELLOW}To restart WebLogic, run:${NC}"
  echo -e "${HOME}/dev/local-arm-mac/scripts/weblogic/start-weblogic-with-checks.sh"
fi

echo -e "${BLUE}========================================================================${NC}"
