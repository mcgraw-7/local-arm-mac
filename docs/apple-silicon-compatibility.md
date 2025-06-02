# Apple Silicon Compatibility Guide for WebLogic and Oracle

This document provides detailed information about running WebLogic and Oracle Database on Apple Silicon (M1/M2/M3) Mac computers.

## Overview

Apple Silicon Macs use ARM64 architecture which requires special configuration for running Oracle products that were originally designed for x86_64 architecture. This guide explains how to properly configure your environment for optimal compatibility and performance.

## System Requirements

- Apple Silicon Mac (M1, M2, or M3 chip)
- macOS Monterey or later
- Minimum 16GB RAM recommended (12GB minimum)
- Rosetta 2 installed
- Oracle JDK 1.8.0_45 installed at `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk`
- Colima installed (for Docker containers)

## Quick Setup

1. Run the compatibility check script:
   ```bash
   ./scripts/utils/check-apple-silicon.sh
   ```

2. Install Rosetta 2 if not already installed:
   ```bash
   softwareupdate --install-rosetta
   ```

3. Install Colima for container support:
   ```bash
   brew install colima
   ```

4. Start Colima with proper settings for Oracle:
   ```bash
   colima start -c 4 -m 12 --arch x86_64
   ```

5. Use the standardized scripts in this repository for all WebLogic operations

## WebLogic Configuration for Apple Silicon

All WebLogic scripts in this repository include the following special configurations:

```bash
export BYPASS_CPU_CHECK=true
export BYPASS_PREFLIGHT=true
export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"
```

These settings ensure that:
- The CPU architecture check is bypassed (which would otherwise prevent WebLogic from running)
- Preflight checks that might fail on ARM64 are bypassed
- Java security and AWT settings are optimized for headless operation

## Oracle Database Configuration

Oracle Database requires x86_64 emulation through Colima:

1. **Use Colima with x86_64 architecture**:
   ```bash
   colima start -c 4 -m 12 -a x86_64
   ```

2. **Platform flag for Docker**:
   All Oracle database containers must be created with the `--platform linux/amd64` flag. The scripts in this repository handle this automatically.

3. **Helper Functions**:
   Use the `va_start_oracle_db()` helper function which handles all platform-specific requirements.

## Java Environment

Oracle JDK 1.8.0_45 will run via Rosetta 2 automatically on Apple Silicon. Verify your Java environment with:

```bash
echo $JAVA_HOME
java -version
```

The output should show:
- `JAVA_HOME` pointing to `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk/Contents/Home`
- Java version showing `1.8.0_45`

## Troubleshooting

### Common Issues and Solutions

1. **WebLogic domain creation fails**
   - Ensure Rosetta 2 is installed
   - Verify Oracle JDK 1.8.0_45 is installed correctly
   - Use the standardized scripts that contain Apple Silicon compatibility fixes

2. **Oracle Database container won't start**
   - Check if Colima is running correctly: `colima status`
   - Verify Colima was started with x86_64 architecture
   - Use the `manage-oracle-db.sh` script which handles platform compatibility issues

3. **Performance issues**
   - Increase memory allocation for Colima: `colima start -c 4 -m 16 -a x86_64`
   - Close unused applications to free up system resources
   - Consider running resource-intensive operations on a remote server

### Verification

Run the compatibility check script to verify your environment:

```bash
./scripts/utils/check-apple-silicon.sh
```

This script provides a comprehensive report on your system's compatibility with Oracle products.

## Recent Updates (2023-2024)

Oracle has officially begun supporting ARM64 platforms for some products:

- Oracle Database 19c Enterprise Edition now has ARM64 support
- Oracle Database 23ai Free Edition supports ARM64
- For these versions, you can use native ARM64 installations rather than x86_64 emulation

For WebLogic Server, continue using the x86_64 version with Rosetta 2 as described in this guide.

## Resources

- [Oracle 19c ARM64 Downloads](https://www.oracle.com/database/technologies/oracle19c-linux-arm64-downloads.html)
- [Colima Documentation](https://github.com/abiosoft/colima)
- [Rosetta 2 Information](https://support.apple.com/en-us/HT211861)
