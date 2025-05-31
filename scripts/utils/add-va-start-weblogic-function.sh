#!/bin/zsh
# Add VA WebLogic Start Function to User Profile
# This script adds the va_start_weblogic() function to the user's .zshrc file

echo "=== Adding VA Start WebLogic Function ==="

# Define the function to add
VA_START_WEBLOGIC_FUNCTION='
# VA WebLogic Server start helper function
va_start_weblogic() {
    echo "Starting WebLogic server..."
    # Check if the repository exists
    if [ -f "$HOME/dev/local-arm-mac/scripts/weblogic/start-weblogic.sh" ]; then
        "$HOME/dev/local-arm-mac/scripts/weblogic/start-weblogic.sh"
    else
        echo "❌ ERROR: start-weblogic.sh script not found"
        echo "Please ensure you have the local-arm-mac repository in your ~/dev directory"
    fi
}
'

# Check if function already exists in .zshrc
echo "Checking for existing va_start_weblogic() function in $HOME/.zshrc..."
if grep -q "va_start_weblogic()" "$HOME/.zshrc"; then
    echo "✅ va_start_weblogic() function already exists in .zshrc"
else
    # Add function to .zshrc
    echo "Adding va_start_weblogic() function to $HOME/.zshrc..."
    echo "$VA_START_WEBLOGIC_FUNCTION" >> "$HOME/.zshrc"
    echo "✅ Added va_start_weblogic() function to .zshrc"
    
    # Show what was added
    echo ""
    echo "Function added:"
    echo "${VA_START_WEBLOGIC_FUNCTION}" | sed 's/^/    /'
fi

echo ""
echo "=== Usage ==="
echo "To start WebLogic server, run:"
echo "  source ~/.zshrc   # To reload your shell configuration"
echo "  va_start_weblogic  # To start the WebLogic server"
