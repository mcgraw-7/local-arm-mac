#!/bin/zsh
# Debug script for configuration comparison

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print comparison
print_comparison() {
    local item="$1"
    local required="$2"
    local current="$3"
    local result="$4"
    
    echo "Testing comparison function with parameters:"
    echo "Item: $item"
    echo "Required: $required"
    echo "Current: $current"
    echo "Result: $result"
    
    if [ "$result" = "PASS" ]; then
        echo "${GREEN}PASS${NC}"
    elif [ "$result" = "WARN" ]; then
        echo "${YELLOW}WARNING${NC}"
    else
        echo "${RED}FAIL${NC}"
    fi
    echo "Comparison function completed"
}

echo "===== CONFIGURATION DEBUG SCRIPT ====="
echo "This is a simplified version for testing"

# Test the function
print_comparison "Test Item" "Should be X" "Is Y" "WARN"
echo "Script completed successfully"
