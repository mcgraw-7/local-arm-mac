#!/bin/zsh
# Add VA Environment Function to User Profile
# This script adds the va_env() function to the user's .zshrc file

# Check if .wljava_env exists
if [ ! -f "$HOME/.wljava_env" ]; then
    echo "❌ ERROR: WebLogic environment file not found at $HOME/.wljava_env"
    echo "Please run the WebLogic environment setup first."
    exit 1
fi

echo "=== Adding VA Environment Function ==="

# Define the function to add
VA_ENV_FUNCTION='
# VA Core Development Environment helper function
va_env() {
    if [ -f "$HOME/.wljava_env" ]; then
        source "$HOME/.wljava_env"
        echo "VA Core Development Environment activated"
        echo "Oracle JDK: $JAVA_HOME"
        java -version
    else
        echo "ERROR: WebLogic environment file not found"
    fi
}
'

# Check if function already exists in .zshrc
echo "Checking for existing va_env() function in $HOME/.zshrc..."
if grep -q "va_env()" "$HOME/.zshrc"; then
    echo "✅ va_env() function already exists in .zshrc"
else
    # Add function to .zshrc
    echo "Adding va_env() function to $HOME/.zshrc..."
    echo "$VA_ENV_FUNCTION" >> "$HOME/.zshrc"
    echo "✅ Added va_env() function to .zshrc"
    
    # Show what was added
    echo ""
    echo "Function added:"
    echo "${VA_ENV_FUNCTION}" | sed 's/^/    /'
fi

echo ""
echo "=== Usage ==="
echo "To activate the VA environment, run:"
echo "  source ~/.zshrc   # To reload your shell configuration"
echo "  va_env           # To activate the environment"
echo ""
echo "You can also add va_env to your .zshrc to run automatically at shell startup."
