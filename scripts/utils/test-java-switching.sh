#!/bin/zsh

echo "=== Testing Java Version Switching ==="
echo ""

echo "Current Java version:"
java -version

echo ""
echo "Setting up environment variables for testing..."
export JAVA_HOME_SAVED="$JAVA_HOME"
export ORIGINAL_PATH="$PATH"

# JDK 8 (default expected)
echo ""
echo "Current Java environment:"
echo "-------------------------"
echo "JAVA_HOME: $JAVA_HOME"
echo "Java version: $(java -version 2>&1 | head -1)"

# Try JDK 17
if [ -d "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home" ]; then
    echo ""
    echo "Switching to JDK 17..."
    echo "---------------------"
    
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$(echo $PATH | sed -E "s|$JAVA_HOME_SAVED/bin:?||g")"
    
    echo "New JAVA_HOME: $JAVA_HOME"
    echo "Java version: $(java -version 2>&1 | head -1)"
else
    echo ""
    echo "JDK 17 not found at expected location"
fi

# Try Zulu JDK 8
if [ -d "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home" ]; then
    echo ""
    echo "Switching to Zulu JDK 8..."
    echo "-------------------------"
    
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$(echo $PATH | sed -E "s|/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/bin:?||g")"
    
    echo "New JAVA_HOME: $JAVA_HOME"
    echo "Java version: $(java -version 2>&1 | head -1)"
else
    echo ""
    echo "Zulu JDK 8 not found at expected location"
fi

# Restore original settings
echo ""
echo "Restoring default Java settings..."
echo "--------------------------------"
export JAVA_HOME="$JAVA_HOME_SAVED"
export PATH="$ORIGINAL_PATH"

echo "Restored JAVA_HOME: $JAVA_HOME"
echo "Java version: $(java -version 2>&1 | head -1)"

echo ""
echo "=== All installed JDKs ==="
ls -1 /Library/Java/JavaVirtualMachines/
