# VA Core Local Development Environment Setup

Configuration scripts for VA Core local development environment setup. Automates dependency checks, environment validation, and Oracle configuration for Apple Silicon (M1/M2/M3) and Intel Macs.

## Important Requirements

WebLogic **must** be installed in the Oracle standardized directory:

```
${HOME}/dev/Oracle/Middleware/Oracle_Home
```

Oracle JDK 1.8.0_45 must be installed at:

```
/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk
```

## Quick Start

1. Make the setup script executable:

   ```bash
   chmod +x setup.sh
   ```

2. Run all verification checks automatically:

   ```bash
   ./setup.sh --auto
   ```

3. Or run interactively:
   ```bash
   ./setup.sh
   ```

## Usage

### Auto-Run Mode

Automatically run all verification checks:

```bash
./setup.sh --auto
# or
./setup.sh -a
# or
AUTO_RUN_CHECKS=true ./setup.sh
```

### Interactive Mode

Run the setup script and select from the available options:

```bash
./setup.sh
```

## System Requirements

- macOS (Apple Silicon M1/M2/M3 or Intel)
- Oracle JDK 1.8.0_45
- WebLogic Server installation
- Colima/Docker (for Oracle database container)
