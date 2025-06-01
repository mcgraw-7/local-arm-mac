---
title: Quick Start Guide
layout: default
permalink: /docs/quick-start/
---

# Quick Start Guide

This guide provides step-by-step instructions for getting started with the local-arm-mac environment for WebLogic development.

## Prerequisites

- macOS (Intel or Apple Silicon M1/M2/M3 Mac)
- Oracle JDK 1.8.0_45 installed at `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk`
- Docker Desktop (Intel Macs) or Colima (Apple Silicon Macs)
- Git
- ZSH shell (default on modern macOS)

## Installation Steps

### 1. Clone the Repository

```bash
mkdir -p ~/dev
cd ~/dev
git clone https://github.com/department-of-veterans-affairs/local-arm-mac.git
cd local-arm-mac
```

### 2. Run the Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

### 3. Follow the Setup Menu

The setup script will display a menu of options. For a new installation, follow these steps in order:

1. **Option 1**: Configure Java environment (limited access, no sudo)
2. **Option 2**: Configure WebLogic-specific environment
3. **Option 3**: Verify Java standardization

### 4. Set Up Helper Functions

For convenience, add these helper functions to your environment:

4. **Option 6**: Add VA Environment helper functions
5. **Option 9**: Add WebLogic start with Oracle DB verification helper functions
6. **Option 7**: Add WebLogic status helper function

### 5. Set Up Oracle Database

If you need Oracle Database for your development:

1. **Option 13**: Manage Oracle Database (with Apple Silicon support)
2. Select the appropriate options to download and create a new Oracle database container

### 6. Apple Silicon Mac Users

If you're using an Apple Silicon Mac (M1/M2/M3):

1. **Option 14**: Check Apple Silicon compatibility
2. Follow the recommendations for installing and configuring Colima

## Using the Environment

After setup, you can use the following helper functions:

- `va_env` - Activate the VA Core Development Environment
- `va_start_oracle_db` - Start the Oracle Database container
- `va_start_weblogic` - Start WebLogic server with Oracle DB verification
- `va_weblogic_status` - Check WebLogic server status
- `wl_java` - Activate the WebLogic Java environment

## Creating a WebLogic Domain

Once your environment is set up:

1. Run **Option 10**: Create WebLogic domain with Oracle DB verification
2. Wait for the domain creation process to complete

## Verifying Your Setup

At any time, you can verify your setup using:

- **Option 3**: Verify Java standardization
- **Option 11**: Verify Oracle DB container for WebLogic
- **Option 12**: Verify Oracle WebLogic standardized directory structure

## Additional Resources

- [Java Standardization Documentation](/docs/java-standardization-docs.html)
- [Apple Silicon Compatibility Guide](/docs/apple-silicon-compatibility.html)

## Troubleshooting

If you encounter issues:

1. Verify your Java environment with **Option 3**
2. Check the Oracle DB container with **Option 11**
3. Ensure WebLogic is installed in the standardized directory with **Option 12**
4. Clean up temporary files with **Option 15** if needed
