#!/bin/zsh
# Add va_deploy_vbms helper function to user's .zshrc

VA_ENV_FUNCTION='
# VA Deploy VBMS Helper Function
va_deploy_vbms() {
  echo "Preparing to deploy VBMS applications to WebLogic..."
  
  # First check if WebLogic and Oracle DB are running
  echo "Verifying WebLogic and Oracle Database status..."
  
  # Check if WebLogic process is running
  WLS_PROCESS=$(ps -ef | grep java | grep weblogic | grep -v grep)
  
  if [ -z "$WLS_PROCESS" ]; then
    echo "❌ WebLogic server is not running!"
    echo "Please start WebLogic first with: va_start_weblogic"
    return 1
  fi
  
  # Check Oracle DB status
  ORACLE_CONTAINER=$(docker ps | grep -i oracle | grep -i database)
  if [ -z "$ORACLE_CONTAINER" ]; then
    echo "❌ Oracle database is NOT running!"
    echo "Applications may fail deployment or runtime operations"
    
    read -p "Do you want to continue anyway? (y/n): " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
      echo "Deployment aborted. Please start Oracle database and try again."
      return 1
    fi
  else
    echo "✅ Oracle database is running: $(echo $ORACLE_CONTAINER | awk "{print \$1}")"
  fi
  
  # Get path to the application EAR file
  if [ $# -eq 0 ]; then
    # No arguments provided, try to find EAR files
    echo "Looking for VBMS EAR files in dev directory..."
    EAR_FILES=($(find ~/dev -name "*vbms*.ear" | grep -v target))
    
    if [ ${#EAR_FILES[@]} -eq 0 ]; then
      echo "❌ No VBMS EAR files found."
      echo "Please provide the path to the EAR file as an argument."
      echo "Example: va_deploy_vbms ~/dev/vbms-app.ear"
      return 1
    elif [ ${#EAR_FILES[@]} -eq 1 ]; then
      EAR_FILE="${EAR_FILES[0]}"
      echo "Found EAR file: $EAR_FILE"
    else
      echo "Multiple EAR files found:"
      for i in "${!EAR_FILES[@]}"; do
        echo "[$i] ${EAR_FILES[$i]}"
      done
      
      read -p "Enter the number of the EAR file to deploy: " EAR_INDEX
      if [[ ! "$EAR_INDEX" =~ ^[0-9]+$ ]] || [ "$EAR_INDEX" -ge ${#EAR_FILES[@]} ]; then
        echo "Invalid selection. Deployment aborted."
        return 1
      fi
      
      EAR_FILE="${EAR_FILES[$EAR_INDEX]}"
      echo "Selected EAR file: $EAR_FILE"
    fi
  else
    # Argument provided, use it as the EAR file path
    EAR_FILE="$1"
    
    if [ ! -f "$EAR_FILE" ]; then
      echo "❌ EAR file not found at: $EAR_FILE"
      return 1
    fi
  fi
  
  # Deploy using WLST
  ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
  echo "Starting deployment using WLST..."
  
  # Create temporary deployment script
  DEPLOY_SCRIPT="/tmp/deploy_vbms.py"
  
  cat > $DEPLOY_SCRIPT << EOF
# WLST Script to deploy VBMS application
import os, sys

# Connection parameters
adminHost = "localhost"
adminPort = "7001"
adminUser = "weblogic"
adminPassword = "weblogic1"

# Application parameters
appName = os.path.basename("$EAR_FILE").split(".")[0]
appPath = "$EAR_FILE"
target = "AdminServer"

print("Connecting to WebLogic Admin Server...")
connect(adminUser, adminPassword, "t3://" + adminHost + ":" + adminPort)

print("Deploying application: " + appName)
print("from: " + appPath)
print("to target: " + target)

# Check if application already exists
try:
    cd("/AppDeployments/" + appName)
    print("Application " + appName + " already exists, updating...")
    undeploy(appName, targets=target)
    print("Application undeployed successfully")
except:
    print("Application does not exist, performing new deployment")

# Deploy the application
deploy(appPath, appName, target)

print("Deployment completed successfully")
disconnect()
exit()
EOF
  
  # Execute WLST deployment script
  echo "Executing deployment with WLST..."
  $ORACLE_HOME/oracle_common/common/bin/wlst.sh $DEPLOY_SCRIPT
  
  DEPLOY_STATUS=$?
  
  # Cleanup
  rm $DEPLOY_SCRIPT
  
  if [ $DEPLOY_STATUS -eq 0 ]; then
    echo "✅ Application deployment completed"
    echo "You can access the application at: http://localhost:7001/$appName"
  else
    echo "❌ Application deployment failed"
    echo "Check the WebLogic logs for more information"
  fi
}
'

echo "Adding va_deploy_vbms function to your .zshrc file..."

# Check if the function already exists in .zshrc
if grep -q "va_deploy_vbms()" ~/.zshrc; then
  echo "Function already exists in .zshrc"
  
  # Update the existing function
  START_LINE=$(grep -n "va_deploy_vbms()" ~/.zshrc | cut -d ':' -f1)
  if [ -n "$START_LINE" ]; then
    # Find the end of the function
    END_LINE=$(tail -n +$START_LINE ~/.zshrc | grep -n "}" | head -1 | cut -d ':' -f1)
    END_LINE=$((START_LINE + END_LINE))
    
    # Create a temp file with the function removed
    sed "${START_LINE},${END_LINE}d" ~/.zshrc > ~/.zshrc.tmp
    
    # Insert the new function at the same location
    sed "${START_LINE}i\\
$VA_ENV_FUNCTION
" ~/.zshrc.tmp > ~/.zshrc
    
    rm ~/.zshrc.tmp
    echo "✅ Updated existing va_deploy_vbms function in .zshrc"
  fi
else
  # Append the function to .zshrc
  echo "$VA_ENV_FUNCTION" >> ~/.zshrc
  echo "✅ Added va_deploy_vbms function to .zshrc"
fi

echo ""
echo "To use the function, restart your terminal or run:"
echo "source ~/.zshrc"
echo ""
echo "Then you can run: va_deploy_vbms [path-to-ear-file]"
echo "to deploy VBMS applications to WebLogic"
