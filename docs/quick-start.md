---
title: Quick Start Guide
layout: default
permalink: /docs/quick-start/
---

# Quick Start Guide

This guide provides a quick overview of setting up your Java/WebLogic development environment on Apple Silicon Macs.

## Prerequisites

- Apple Silicon Mac (M1/M2/M3)
- Oracle JDK 1.8.0_45
- WebLogic 12.2.1.4.0
- Oracle Database (container)
- Rosetta 2 installed

## Initial Setup

1. **Verify Apple Silicon Compatibility**

   ```bash
   ./setup.sh
   # Select option 14
   ```

2. **Configure Java Environment**

   ```bash
   ./setup.sh
   # Select option 1
   ```

3. **Set Up WebLogic Environment**

   ```bash
   ./setup.sh
   # Select option 2
   ```

4. **Verify Standardization**
   ```bash
   ./setup.sh
   # Select option 3
   ```

## WebLogic Setup

1. **Configure Java for WebLogic**

   ```bash
   ./setup.sh
   # Select option 5
   ```

2. **Add Helper Functions**

   ```bash
   ./setup.sh
   # Select options 6-9
   ```

3. **Verify Oracle DB**

   ```bash
   ./setup.sh
   # Select option 11
   ```

4. **Create WebLogic Domain**
   ```bash
   ./setup.sh
   # Select option 10
   ```

## Directory Structure

```
scripts/
├── java/           # Java environment configuration
├── weblogic/       # WebLogic configuration and management
├── utils/          # Utility scripts and helper functions
└── vbms/           # VBMS-specific scripts
```

## Helper Functions

After setup, you'll have access to these helper functions:

- `va_env()` - Set up VA environment
- `va_weblogic_status()` - Check WebLogic status
- `va_deploy_vbms()` - Deploy VBMS applications
- `va_start_weblogic()` - Start WebLogic with DB verification
- `va_start_oracle_db()` - Start Oracle DB

## Common Tasks

### Start WebLogic

```bash
va_start_weblogic
```

### Check Status

```bash
va_weblogic_status
```

### Deploy VBMS

```bash
va_deploy_vbms
```

### Clean Up

```bash
./setup.sh
# Select option 15
```

## Troubleshooting

1. **Java Issues**

   ```bash
   ./setup.sh
   # Select option 3
   ```

2. **WebLogic Issues**

   ```bash
   ./setup.sh
   # Select option 12
   ```

3. **Oracle DB Issues**
   ```bash
   ./setup.sh
   # Select option 11
   ```

## Documentation

- `setup-options.md` - Detailed setup options
- `script-reference.md` - Script documentation
- `apple-silicon-compatibility.md` - Apple Silicon guide

## Support

For detailed information, refer to:

- `README.md` - Main documentation
- `docs/` - Detailed guides
- `scripts/utils/` - Utility scripts
