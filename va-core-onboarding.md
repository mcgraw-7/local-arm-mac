# VA Core Developer Onboarding Guide

## Welcome!
This guide will help you set up your local development environment for VA Core applications using WebLogic. Follow these steps to get up and running quickly.

## Prerequisites

Before you begin, ensure you have:

1. **Mac computer** (Apple Silicon M1/M2/M3 or Intel)
2. **macOS** 12.0 (Monterey) or newer
3. **Command Line Tools** for Xcode (run `xcode-select --install` to install)
4. **Git** installed
5. **Docker Desktop** installed
6. **Oracle JDK 1.8.0_45** installed at `/Library/Java/JavaVirtualMachines/jdk1.8.0_45.jdk`

## Step 1: Clone the Repository

```bash
# Clone the VA local setup repository
git clone https://github.com/department-of-veterans-affairs/va-local-setup.git
cd va-local-setup

# Run the setup script
./setup.sh
```

## Step 2: Activate the VA Environment

After running the setup script, activate the VA development environment:

```bash
# Option 1: Direct activation
source ~/.va_env

# Option 2: Using the helper function
va_env
```

## Step 3: Verify Your Setup

Run the verification script to ensure everything is configured correctly:

```bash
~/dev/verify-standardization.sh
```

You should see confirmation that:
- Oracle JDK 1.8.0_45 is being used
- The environment variables are correctly set
- Standardized WebLogic scripts are available

## Step 4: Start WebLogic (if already installed)

If WebLogic is already installed, you can start it with:

```bash
va_start_weblogic
```

## Step 5: Check WebLogic Status

Check the status of your WebLogic environment:

```bash
va_weblogic_status
```

This will show what components are properly configured and what still needs to be set up.

## Step 6: Complete WebLogic Installation (if needed)

If WebLogic is not yet installed, follow these steps:

1. Download the WebLogic installer jar (`fmw_12.2.1.4.0_wls_lite_generic.jar`) to `~/dev/`
2. Run the WebLogic installation:
   ```bash
   cd ~/dev
   ~/dev/standardized-scripts/run-weblogic.sh weblogic-m3-installer.sh
   ```

3. Create the WebLogic domain:
   ```bash
   ~/dev/standardized-scripts/run-weblogic.sh create-domain-m3.sh
   ```

## Step 7: Deploy VBMS Applications (if needed)

Deploy the VBMS applications to your WebLogic server:

```bash
va_deploy_vbms
```

## Step 8: Access WebLogic Console

Once WebLogic is running, you can access the Admin Console at:
http://localhost:7001/console

Default credentials:
- Username: `weblogic`
- Password: `welcome1`

## Step 9: Access VBMS Applications

After deploying VBMS applications, you can access them at:
- VBMS UI: http://localhost:7001/vbms-ui-app
- VBMS Core: http://localhost:7001/vbms-core-app
- Authentication: http://localhost:7001/jvm-proxy-authentication-war

## Step 10: Daily Development Workflow

1. Start your day by activating the VA environment:
   ```bash
   va_env
   ```

2. Start WebLogic:
   ```bash
   va_start_weblogic
   ```

3. Deploy any modified applications:
   ```bash
   va_deploy_vbms
   ```

4. Work on your assigned tasks

5. To stop WebLogic when you're done:
   ```bash
   ~/dev/standardized-scripts/run-weblogic.sh stop-weblogic.sh
   ```

## Troubleshooting

If you encounter issues:

1. Check the logs:
   ```bash
   ls -l ~/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV/servers/AdminServer/logs
   ```

2. Run the diagnostics:
   ```bash
   ~/dev/standardized-scripts/core-config-status.sh
   ```

3. Verify your Java environment:
   ```bash
   ~/dev/verify-standardization.sh
   ```

4. Visit the VA Local Setup wiki for more detailed troubleshooting guides.

## Need Help?

Contact the VA Core Development team:
- Slack: #va-core-dev-help
- Email: va-core-dev-support@va.gov

Welcome to the team!
