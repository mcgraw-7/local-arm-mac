#!/bin/zsh
# Add va_weblogic_status helper function to user's .zshrc

VA_ENV_FUNCTION='
# VA WebLogic Status Helper Function
va_weblogic_status() {
  echo "Checking WebLogic server status..."
  
  # Check if WebLogic process is running
  WLS_PROCESS=$(ps -ef | grep java | grep weblogic | grep -v grep)
  
  if [ -n "$WLS_PROCESS" ]; then
    echo "✅ WebLogic server is running:"
    echo "$WLS_PROCESS" | grep -v grep | head -1
    
    # Extract JVM and memory info
    JVM_INFO=$(ps -o pid,rss,%cpu -p $(echo "$WLS_PROCESS" | awk "{print \$2}" | head -1))
    echo ""
    echo "JVM Stats:"
    echo "$JVM_INFO"
    
    # Check if Admin Console is accessible
    echo ""
    echo "Testing Admin Console access..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:7001/console || echo "Failed")
    
    if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ]; then
      echo "✅ Admin Console is accessible at http://localhost:7001/console"
    else
      echo "⚠️ Admin Console returned status $HTTP_STATUS (not fully started yet or requires authentication)"
    fi
    
    # Check Oracle DB status if WebLogic is running
    echo ""
    echo "Checking Oracle database status..."
    ORACLE_CONTAINER=$(docker ps | grep -i oracle | grep -i database)
    if [ -n "$ORACLE_CONTAINER" ]; then
      echo "✅ Oracle database is running: $(echo $ORACLE_CONTAINER | awk "{print \$1}")"
    else
      echo "❌ Oracle database is NOT running - applications may fail!"
      echo "Use va_start_weblogic to restart with database verification"
    fi
  else
    echo "❌ WebLogic server is not running"
    
    # Check if domain exists
    ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
    DOMAIN_HOME="${ORACLE_HOME}/user_projects/domains/P2-DEV"
    if [ -d "$DOMAIN_HOME" ]; then
      echo "✅ WebLogic domain exists at: $DOMAIN_HOME"
      echo "To start WebLogic, run: va_start_weblogic"
    else
      echo "❌ WebLogic domain not found at: $DOMAIN_HOME"
      echo "Please create a domain first using: ${HOME}/dev/local-arm-mac/scripts/weblogic/create-domain-m3.sh"
      echo "WebLogic must be installed in the Oracle standardized directory: ${ORACLE_HOME}"
      echo "No deviations from this directory structure are permitted."
    fi
  fi
}
'

echo "Adding va_weblogic_status function to your .zshrc file..."

# Check if the function already exists in .zshrc
if grep -q "va_weblogic_status()" ~/.zshrc; then
  echo "Function already exists in .zshrc"
  
  # Update the existing function
  START_LINE=$(grep -n "va_weblogic_status()" ~/.zshrc | cut -d ':' -f1)
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
    echo "✅ Updated existing va_weblogic_status function in .zshrc"
  fi
else
  # Append the function to .zshrc
  echo "$VA_ENV_FUNCTION" >> ~/.zshrc
  echo "✅ Added va_weblogic_status function to .zshrc"
fi

echo ""
echo "To use the function, restart your terminal or run:"
echo "source ~/.zshrc"
echo ""
echo "Then you can run: va_weblogic_status"
echo "to check the status of WebLogic and the Oracle database"
