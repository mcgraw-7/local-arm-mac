# local-arm-mac

Configuration scripts for VA Core local development environment setup. Automates dependency checks, environment validation, and WebLogic/Oracle configuration for Apple Silicon (M1/M2/M3) and Intel Macs. Reduces "it works on my machine" issues and streamlines developer onboarding.

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

### Utility Scripts

- `update-scripts-without-sudo.sh` - Updates scripts without requiring sudo access
- `verify-standardization.sh` - Verifies the standardization of the environment

## Documentation

- `docs/java-standardization-docs.md` - Detailed documentation of Java standardization
- `docs/apple-silicon-compatibility.md` - Information about compatibility with Apple Silicon (ARM) Macs

## Requirements

- macOS on Apple Silicon (M1/M2/M3) Mac or Intel Mac
- Oracle JDK 1.8.0_45 installed at `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk`
- WebLogic Server installation (for WebLogic-related scripts)

![CleanShot 2025-05-31 at 13 03 56@2x](https://github.com/user-attachments/assets/f0a6e1cd-6201-4ec8-944f-8676f6b476a4)

![CleanShot 2025-05-31 at 13 04 55@2x](https://github.com/user-attachments/assets/3ea128a7-583c-43d7-bb6a-ca18257db99a)

![CleanShot 2025-05-31 at 13 05 22@2x](https://github.com/user-attachments/assets/003dc10d-f3a0-4dc0-95e5-11472ae4cb65)

![CleanShot 2025-05-31 at 13 06 05@2x](https://github.com/user-attachments/assets/0b4b49f5-8905-498e-9eb0-649d82fd1927)

![CleanShot 2025-05-31 at 13 06 42@2x](https://github.com/user-attachments/assets/459b29ec-7b8d-4816-80b5-8a675f960b90)

