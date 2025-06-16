#!/bin/bash

# Basic Java version check
echo "Current Java version:"
java -version

# List installed JDKs
echo -e "\nInstalled JDKs:"
ls -la /Library/Java/JavaVirtualMachines/

# Check system variables
echo -e "\nEnvironment variables:"
echo "JAVA_HOME: $JAVA_HOME"
echo "PATH: $PATH"
