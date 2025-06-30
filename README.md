# local-arm-mac

Configuration scripts for VA Core local development environment setup. Automates dependency checks, environment validation, and Oracle configuration for Apple Silicon (M1/M2/M3) and Intel Macs. Reduces "it works on my machine" issues and streamlines developer onboarding.

## Important Directory Structure Requirements

WebLogic **must** be installed in the Oracle standardized directory:

```
${HOME}/dev/Oracle/Middleware/Oracle_Home
```

No deviations from this directory structure are permitted. All scripts in this repository enforce this requirement to ensure proper functionality and compatibility with VA systems.

## Getting Started

1. Clone or download this repository
2. Make the setup script executable:
   ```
   chmod +x setup.sh
   ```
3. Run the setup script:
   ```
   ./setup.sh
   ```
4. Follow the on-screen prompts to configure your environment

## Usage

### Interactive Mode

Run the setup script and select from the available options:

```
./setup.sh
```

### Auto-Run Mode

Automatically run all verification checks without user interaction:

**Command-line flags:**

```bash
./setup.sh --auto
# or
./setup.sh -a
```

**Environment variable:**

```bash
AUTO_RUN_CHECKS=true ./setup.sh
```

**For the entire session:**

```bash
export AUTO_RUN_CHECKS=true
./setup.sh  # Will auto-run every time
```

### Available Options

1. **Run all verification checks** - Executes all verification scripts in sequence
2. **Path Analysis** - Analyze system paths for Maven, Java, and Oracle components
3. **Check Apple Silicon compatibility** - Verify compatibility with Oracle and WebLogic
4. **Verify VA Core environment standardization** - Check environment matches VA Core requirements
5. **Verify Oracle directory structure** - Ensure Oracle WebLogic is in standardized directories
6. **View README Documentation** - Display this documentation
7. **Exit** - Exit the setup script

## Features and Functions

- **Path Analysis Configuration Tool**: Analyzes and categorizes system paths for Maven, Java, and Oracle components to verify against documentation
- **Apple Silicon Compatibility Check**: Verify compatibility with Oracle and WebLogic on Apple Silicon
- **Directory Structure Verification**: Ensure Oracle WebLogic is installed in standardized directories
- **VA Core Standardization Verification**: Verify your environment matches VA Core requirements

## Apple Silicon Compatibility

- Run the compatibility check script: `./scripts/utils/check-apple-silicon.sh`
- For detailed information, see [Apple Silicon Compatibility Guide](docs/apple-silicon-compatibility.md)

## Repository Structure

```
local-arm-mac/
├── scripts/
│   └── utils/        # Utility scripts for VA Core local setup
├── docs/             # Documentation files
├── config/           # Configuration templates
├── templates/        # Template files for environment setup
└── setup.sh          # Main setup script (entry point)
```

### Documentation Files

- `docs/java-standardization-docs.md` - Detailed documentation of Java standardization
- `docs/apple-silicon-compatibility.md` - Information about compatibility with Apple Silicon (ARM) Macs

### System Requirements

- macOS on Apple Silicon (M1/M2/M3) Mac or Intel Mac
- Oracle JDK 1.8.0_45 installed at `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk`
- WebLogic Server installation (for WebLogic-related scripts)
