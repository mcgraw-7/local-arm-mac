# local-arm-mac

Configuration scripts for VA Core local development environment setup. Automates dependency checks, environment validation, and WebLogic/Oracle configuration for Apple Silicon (M1/M2/M3) and Intel Macs. Reduces "it works on my machine" issues and streamlines developer onboarding.

## Important Directory Structure Requirements

WebLogic **must** be installed in the Oracle standardized directory:

```
${HOME}/dev/Oracle/Middleware/Oracle_Home
```

No deviations from this directory structure are permitted. All scripts in this repository enforce this requirement to ensure proper functionality and compatibility with VA systems.

## Script Organization

The scripts in this repository are organized into three main categories:

### 1. Java Scripts (`scripts/java/`)

Scripts related to Java environment setup and management:

- `limited-access-java-env.sh` - Configures Java environment without sudo access
- `verify-java-limited.sh` - Verifies Java environment configuration
- `java-versions.sh` - Shows available Java versions
- `java-check.sh` - Basic Java environment checks
- `update-java-paths.sh` - Updates Java path configurations
- `test-java-switching.sh` - Tests Java version switching

### 2. WebLogic Scripts (`scripts/weblogic/`)

Scripts for WebLogic server and domain management:

- `start-weblogic.sh` - Starts WebLogic server
- `standardize-weblogic-scripts.sh` - Standardizes WebLogic configurations
- `create-domain-m3-fixed.sh` - Creates WebLogic domain
- `manage-oracle-db.sh` - Manages Oracle database
- `check-weblogic-status.sh` - Checks WebLogic server status
- `verify-oracle-db.sh` - Verifies Oracle database configuration
- `setup-wl-java.sh` - Sets up WebLogic Java environment
- `weblogic-java-env-limited.sh` - Limited access WebLogic Java setup
- `cleanup-weblogic.sh` - Cleans up WebLogic resources
- `check-vbms-compatibility.sh` - Checks VBMS compatibility

### 3. Utility Scripts (`scripts/utils/`)

General utility and helper scripts:

- `verify-standardization.sh` - Verifies environment standardization
- `compare-configuration.sh` - Compares different configurations
- `test-java-weblogic-compatibility.sh` - Tests Java-WebLogic compatibility
- `compare-debug.sh` - Debug comparison tool
- `show-complete-configuration.sh` - Shows complete environment configuration
- `check-maven-config.sh` - Checks Maven configuration
- `add-va-start-weblogic-function.sh` - Adds WebLogic start function
- `check-apple-silicon.sh` - Checks Apple Silicon compatibility
- `verify-oracle-directory.sh` - Verifies Oracle directory structure
- `update-scripts-without-sudo.sh` - Updates scripts without sudo
- `cleanup-github-pages.sh` - Cleans up GitHub pages
- `cleanup-artifacts.sh` - Cleans up build artifacts
- `cleanup-untracked-files.sh` - Cleans up untracked files
- `add-va-deploy-vbms-function.sh` - Adds VBMS deployment function
- `add-va-weblogic-status-function.sh` - Adds WebLogic status function
- `add-va-env-function.sh` - Adds VA environment function
- `cleanup-all-scripts.sh` - Cleans up all scripts
- `cleanup-scripts.sh` - Basic script cleanup

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

## Features and Functions

### Environment Setup and Verification

- **Apple Silicon Compatibility Check**: Verify compatibility with Oracle and WebLogic on Apple Silicon
- **Directory Structure Verification**: Ensure Oracle WebLogic is installed in standardized directories
- **Java Environment Configuration**: Set up Java environment with limited access and no sudo requirements
- **WebLogic Environment Setup**: Configure WebLogic-specific environment settings
- **Java Standardization Verification**: Verify Java installation and configuration

### Database Management

- **Oracle Database Management**: Manage Oracle Database with Apple Silicon support
- **Database Container Verification**: Verify Oracle DB container for WebLogic
- **WebLogic Domain Creation**: Create WebLogic domain with Oracle DB verification

### Helper Functions

- **VA Environment Functions**: Quick access to VA environment settings
- **WebLogic Status Monitoring**: Check WebLogic server status
- **VBMS Deployment**: Deploy VBMS applications
- **WebLogic Start Functions**: Start WebLogic with Oracle DB verification

### Maintenance and Utilities

- **Script Updates**: Update scripts in non-sudo mode
- **Cleanup Utilities**: Remove temporary files and artifacts
- **Documentation Access**: Quick access to setup instructions and documentation

## Apple Silicon Compatibility

<details>
<summary><strong>Apple Silicon (M1/M2/M3) Mac Support</strong></summary>

This repository includes comprehensive support for running Oracle WebLogic and Oracle Database on Apple Silicon (arm64) Macs:

- **Automatic detection** of Apple Silicon architecture
- **Colima integration** for running Oracle Database containers
- **Environment variables** optimized for M-series chips
- **Helper functions** that work seamlessly across architectures
- **Special handling** of platform-specific Docker commands

For detailed information, see [Apple Silicon Compatibility Guide](docs/apple-silicon-compatibility.md)

**Special considerations for Apple Silicon:**

1. Run the compatibility check script: `./scripts/utils/check-apple-silicon.sh`
2. Install Colima if needed: `brew install colima`
3. Start Colima with proper settings: `colima start -c 4 -m 12 -a x86_64`
4. Use the `manage-oracle-db.sh` script or `va_start_oracle_db()` helper function which handles platform-specific requirements
5. All Oracle database containers will be created with `--platform linux/amd64` flag automatically

> **Note:** If you use Homebrew to install anything created by Oracle, Homebrew will use an open source option to bypass the Oracle account creation process, which is normally very useful, but not here. You need the official Oracle branded JDK.

</details>

## Repository Structure

<details>
<summary><strong>Directory and File Organization</strong></summary>

```
local-arm-mac/
├── scripts/
│   ├── java/         # Java environment configuration scripts
│   ├── weblogic/     # WebLogic-specific configuration scripts
│   └── utils/        # Utility scripts for maintenance and verification
├── docs/             # Documentation files
├── config/           # Configuration templates
├── templates/        # Template files for environment setup
└── setup.sh          # Main setup script (entry point)
```

### Documentation Files

- `docs/java-standardization-docs.md` - Detailed documentation of Java standardization
- `docs/apple-silicon-compatibility.md` - Information about compatibility with Apple Silicon (ARM) Macs

### Helper Functions

The following helper functions are available once you've run the setup script:

- `va_env()` - Activates the VA Core Development Environment
- `va_start_weblogic()` - Starts WebLogic server after verifying Oracle DB container
- `va_start_oracle_db()` - Starts Oracle Database container with Colima support for Apple Silicon
- `va_weblogic_status()` - Checks WebLogic and Oracle database container status
- `va_deploy_vbms()` - Deploys VBMS applications to WebLogic
- `wl_java()` - Activates the WebLogic Java environment

### System Requirements

- macOS on Apple Silicon (M1/M2/M3) Mac or Intel Mac
- Oracle JDK 1.8.0_45 installed at `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk`
- WebLogic Server installation (for WebLogic-related scripts)
</details>

## Screenshots

<details>
<summary><strong>Setup and Configuration Screenshots</strong></summary>

<sub>After initializing setup.sh</sub>

![CleanShot 2025-05-31 at 13 03 56@2x](https://github.com/user-attachments/assets/f0a6e1cd-6201-4ec8-944f-8676f6b476a4)

<sub>java configuration</sub>

![CleanShot 2025-05-31 at 13 04 55@2x](https://github.com/user-attachments/assets/3ea128a7-583c-43d7-bb6a-ca18257db99a)

<sub>weblogic configuration</sub>

![CleanShot 2025-05-31 at 13 05 22@2x](https://github.com/user-attachments/assets/003dc10d-f3a0-4dc0-95e5-11472ae4cb65)

<sub></sub>

![CleanShot 2025-05-31 at 13 06 05@2x](https://github.com/user-attachments/assets/0b4b49f5-8905-498e-9eb0-649d82fd1927)

<sub>After option 4</sub>

![CleanShot 2025-05-31 at 13 06 42@2x](https://github.com/user-attachments/assets/459b29ec-7b8d-4816-80b5-8a675f960b90)

<sub>Utility script added to .zshrc `wl_java`</sub>

![CleanShot 2025-05-31 at 16 37 13@2x](https://github.com/user-attachments/assets/2ed4dcb0-f276-4e26-8b11-a0cda08da52d)

<sub>`./verify-java-limited.sh`</sub>

![CleanShot 2025-05-31 at 17 02 24@2x](https://github.com/user-attachments/assets/e1d5cb9a-b377-457b-ad2e-70dfdec304b5)

</details>
