# local-arm-mac

Configuration scripts for VA Core local development environment setup. Automates dependency checks, environment validation, and WebLogic/Oracle configuration for Apple Silicon (M1/M2/M3) and Intel Macs. Reduces "it works on my machine" issues and streamlines developer onboarding.

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

## Repository Organization

The repository is divided into three main categories of scripts:
- **Testing Current Configuration** - Scripts that test and validate your current environment
- **Updating Existing Configuration** - Scripts that modify or update your environment
- **Utility Functions** - Helper scripts and utility functions to assist with common tasks

<details>
<summary><h2>🔍 Testing Current Configuration Scripts</h2></summary>

These scripts help you test, verify, and diagnose your current environment without making changes.

<details>
<summary><strong>Verify Java Standardization</strong></summary>

Verifies that the Java environment is correctly standardized for WebLogic development.

**What it does:**
- Checks for the correct Oracle JDK version
- Ensures that environment variables are properly configured
- Validates that Java wrapper scripts are correctly set up
- Verifies that the WebLogic environment can access the Oracle JDK

**Script:** `scripts/utils/verify-standardization.sh`

**Usage:**
```bash
./scripts/utils/verify-standardization.sh
```
</details>

<details>
<summary><strong>Verify Java Limited Access Setup</strong></summary>

Verifies the limited access Java environment setup.

**What it does:**
- Checks that the Java wrapper scripts are correctly set up
- Verifies environment variables for non-sudo Java operation
- Tests Java version and accessibility

**Script:** `scripts/java/verify-java-limited.sh`

**Usage:**
```bash
./scripts/java/verify-java-limited.sh
```
</details>

<details>
<summary><strong>Check Apple Silicon Compatibility</strong></summary>

Checks and determines compatibility with Apple Silicon (M1/M2/M3) Macs.

**What it does:**
- Detects Apple Silicon architecture
- Verifies Colima installation and configuration
- Checks Docker setup for compatibility
- Validates Rosetta 2 installation
- Verifies Oracle JDK compatibility
- Provides a comprehensive compatibility report with recommendations

**Script:** `scripts/utils/check-apple-silicon.sh`

**Usage:**
```bash
./scripts/utils/check-apple-silicon.sh
```
</details>

<details>
<summary><strong>Verify Oracle DB Container for WebLogic</strong></summary>

Verifies that the Oracle DB container is properly configured for WebLogic.

**What it does:**
- Checks if Docker/Colima is running
- Verifies the Oracle DB container status
- Displays container port mappings
- Checks WebLogic JDBC configurations for the database connection
- Offers to start the container if it's not running

**Script:** `scripts/weblogic/verify-oracle-db.sh`

**Usage:**
```bash
./scripts/weblogic/verify-oracle-db.sh
```
</details>

<details>
<summary><strong>Verify Oracle WebLogic Standardized Directory Structure</strong></summary>

Verifies that WebLogic is installed in the standardized directory structure.

**What it does:**
- Checks if WebLogic is installed in `${HOME}/dev/Oracle/Middleware/Oracle_Home`
- Validates the domain directory structure
- Ensures all required components are in the correct locations

**Script:** `scripts/utils/verify-oracle-directory.sh`

**Usage:**
```bash
./scripts/utils/verify-oracle-directory.sh
```
</details>

<details>
<summary><strong>Check VBMS Compatibility</strong></summary>

Checks if your environment is compatible with running VBMS applications.

**What it does:**
- Verifies WebLogic installation
- Checks VBMS-specific configuration requirements
- Validates DB configurations for VBMS
- Tests JVM versions and parameters needed by VBMS

**Script:** `scripts/vbms/check-vbms-compatibility.sh`

**Usage:**
```bash
./scripts/vbms/check-vbms-compatibility.sh
```
</details>

<details>
<summary><strong>WebLogic Status Checker</strong></summary>

Checks the status of the WebLogic server and its components.

**What it does:**
- Verifies if WebLogic Admin Server is running
- Checks for running Managed Servers
- Displays JDBC connection pool status
- Shows deployed application status

**Script:** `scripts/weblogic/weblogic-status.sh` 
(Note: This script is added via the add-va-weblogic-status-function.sh utility)

**Usage:**
After setup, you can check WebLogic status with:
```bash
va_weblogic_status
```
</details>
</details>

<details>
<summary><h2>☠️ Updating Existing Configuration Scripts ☠️</h2></summary>

☠️☠️☠️ These scripts modify your existing environment configuration. ☠️☠️☠️

<details>
<summary><strong>Configure Java Environment (Limited Access, No Sudo)</strong></summary>

Configures the Java environment for WebLogic development without requiring sudo access.

**What it does:**
- Creates a Java environment wrapper script
- Sets up environment variables for the Oracle JDK
- Adds necessary entries to your `.zshrc` file
- Ensures the correct Java version is used for WebLogic operations

**Script:** `scripts/java/limited-access-java-env.sh`

**Usage:**
```bash
./scripts/java/limited-access-java-env.sh
```

**Warning:** This will modify multiple files including .zshrc and create Java wrapper scripts.
</details>

<details>
<summary><strong>Configure WebLogic-specific Environment</strong></summary>

Sets up the WebLogic-specific environment settings and helper functions.

**What it does:**
- Creates WebLogic environment configuration files
- Sets up required environment variables for WebLogic
- Adds the `wl_java()` function to your `.zshrc` file
- Enables easy activation of the WebLogic Java environment

**Script:** `scripts/weblogic/setup-wl-java.sh`

**Usage:**
```bash
./scripts/weblogic/setup-wl-java.sh
```

After setup, you can activate the WebLogic environment with:
```bash
wl_java
```

**Warning:** This will modify `.zshrc` and create WebLogic environment files.
</details>

<details>
<summary><strong>Update Scripts (Non-Sudo Mode)</strong></summary>

Updates scripts without requiring sudo access.

**What it does:**
- Updates various WebLogic and Java configuration scripts
- Applies standardized headers and environment checks
- Updates environment variable handling
- Ensures proper Oracle JDK usage

**Script:** `scripts/utils/update-scripts-without-sudo.sh`

**Usage:**
```bash
./scripts/utils/update-scripts-without-sudo.sh
```

**Warning:** This will update multiple script files in your system.
</details>

<details>
<summary><strong>Run with Oracle JDK Wrapper</strong></summary>

Sets up a command wrapper to run arbitrary commands with the Oracle JDK environment.

**What it does:**
- Creates a script at `~/dev/run-with-oracle-jdk.sh`
- Allows running any command with the Oracle JDK environment variables
- Ensures consistent Java environment for WebLogic-related tasks

**Script:** `scripts/java/run-with-oracle-jdk.sh`

**Usage:**
After setup:
```bash
~/dev/run-with-oracle-jdk.sh [your command]
```
</details>

<details>
<summary><strong>Add VA Environment Helper Functions</strong></summary>

Adds the VA Environment helper function to your shell configuration.

**What it does:**
- Adds the `va_env()` function to your `.zshrc` file
- Enables easy activation of the VA Core Development Environment
- Sets up required environment variables for VA development

**Script:** `scripts/utils/add-va-env-function.sh`

**Usage:**
```bash
./scripts/utils/add-va-env-function.sh
```

After setup, you can activate the VA environment with:
```bash
va_env
```
</details>

<details>
<summary><strong>Add WebLogic Status Helper Function</strong></summary>

Adds a function to check WebLogic server status.

**What it does:**
- Adds the `va_weblogic_status()` function to your `.zshrc` file
- Provides an easy way to check if WebLogic is running
- Shows status information about the WebLogic server and its components

**Script:** `scripts/utils/add-va-weblogic-status-function.sh`

**Usage:**
```bash
./scripts/utils/add-va-weblogic-status-function.sh
```

After setup, you can check WebLogic status with:
```bash
va_weblogic_status
```
</details>

<details>
<summary><strong>Add VBMS Deployment Helper Function</strong></summary>

Adds a helper function for deploying VBMS applications.

**What it does:**
- Adds the `va_deploy_vbms()` function to your `.zshrc` file
- Simplifies the process of deploying VBMS applications to WebLogic
- Includes checks for WebLogic status before deployment

**Script:** `scripts/utils/add-va-deploy-vbms-function.sh`

**Usage:**
```bash
./scripts/utils/add-va-deploy-vbms-function.sh
```

After setup, you can deploy VBMS applications with:
```bash
va_deploy_vbms
```
</details>

<details>
<summary><strong>Add WebLogic Start with Oracle DB Verification Functions</strong></summary>

Adds functions to start WebLogic with Oracle DB verification.

**What it does:**
- Adds the `va_start_weblogic()` and `va_start_oracle_db()` functions to your `.zshrc` file
- Ensures Oracle DB is running before starting WebLogic
- Handles Apple Silicon compatibility automatically
- Includes platform-specific checks and optimizations

**Script:** `scripts/utils/add-va-start-weblogic-function.sh`

**Usage:**
```bash
./scripts/utils/add-va-start-weblogic-function.sh
```

After setup, you can start WebLogic with Oracle DB verification:
```bash
va_start_oracle_db  # Start Oracle DB if needed
va_start_weblogic   # Start WebLogic with verification
```
</details>

<details>
<summary><strong>Fix JDK Path</strong></summary>

Fixes incorrect JDK paths in your environment.

**What it does:**
- Corrects invalid JDK paths
- Updates environment variables and config files
- Ensures scripts use the correct JDK location

**Script:** `scripts/utils/fix-jdk-path.sh`

**Usage:**
```bash
./scripts/utils/fix-jdk-path.sh
```
</details>

<details>
<summary><strong>Standardize WebLogic Scripts</strong></summary>

Standardizes WebLogic scripts for consistent operation.

**What it does:**
- Updates WebLogic scripts with standardized headers
- Adds environment checks and error handling
- Ensures consistent variable naming and usage
- Applies best practices for WebLogic script management

**Script:** `scripts/weblogic/standardize-weblogic-scripts.sh`

**Usage:**
```bash
./scripts/weblogic/standardize-weblogic-scripts.sh
```
</details>
</details>

<details>
<summary><h2>🔧 Utility Scripts & Functions</h2></summary>

These scripts provide utility functions for managing and maintaining your environment.

<details>
<summary><strong>Create WebLogic Domain with Oracle DB Verification</strong></summary>

Creates a WebLogic domain after verifying that Oracle DB is properly configured.

**What it does:**
- Checks if Oracle DB container is running
- Creates a WebLogic domain with the proper configuration
- Ensures the domain is created in the standardized directory
- Sets up required JDBC data sources for the domain

**Script:** `scripts/weblogic/create-domain-m3.sh`

**Usage:**
```bash
./scripts/weblogic/create-domain-m3.sh
```

For debug mode:
```bash
./scripts/weblogic/create-domain-m3.sh --debug
```

For dry-run testing:
```bash
./scripts/weblogic/create-domain-m3.sh --dry-run
```

**Note:** This requires WebLogic to be installed in the standardized Oracle directory.
</details>

<details>
<summary><strong>Manage Oracle Database (with Apple Silicon Support)</strong></summary>

Comprehensive interface for managing Oracle Database with specific support for Apple Silicon.

**What it does:**
- Checks Docker/Colima status
- Provides options to download Oracle database images
- Creates, starts, and stops Oracle containers
- Shows database container logs
- Includes special handling for Apple Silicon (M1/M2/M3) Macs
- Sets proper platform flags for container creation on Apple Silicon

**Script:** `scripts/weblogic/manage-oracle-db.sh`

**Usage:**
```bash
./scripts/weblogic/manage-oracle-db.sh
```

**Features:**
- Automatically detects Apple Silicon and configures Colima
- Uses `--platform linux/amd64` flag for Oracle containers on Apple Silicon
- Manages container lifecycle and shows status information
</details>

<details>
<summary><strong>Start WebLogic with Checks</strong></summary>

Starts WebLogic after performing necessary checks.

**What it does:**
- Verifies Oracle DB is running
- Checks domain configuration
- Starts the WebLogic Admin Server with proper parameters
- Applies compatibility fixes for Apple Silicon Macs

**Script:** `scripts/weblogic/start-weblogic-with-checks.sh`

**Usage:**
```bash
./scripts/weblogic/start-weblogic-with-checks.sh
```
</details>

<details>
<summary><strong>Clean Up Temporary Files and Artifacts</strong></summary>

Helps remove temporary files and artifacts that should not be in the Git repository.

**What it does:**
- Searches for common WebLogic artifact files
- Identifies log files, backup files, and installer artifacts
- Provides options to remove these files
- Cleans up various temporary files that should be ignored by Git

**Script:** `scripts/utils/cleanup-artifacts.sh`

**Usage:**
```bash
./scripts/utils/cleanup-artifacts.sh
```
</details>

<details>
<summary><strong>Clean Up Untracked Files</strong></summary>

Cleans up untracked files that might be cluttering your repository.

**What it does:**
- Lists untracked files in the repository
- Offers options to remove specific types of files
- Provides interactive mode for selecting files

**Script:** `scripts/utils/cleanup-untracked-files.sh`

**Usage:**
```bash
./scripts/utils/cleanup-untracked-files.sh
```
</details>

<details>
<summary><strong>WebLogic Java Environment (Limited Access)</strong></summary>

Sets up a limited access WebLogic Java environment.

**What it does:**
- Creates environment variables for WebLogic operation
- Sets up Java wrapper for non-sudo operation
- Configures proper JVM parameters for WebLogic

**Script:** `scripts/weblogic/weblogic-java-env-limited.sh`

**Usage:**
```bash
./scripts/weblogic/weblogic-java-env-limited.sh
```
</details>
</details>

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
│   │   ├── limited-access-java-env.sh
│   │   ├── run-with-oracle-jdk.sh
│   │   └── verify-java-limited.sh
│   ├── weblogic/     # WebLogic-specific configuration scripts
│   │   ├── create-domain-m3.sh
│   │   ├── manage-oracle-db.sh
│   │   ├── setup-wl-java.sh
│   │   ├── start-weblogic-with-checks.sh
│   │   ├── start-weblogic.sh
│   │   └── verify-oracle-db.sh
│   ├── utils/        # Utility scripts for maintenance and verification
│   │   ├── add-va-*-function.sh  # Various helper function scripts
│   │   ├── check-apple-silicon.sh
│   │   ├── cleanup-artifacts.sh
│   │   ├── fix-jdk-path.sh
│   │   └── verify-standardization.sh
│   └── vbms/         # VBMS-specific scripts
│       └── check-vbms-compatibility.sh
├── docs/             # Documentation files
│   ├── java-standardization-docs.md
│   ├── weblogic-setup-guide.md
│   └── apple-silicon-compatibility.md
├── config/           # Configuration templates
│   ├── va-env-defaults.conf
│   └── weblogic-settings.conf
├── templates/        # Template files for environment setup
│   ├── weblogic-templates/
│   └── shell-templates/
└── setup.sh          # Main setup script (entry point)
```

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

<sub>After option 1</sub>

![CleanShot 2025-05-31 at 13 04 55@2x](https://github.com/user-attachments/assets/3ea128a7-583c-43d7-bb6a-ca18257db99a)

<sub>After option 2</sub>

![CleanShot 2025-05-31 at 13 05 22@2x](https://github.com/user-attachments/assets/003dc10d-f3a0-4dc0-95e5-11472ae4cb65)

<sub>After option 3</sub>

![CleanShot 2025-05-31 at 13 06 05@2x](https://github.com/user-attachments/assets/0b4b49f5-8905-498e-9eb0-649d82fd1927)

<sub>After option 4</sub>

![CleanShot 2025-05-31 at 13 06 42@2x](https://github.com/user-attachments/assets/459b29ec-7b8d-4816-80b5-8a675f960b90)

<sub>Utility script added to .zshrc `wl_java`</sub>

![CleanShot 2025-05-31 at 16 37 13@2x](https://github.com/user-attachments/assets/2ed4dcb0-f276-4e26-8b11-a0cda08da52d)

<sub>`./verify-java-limited.sh`</sub>

![CleanShot 2025-05-31 at 17 02 24@2x](https://github.com/user-attachments/assets/e1d5cb9a-b377-457b-ad2e-70dfdec304b5)
</details>
