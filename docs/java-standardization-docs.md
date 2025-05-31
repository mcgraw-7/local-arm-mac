# WebLogic Java Environment Standardization (Limited Access)

## Overview
This document provides instructions for standardizing the Java environment for WebLogic development on Apple Silicon Macs without requiring sudo access. We've established `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home` as our standard JDK location.

## What We've Done

### 1. Created Environment Configuration
- Created environment file: `~/.wljava_env`
- Added `wl_java` function to `.zshrc` for quick activation
- Created scripts that don't require sudo access

### 2. Standardized WebLogic Scripts
- Created copies of critical scripts in `~/dev/standardized-scripts/` with the correct JDK path
- Modified key WebLogic scripts to use the standardized JDK path

### 3. Created Helper Utilities
- `~/dev/run-with-oracle-jdk.sh` - Run any command with the Oracle JDK
- `~/dev/standardized-scripts/run-weblogic.sh` - Run WebLogic scripts with the standard environment

## How to Use

### Option 1: Activate Java Environment (for New Terminal Sessions)
```bash
# Method 1: Direct activation
source ~/.wljava_env

# Method 2: Using the function in .zshrc
wl_java
```

### Option 2: Run Commands with Oracle JDK
```bash
# This runs any command with the Oracle JDK environment
~/dev/run-with-oracle-jdk.sh [command] [arguments]

# Example:
~/dev/run-with-oracle-jdk.sh java -version
```

### Option 3: Run WebLogic Scripts
```bash
# Method 1: Use standardized scripts directly
~/dev/standardized-scripts/script-name.sh

# Method 2: Run any WebLogic script with the correct environment
~/dev/standardized-scripts/run-weblogic.sh script-name.sh

# Example:
~/dev/standardized-scripts/run-weblogic.sh startWebLogic.sh
```

## Managing Java Versions

1. **Environment Variables**: All scripts set `JAVA_HOME` explicitly to the Oracle JDK path
2. **PATH Precedence**: The Oracle JDK bin directory is added at the start of your PATH
3. **Wrapper Scripts**: The `run-with-oracle-jdk.sh` script ensures Oracle JDK is used

## Verification

You can verify that you're using the correct JDK by checking:

```bash
echo $JAVA_HOME
java -version
```

The output should show:
- `JAVA_HOME` pointing to `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home`
- Java version showing `1.8.0_45`

## ARM64 Mac Support

For Apple Silicon Macs, all WebLogic scripts include:

```bash
export BYPASS_CPU_CHECK=true
export BYPASS_PREFLIGHT=true
export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"
```
