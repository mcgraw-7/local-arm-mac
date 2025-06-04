#!/bin/zsh
# Script to check Maven configuration on Apple Silicon Mac
# filepath: /Users/michaelmcgraw/dev/local-arm-mac/scripts/utils/check-maven-config.sh

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}====================================================${NC}"
echo "${BLUE}Maven Configuration Check${NC}"
echo "${BLUE}====================================================${NC}"

# Check for Maven installation
echo ""
echo "${BLUE}Checking for Maven...${NC}"
if ! command -v mvn &> /dev/null; then
    echo "${RED}❌ Maven is not installed${NC}"
    echo "Maven is required for building Java projects"
    echo "You can install Maven with: brew install maven"
    exit 1
else
    MVN_VERSION=$(mvn --version | grep "Apache Maven" | head -n 1)
    echo "${GREEN}✅ $MVN_VERSION${NC}"
    
    # Show Java version Maven is using
    JAVA_VERSION=$(mvn --version | grep "Java version" | head -n 1)
    echo "${GREEN}✅ $JAVA_VERSION${NC}"
    
    # Show Maven home
    MVN_HOME=$(mvn --version | grep "Maven home" | head -n 1)
    echo "${GREEN}✅ $MVN_HOME${NC}"
fi

# Check Maven settings.xml existence
echo ""
echo "${BLUE}Checking Maven settings.xml...${NC}"
USER_SETTINGS_PATH="${HOME}/.m2/settings.xml"
if [ -f "$USER_SETTINGS_PATH" ]; then
    echo "${GREEN}✅ User settings.xml found at: $USER_SETTINGS_PATH${NC}"
    
    # Extract and display proxy settings without passwords
    echo ""
    echo "${BLUE}Proxy configurations in settings.xml:${NC}"
    PROXY_COUNT=$(grep -c "<proxy>" "$USER_SETTINGS_PATH")
    if [ "$PROXY_COUNT" -gt 0 ]; then
        echo "${GREEN}Found $PROXY_COUNT proxy configuration(s)${NC}"
        
        # Use awk to extract proxy information
        awk '/<proxy>/,/<\/proxy>/ {
            if ($0 ~ /<id>/) {
                match($0, /<id>(.*)<\/id>/, id)
                proxy_id = id[1]
                printf "Proxy ID: %s\n", proxy_id
            }
            if ($0 ~ /<active>/) {
                match($0, /<active>(.*)<\/active>/, active)
                printf "  Active: %s\n", active[1]
            }
            if ($0 ~ /<protocol>/) {
                match($0, /<protocol>(.*)<\/protocol>/, protocol)
                printf "  Protocol: %s\n", protocol[1]
            }
            if ($0 ~ /<host>/) {
                match($0, /<host>(.*)<\/host>/, host)
                printf "  Host: %s\n", host[1]
            }
            if ($0 ~ /<port>/) {
                match($0, /<port>(.*)<\/port>/, port)
                printf "  Port: %s\n", port[1]
            }
            if ($0 ~ /<username>/) {
                match($0, /<username>(.*)<\/username>/, username)
                printf "  Username: %s\n", username[1]
            }
            if ($0 ~ /<password>/) {
                printf "  Password: [HIDDEN]\n"
            }
            if ($0 ~ /<nonProxyHosts>/) {
                match($0, /<nonProxyHosts>(.*)<\/nonProxyHosts>/, nonProxy)
                printf "  Non-Proxy Hosts: %s\n\n", nonProxy[1]
            }
        }' "$USER_SETTINGS_PATH"
    else
        echo "${YELLOW}⚠️  No proxy configurations found in settings.xml${NC}"
    fi
    
    # Extract and display active profiles
    echo ""
    echo "${BLUE}Active profiles in settings.xml:${NC}"
    if grep -q "<activeProfile>" "$USER_SETTINGS_PATH"; then
        grep -A 1 "<activeProfile>" "$USER_SETTINGS_PATH" | grep -v "<activeProfile>" | sed 's/<\/activeProfile>//' | sed 's/[ \t]*//' | while read profile; do
            echo "  - $profile"
        done
    else
        echo "${YELLOW}⚠️  No active profiles found in settings.xml${NC}"
    fi
    
    # Extract and display available profiles
    echo ""
    echo "${BLUE}Available profiles in settings.xml:${NC}"
    if grep -q "<profile>" "$USER_SETTINGS_PATH"; then
        grep -A 1 "<profile>" "$USER_SETTINGS_PATH" | grep "<id>" | sed 's/.*<id>/  - /' | sed 's/<\/id>//' 
    else
        echo "${YELLOW}⚠️  No profiles found in settings.xml${NC}"
    fi
    
    # Check for proxy-related environment variables
    echo ""
    echo "${BLUE}Checking for proxy-related environment variables:${NC}"
    for var in http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY; do
        if [ -n "${(P)var}" ]; then
            echo "  ${var}=${(P)var}"
        fi
    done
else
    echo "${YELLOW}⚠️  User settings.xml not found at: $USER_SETTINGS_PATH${NC}"
    echo "Maven is using default settings"
fi

# Test Maven connection to repositories
echo ""
echo "${BLUE}Testing connection to repositories...${NC}"

# Test central repository
echo "Testing connection to Maven Central..."
mvn dependency:get -Dartifact=org.apache.commons:commons-lang3:3.12.0 -DrepoUrl=https://repo.maven.apache.org/maven2/ -q > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "${GREEN}✅ Connection to Maven Central successful${NC}"
else
    echo "${RED}❌ Connection to Maven Central failed${NC}"
fi

echo ""
echo "${BLUE}====================================================${NC}"
echo "${BLUE}Maven Effective Settings${NC}"
echo "${BLUE}====================================================${NC}"
echo "${YELLOW}Note: This shows your effective Maven settings with passwords masked${NC}"
echo ""

# Get effective settings and highlight proxy sections
mvn help:effective-settings | awk '
    /Effective user settings:/ {print; in_settings=1; next}
    in_settings {
        if (/^<!DOCTYPE/ || /<\?xml/) next
        if (/<proxy>/) {
            in_proxy=1
            print "\033[1;34m" $0 "\033[0m"
            next
        }
        if (in_proxy && /<\/proxy>/) {
            in_proxy=0
            print "\033[1;34m" $0 "\033[0m"
            next
        }
        if (in_proxy) {
            if (/<password>.*<\/password>/) {
                gsub(/<password>.*<\/password>/, "<password>[HIDDEN]</password>")
            }
            print "\033[1;34m" $0 "\033[0m"
        } else {
            print
        }
    }
'

echo ""
echo "${BLUE}====================================================${NC}"
echo "${BLUE}Maven Configuration Summary${NC}"
echo "${BLUE}====================================================${NC}"
echo "For optimal Maven setup on Apple Silicon with VA resources:"
echo ""
echo "1. Ensure proxy is configured for VA/BIP domains"
echo ""
echo "2. For SSL certificate issues with VA repositories, use:"
echo "   mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true"
echo ""
echo "3. When working with WebLogic and Oracle, make sure Colima is running with x86_64 architecture"
echo "${BLUE}====================================================${NC}"