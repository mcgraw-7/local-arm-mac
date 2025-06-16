#!/bin/bash
# Test script to validate Java version switching and WebLogic compatibility

# Define color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
NC="\033[0m" # No Color

echo -e "${BLUE}=== Java Version Switching and WebLogic Compatibility Test ===${NC}"
echo ""

# Check if WebLogic is installed at the standard location
WL_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
if [ ! -d "$WL_HOME" ]; then
    echo -e "${RED}ERROR: WebLogic is not installed at the standard location: ${HOME}/dev/Oracle/Middleware/Oracle_Home${NC}"
    echo "Please install WebLogic at this location before continuing."
    exit 1
fi

# Save current Java environment
ORIGINAL_JAVA_HOME="$JAVA_HOME"
echo -e "${YELLOW}Current Java environment:${NC}"
echo -e "JAVA_HOME=${GREEN}$JAVA_HOME${NC}"
current_version=$(java -version 2>&1 | head -1)
echo -e "Java version: ${GREEN}$current_version${NC}"
echo ""

# Test with Oracle JDK 8
echo -e "${BLUE}Testing WebLogic with Oracle JDK 8...${NC}"
if [ -d "/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home" ]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$(echo $PATH | sed -E "s|$ORIGINAL_JAVA_HOME/bin:?||g")"
    
    echo -e "JAVA_HOME=${GREEN}$JAVA_HOME${NC}"
    jdk8_version=$(java -version 2>&1 | head -1)
    echo -e "Java version: ${GREEN}$jdk8_version${NC}"
    
    echo -e "${YELLOW}Testing WebLogic compatibility with JDK 8...${NC}"
    if [ -f "$WL_HOME/oracle_common/common/bin/wlst.sh" ]; then
        echo -e "${GREEN}✅ WebLogic WLST script found${NC}"
        echo -e "${YELLOW}Checking if WLST can run with this JDK...${NC}"
        
        # Attempt to run a simple WLST command
        "$WL_HOME/oracle_common/common/bin/wlst.sh" -c "print 'WebLogic compatible with JDK 8!'; exit()" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ WebLogic is compatible with Oracle JDK 8${NC}"
        else
            echo -e "${RED}❌ WebLogic is not compatible with Oracle JDK 8${NC}"
        fi
    else
        echo -e "${RED}❌ WebLogic WLST script not found${NC}"
    fi
else
    echo -e "${RED}❌ Oracle JDK 8 not found at expected location${NC}"
fi
echo ""

# Test with Oracle JDK 17
echo -e "${BLUE}Testing WebLogic with Oracle JDK 17...${NC}"
if [ -d "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home" ]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$(echo $PATH | sed -E "s|/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home/bin:?||g")"
    
    echo -e "JAVA_HOME=${GREEN}$JAVA_HOME${NC}"
    jdk17_version=$(java -version 2>&1 | head -1)
    echo -e "Java version: ${GREEN}$jdk17_version${NC}"
    
    echo -e "${YELLOW}Testing WebLogic compatibility with JDK 17...${NC}"
    if [ -f "$WL_HOME/oracle_common/common/bin/wlst.sh" ]; then
        echo -e "${GREEN}✅ WebLogic WLST script found${NC}"
        echo -e "${YELLOW}Checking if WLST can run with this JDK...${NC}"
        
        # Attempt to run a simple WLST command
        "$WL_HOME/oracle_common/common/bin/wlst.sh" -c "print 'WebLogic compatible with JDK 17!'; exit()" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ WebLogic is compatible with Oracle JDK 17${NC}"
        else
            echo -e "${RED}❌ WebLogic is not compatible with Oracle JDK 17${NC}"
            echo -e "${YELLOW}Note: This is expected as WebLogic 12c was designed for JDK 8.${NC}"
            echo -e "${YELLOW}JDK 17 can be used for other applications but not for running WebLogic itself.${NC}"
        fi
    else
        echo -e "${RED}❌ WebLogic WLST script not found${NC}"
    fi
else
    echo -e "${RED}❌ Oracle JDK 17 not found at expected location${NC}"
fi
echo ""

# Restore original Java settings
export JAVA_HOME="$ORIGINAL_JAVA_HOME"
export PATH="$JAVA_HOME/bin:$(echo $PATH | sed -E "s|/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/bin:?||g")"

echo -e "${BLUE}Restored original Java environment:${NC}"
echo -e "JAVA_HOME=${GREEN}$JAVA_HOME${NC}"
restored_version=$(java -version 2>&1 | head -1)
echo -e "Java version: ${GREEN}$restored_version${NC}"

echo -e "\n${GREEN}=== Test completed ===\n${NC}"
echo -e "${YELLOW}Summary:${NC}"
echo -e "1. Original Java: $current_version"
echo -e "2. JDK 8 Test: $jdk8_version"
echo -e "3. JDK 17 Test: $jdk17_version"
echo -e "4. Restored to: $restored_version"
echo ""
echo -e "${BLUE}Note:${NC} WebLogic 12c officially supports JDK 8 and not JDK 17."
echo -e "Use JDK 8 for running WebLogic and JDK 17 for other development tasks as needed."
echo -e "The Java version switching functions in your .zshrc allow for easy switching between Java versions."
