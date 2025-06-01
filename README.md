# local-arm-mac

Configuration scripts for VA Core local development environment setup. Automates dependency checks, environment validation, and WebLogic/Oracle configuration for Apple Silicon (M1/M2/M3) and Intel Macs. Reduces "it works on my machine" issues and streamlines developer onboarding.

## Apple Silicon Compatibility

This repository includes comprehensive support for running Oracle WebLogic and Oracle Database on Apple Silicon (arm64) Macs:

- **Automatic detection** of Apple Silicon architecture
- **Colima integration** for running Oracle Database containers
- **Environment variables** optimized for M-series chips
- **Helper functions** that work seamlessly across architectures
- **Special handling** of platform-specific Docker commands

For detailed information, see [Apple Silicon Compatibility Guide](docs/apple-silicon-compatibility.md)

<sub>this is work in progress.</sub></br>
<sub>i've tested these scripts and provided screenshots of results</sub></br>
<sub>please, make sure you
- KNOW what you _have_ configured
- KNOW what you _need_ configured</sub>

>> also, my understanding is if you use Homebrew to install anything created by Oracle, Homebrew will use an open source option to bypass the Oracle account creation process, which is normally very useful, but not here.
>>
>> You need the top shelf Oracle branded JDK.

## Important Directory Structure Requirements

WebLogic **must** be installed in the Oracle standardized directory:
```
${HOME}/dev/Oracle/Middleware/Oracle_Home
```

No deviations from this directory structure are permitted. All scripts in this repository enforce this requirement to ensure proper functionality and compatibility with VA systems.

## Repository Structure

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

## Available Scripts

### Java Environment Scripts

- `limited-access-java-env.sh` - Configures the Java environment without requiring sudo access
- `run-with-oracle-jdk.sh` - Runs a command with the Oracle JDK environment
- `verify-java-limited.sh` - Verifies the Java environment configuration

### WebLogic Scripts

- `setup-wl-java.sh` - Sets up the WebLogic Java environment
- `weblogic-java-env-limited.sh` - Configures WebLogic-specific Java settings
- `standardize-weblogic-scripts.sh` - Standardizes WebLogic scripts to use the correct JDK
- `start-weblogic.sh` - Starts the WebLogic server with Oracle DB verification
- `create-domain-m3.sh` - Creates WebLogic domain with Oracle DB verification
- `verify-oracle-db.sh` - Verifies Oracle DB container for WebLogic operation
- `manage-oracle-db.sh` - Manages Oracle Database with Apple Silicon support

### VBMS Scripts

- `check-vbms-compatibility.sh` - Checks VBMS application compatibility with WebLogic on Apple Silicon

### Utility Scripts

- `update-scripts-without-sudo.sh` - Updates scripts without requiring sudo access
- `verify-standardization.sh` - Verifies the standardization of the environment
- `verify-oracle-directory.sh` - Verifies WebLogic is installed in the standardized directory
- `check-apple-silicon.sh` - Checks and sets up Apple Silicon compatibility for Oracle and WebLogic
- `cleanup-artifacts.sh` - Cleans up temporary files and artifacts that shouldn't be in Git
- `add-va-env-function.sh` - Adds VA environment helper function to .zshrc
- `add-va-start-weblogic-function.sh` - Adds VA start WebLogic helper function to .zshrc
- `add-va-weblogic-status-function.sh` - Adds VA WebLogic status helper function to .zshrc
- `add-va-deploy-vbms-function.sh` - Adds VA VBMS deployment helper function to .zshrc

## Helper Functions

The following helper functions are available once you've run the setup script:

- `va_env()` - Activates the VA Core Development Environment
- `va_start_weblogic()` - Starts WebLogic server after verifying Oracle DB container with Apple Silicon support
- `va_start_oracle_db()` - Starts Oracle Database container with Colima support for Apple Silicon
- `va_weblogic_status()` - Checks WebLogic and Oracle database container status
- `va_deploy_vbms()` - Deploys VBMS applications to WebLogic

## Oracle Database Container

This environment is configured to work with Oracle Database in a Docker container. Several scripts check for and verify that the Oracle Database container is running before executing WebLogic operations that require database access.

### Standard Setup (Intel Macs)
To ensure proper operation on Intel Macs:
1. Make sure Docker Desktop is running
2. Verify that the Oracle database container is running
3. Use the included helper functions to manage WebLogic and VBMS deployments

### Apple Silicon Setup (M1/M2/M3 Macs)
For Apple Silicon Macs, the process is slightly different:
1. Run the compatibility check script: `./scripts/utils/check-apple-silicon.sh`
2. Install Colima if needed: `brew install colima` 
3. Start Colima with proper settings: `colima start -c 4 -m 12 -a x86_64`
4. Use the `manage-oracle-db.sh` script or `va_start_oracle_db()` helper function which handles platform-specific requirements
5. All Oracle database containers will be created with `--platform linux/amd64` flag automatically

The `check-apple-silicon.sh` script will detect your environment and recommend any necessary changes for optimal compatibility. It will:
- Verify Colima installation and configuration
- Check Docker setup for compatibility 
- Verify Rosetta 2 installation
- Validate Oracle JDK compatibility
- Provide a comprehensive compatibility report

You can manage all Oracle Database operations through option 13 in the setup menu, which provides a comprehensive interface with Apple Silicon support.

## Documentation

- `docs/java-standardization-docs.md` - Detailed documentation of Java standardization
- `docs/apple-silicon-compatibility.md` - Information about compatibility with Apple Silicon (ARM) Macs

## Requirements

- macOS on Apple Silicon (M1/M2/M3) Mac or Intel Mac
- Oracle JDK 1.8.0_45 installed at `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk`
- WebLogic Server installation (for WebLogic-related scripts)

## Screenshots 

<sub>after initializing setup.sh</sub>


![CleanShot 2025-05-31 at 13 03 56@2x](https://github.com/user-attachments/assets/f0a6e1cd-6201-4ec8-944f-8676f6b476a4)

<sub>after option 1</sub>


![CleanShot 2025-05-31 at 13 04 55@2x](https://github.com/user-attachments/assets/3ea128a7-583c-43d7-bb6a-ca18257db99a)

<sub>after option 2</sub>


![CleanShot 2025-05-31 at 13 05 22@2x](https://github.com/user-attachments/assets/003dc10d-f3a0-4dc0-95e5-11472ae4cb65)

<sub>after option 3</sub>


![CleanShot 2025-05-31 at 13 06 05@2x](https://github.com/user-attachments/assets/0b4b49f5-8905-498e-9eb0-649d82fd1927)

<sub>after option 4</sub>


![CleanShot 2025-05-31 at 13 06 42@2x](https://github.com/user-attachments/assets/459b29ec-7b8d-4816-80b5-8a675f960b90)

<sub>utility script added to .zshrc `wl_java`</sub>

![CleanShot 2025-05-31 at 16 37 13@2x](https://github.com/user-attachments/assets/2ed4dcb0-f276-4e26-8b11-a0cda08da52d)

<sub>`./verify-java-limited.sh`</sub>

![CleanShot 2025-05-31 at 17 02 24@2x](https://github.com/user-attachments/assets/e1d5cb9a-b377-457b-ad2e-70dfdec304b5)



