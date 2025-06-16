#!/bin/zsh

# Define color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
RESET="\033[0m"

echo -e "${BLUE}=== Java Versions Management Utility ===${RESET}"

# Get current JAVA_HOME and PATH
current_java_home="$JAVA_HOME"

echo -e "\n${YELLOW}Current Java Configuration:${RESET}"
echo -e "JAVA_HOME: ${GREEN}$current_java_home${RESET}"
echo -e "Java Version: ${GREEN}$(java -version 2>&1 | head -1)${RESET}"

echo -e "\n${YELLOW}Installed JDKs:${RESET}"
jdk_count=0

# List all installed JDKs
for jdk_dir in /Library/Java/JavaVirtualMachines/*; do
    if [[ -d "$jdk_dir" && -d "$jdk_dir/Contents/Home" ]]; then
        jdk_name=$(basename "$jdk_dir")
        jdk_bin="$jdk_dir/Contents/Home/bin/java"
        
        if [[ -x "$jdk_bin" ]]; then
            jdk_version=$("$jdk_bin" -version 2>&1 | head -1)
            
            if [[ "$jdk_dir/Contents/Home" == "$current_java_home" ]]; then
                echo -e "${GREEN}✓ $jdk_name: $jdk_version [ACTIVE]${RESET}"
            else
                echo -e "${BLUE}  $jdk_name: $jdk_version${RESET}"
            fi
            
            ((jdk_count++))
        else
            echo -e "${RED}  $jdk_name: [Invalid installation]${RESET}"
        fi
    fi
done

if [[ $jdk_count -eq 0 ]]; then
    echo -e "${RED}No JDKs found in /Library/Java/JavaVirtualMachines/${RESET}"
fi

echo -e "\n${YELLOW}JDK Switching Instructions:${RESET}"
echo "The following commands have been added to your .zshrc file to switch between JDKs:"
echo -e "${GREEN}jdk17${RESET}       - Switch to Oracle JDK 17"
echo -e "${GREEN}jdk8${RESET}        - Switch to Oracle JDK 8 (version 1.8.0_202)"
echo -e "${GREEN}jdk8old${RESET}     - Switch to Oracle JDK 8 (older version 1.8.0_45)"
echo -e "${GREEN}jdkzulu${RESET}     - Switch to Zulu JDK 8"
echo -e "${GREEN}defaultjdk${RESET}  - Restore your default JDK"
echo -e "${GREEN}javaversion${RESET} - Show current Java version"
echo -e "${GREEN}jdks${RESET}        - List all installed JDKs"

echo -e "\n${BLUE}Note:${RESET} These changes only affect the current terminal session."
echo "Your system default JDK remains unchanged."
