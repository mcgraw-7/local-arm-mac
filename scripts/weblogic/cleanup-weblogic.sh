#!/bin/zsh
# Comprehensive WebLogic cleanup script
# This will remove all WebLogic installations and prepare for a fresh install
# Created: June 1, 2025

# Set color codes for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}====================================================${NC}"
echo "${BLUE}WebLogic Comprehensive Cleanup${NC}"
echo "${BLUE}====================================================${NC}"
echo "${YELLOW}WARNING: This script will remove all WebLogic installations${NC}"
echo "${YELLOW}and prepare your environment for a fresh installation.${NC}"
echo ""
echo "${RED}Press CTRL+C now if you want to cancel.${NC}"
echo "Otherwise, press Enter to continue..."
read

# Define directories to clean
ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
ORACLE_INVENTORY="${HOME}/dev/Oracle/oraInventory"
WEBLOGIC_TEMP="${HOME}/dev/wls_temp"
WEBLOGIC_EXTRACT="${HOME}/dev/wls_extract"
WEBLOGIC_MANUAL="${HOME}/dev/wls_manual"
ORACLE_DOCKER="${HOME}/dev/oracle-docker-images"
ORACLE_OFFICIAL="${HOME}/dev/oracle-official"
WEBLOGIC_BUILD="${HOME}/dev/weblogic-build"

# Create a backup directory with timestamp
BACKUP_DIR="${HOME}/dev/weblogic-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "${BLUE}Creating backup directory: $BACKUP_DIR${NC}"

# Backup existing config files that might be useful later
echo "${YELLOW}Backing up any useful configuration files...${NC}"
if [ -d "$ORACLE_HOME" ]; then
  echo "Backing up domain configuration files..."
  mkdir -p "$BACKUP_DIR/domains"
  
  # Backup domain configurations if they exist
  if [ -d "$ORACLE_HOME/user_projects/domains" ]; then
    find "$ORACLE_HOME/user_projects/domains" -name "*.xml" -o -name "*.properties" -o -name "*.py" | while read file; do
      rel_path=${file#$ORACLE_HOME/user_projects/domains/}
      mkdir -p "$BACKUP_DIR/domains/$(dirname "$rel_path")"
      cp "$file" "$BACKUP_DIR/domains/$(dirname "$rel_path")/"
    done
  fi
fi

# Backup installation scripts and response files
echo "Backing up installation scripts and response files..."
mkdir -p "$BACKUP_DIR/scripts"
find "$HOME/dev" -maxdepth 1 -name "*.sh" -o -name "*.py" -o -name "*.rsp" | grep -i weblogic | while read file; do
  cp "$file" "$BACKUP_DIR/scripts/"
done

echo "${GREEN}✅ Backup complete: $BACKUP_DIR${NC}"

# Stop any running WebLogic processes
echo "${YELLOW}Stopping any running WebLogic processes...${NC}"
pkill -f weblogic || echo "No WebLogic processes found running"

# Clean up directories
echo "${YELLOW}Removing WebLogic directories...${NC}"

remove_dir() {
  if [ -d "$1" ]; then
    echo "Removing $1"
    rm -rf "$1"
    echo "${GREEN}✅ Removed: $1${NC}"
  else
    echo "Directory not found: $1 (skipping)"
  fi
}

# Remove Oracle home and inventory
remove_dir "$ORACLE_HOME"
remove_dir "$ORACLE_INVENTORY"

# Remove temporary directories
remove_dir "$WEBLOGIC_TEMP"
remove_dir "$WEBLOGIC_EXTRACT"
remove_dir "$WEBLOGIC_MANUAL"
remove_dir "$ORACLE_DOCKER"
remove_dir "$ORACLE_OFFICIAL"
remove_dir "$WEBLOGIC_BUILD"

# Recreate the standard directories
echo "${YELLOW}Creating fresh standard directories...${NC}"
mkdir -p "$ORACLE_HOME"
mkdir -p "$ORACLE_INVENTORY"

echo "${GREEN}====================================================${NC}"
echo "${GREEN}Cleanup Complete!${NC}"
echo "${GREEN}====================================================${NC}"
echo ""
echo "Your environment is now ready for a fresh WebLogic installation."
echo ""
echo "${BLUE}Next steps:${NC}"
echo "1. Install WebLogic using the installer JAR with this command:"
echo "${YELLOW}   cd ~/dev && java -D64 -Dspace.detection=false -Xmx1024m -jar fmw_12.2.1.4.0_wls_lite_generic.jar${NC}"
echo ""
echo "2. When prompted, use these directories:"
echo "${YELLOW}   Inventory: $ORACLE_INVENTORY${NC}"
echo "${YELLOW}   Oracle Home: $ORACLE_HOME${NC}"
echo ""
echo "3. After installation completes, run the domain creation script:"
echo "${YELLOW}   cd ~/dev/local-arm-mac && ./scripts/weblogic/create-domain-m3.sh${NC}"
echo ""
echo "${GREEN}Enjoy your fresh WebLogic installation!${NC}"
