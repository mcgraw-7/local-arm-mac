---
layout: default
title: Setup Options
---

# Setup Options Documentation

This document details all available options in the main setup script (`setup.sh`) and their purposes.

## Overview

The setup script provides a comprehensive set of tools for configuring and managing your Java/WebLogic development environment on Apple Silicon Macs. Each option is designed to handle a specific aspect of the setup process.

## Available Options

### 1. Configure Java Environment (Limited Access, No Sudo)

- **Script**: `scripts/java/limited-access-java-env.sh`
- **Purpose**: Sets up Java environment without requiring sudo access
- **Changes**: Modifies `.zshrc` and creates Java wrapper scripts
- **Warning**: This will modify multiple files including `.zshrc`

### 2. Configure WebLogic-specific Environment

- **Script**: `scripts/weblogic/setup-wl-java.sh`
- **Purpose**: Configures environment specifically for WebLogic
- **Changes**: Modifies `.zshrc` and creates WebLogic environment files
- **Warning**: This will modify `.zshrc`

### 3. Verify Java Standardization

- **Script**: `scripts/utils/verify-standardization.sh`
- **Purpose**: Verifies that Java environment is properly standardized
- **Checks**: Java version, paths, and configuration

### 4. Update Scripts (Non-sudo Mode)

- **Script**: `scripts/utils/update-scripts-without-sudo.sh`
- **Purpose**: Updates script files without requiring sudo access
- **Warning**: This will update multiple script files

### 5. Configure Java Environment for WebLogic

- **Script**: `scripts/weblogic/weblogic-java-env-limited.sh`
- **Purpose**: Sets up Java environment specifically for WebLogic
- **Changes**: Configures Java environment variables and paths

### 6. Add VA Environment Helper Functions

- **Script**: `scripts/utils/add-va-env-function.sh`
- **Purpose**: Adds VA environment helper functions to `.zshrc`
- **Function**: `va_env()`

### 7. Add WebLogic Status Helper Function

- **Script**: `scripts/utils/add-va-weblogic-status-function.sh`
- **Purpose**: Adds WebLogic status checking function to `.zshrc`
- **Function**: `va_weblogic_status()`

### 8. Add VBMS Deployment Helper Function

- **Script**: `scripts/utils/add-va-deploy-vbms-function.sh`
- **Purpose**: Adds VBMS deployment helper function to `.zshrc`
- **Function**: `va_deploy_vbms()`

### 9. Add WebLogic Start with Oracle DB Verification

- **Script**: `scripts/utils/add-va-start-weblogic-function.sh`
- **Purpose**: Adds WebLogic startup functions with Oracle DB verification
- **Functions**: `va_start_weblogic()`, `va_start_oracle_db()`

### 10. Create WebLogic Domain with Oracle DB Verification

- **Script**: `scripts/weblogic/create-domain-m3-fixed.sh`
- **Purpose**: Creates WebLogic domain after verifying Oracle DB
- **Prerequisites**: Oracle DB container must be running

### 11. Verify Oracle DB Container for WebLogic

- **Script**: `scripts/weblogic/verify-oracle-db.sh`
- **Purpose**: Verifies Oracle DB container configuration
- **Checks**: Container status, connection, and configuration

### 12. Verify Oracle WebLogic Directory Structure

- **Script**: `scripts/utils/verify-oracle-directory.sh`
- **Purpose**: Verifies WebLogic installation directory structure
- **Standard Path**: `${HOME}/dev/Oracle/Middleware/Oracle_Home`

### 13. Manage Oracle Database (Apple Silicon Support)

- **Script**: `scripts/weblogic/manage-oracle-db.sh`
- **Purpose**: Manages Oracle Database with Apple Silicon support
- **Features**: Start, stop, and verify database operations

### 14. Check Apple Silicon Compatibility

- **Script**: `scripts/utils/check-apple-silicon.sh`
- **Purpose**: Verifies Apple Silicon compatibility
- **Checks**: Architecture, Rosetta 2, and system requirements

### 15. Clean Up Temporary Files and Artifacts

- **Script**: `scripts/utils/cleanup-artifacts.sh`
- **Purpose**: Removes temporary files and artifacts
- **Scope**: Git repository cleanup

### 16. View README Documentation

- **Purpose**: Displays README documentation
- **Formats**: Supports multiple markdown viewers (glow, mdless, bat, less)

## Script Organization

The scripts are organized into the following directories:

### `/scripts/java/`

- Java environment configuration scripts
- Java verification tools

### `/scripts/weblogic/`

- WebLogic configuration and management scripts
- Domain creation and verification tools

### `/scripts/utils/`

- Helper functions and utility scripts
- Environment verification tools
- Cleanup and maintenance scripts

### `/scripts/vbms/`

- VBMS-specific scripts and tools
- Compatibility verification

## Best Practices

1. **Order of Operations**:

   - Start with option 14 to verify Apple Silicon compatibility
   - Configure Java environment (option 1)
   - Set up WebLogic environment (option 2)
   - Verify standardization (option 3)

2. **Environment Setup**:

   - Use option 5 for WebLogic-specific Java configuration
   - Add helper functions (options 6-9) for easier management
   - Verify Oracle DB before domain creation

3. **Maintenance**:
   - Regularly verify standardization (option 3)
   - Clean up artifacts (option 15) before commits
   - Check Apple Silicon compatibility after system updates

## Troubleshooting

If you encounter issues:

1. Run option 14 to verify Apple Silicon compatibility
2. Use option 3 to check Java standardization
3. Verify Oracle DB with option 11
4. Check WebLogic directory structure with option 12

For detailed troubleshooting, refer to the specific script documentation in `script-reference.md`.

<div class="quick-nav">
  <h2>Quick Navigation</h2>
  <div class="quick-nav-grid">
    <a href="#option-1" class="quick-nav-btn">1. Configure Java envir...</a>
    <a href="#option-2" class="quick-nav-btn">2. Configure WebLogic-s...</a>
    <a href="#option-3" class="quick-nav-btn">3. Verify Java standard...</a>
    <a href="#option-4" class="quick-nav-btn">4. Update scripts (non-...</a>
    <a href="#option-5" class="quick-nav-btn">5. Run with Oracle JDK ...</a>
    <a href="#option-6" class="quick-nav-btn">6. Add VA Environment h...</a>
    <a href="#option-7" class="quick-nav-btn">7. Add WebLogic status ...</a>
    <a href="#option-8" class="quick-nav-btn">8. Add VBMS deployment ...</a>
    <a href="#option-9" class="quick-nav-btn">9. Add WebLogic start w...</a>
    <a href="#option-10" class="quick-nav-btn">10. Create WebLogic doma...</a>
    <a href="#option-11" class="quick-nav-btn">11. Verify Oracle DB con...</a>
    <a href="#option-12" class="quick-nav-btn">12. Verify Oracle WebLog...</a>
    <a href="#option-13" class="quick-nav-btn">13. Manage Oracle Databa...</a>
    <a href="#option-14" class="quick-nav-btn">14. Check Apple Silicon ...</a>
    <a href="#option-15" class="quick-nav-btn">15. Clean up temporary f...</a>
    <a href="#option-16" class="quick-nav-btn">16. Update GitHub Pages ...</a>
    <a href="#option-17" class="quick-nav-btn">17. Exit...</a>
  </div>
</div>

<div class="options-container">
<div class="option-card" id="option-1">
  <h2 class="option-title">1. Configure Java environment (limited access, no sudo)</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>1</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-2">
  <h2 class="option-title">2. Configure WebLogic-specific environment</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>2</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-3">
  <h2 class="option-title">3. Verify Java standardization</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>3</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-4">
  <h2 class="option-title">4. Update scripts (non-sudo mode)</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>4</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-5">
  <h2 class="option-title">5. Run with Oracle JDK wrapper</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>5</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-6">
  <h2 class="option-title">6. Add VA Environment helper functions</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>6</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-7">
  <h2 class="option-title">7. Add WebLogic status helper function</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>7</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-8">
  <h2 class="option-title">8. Add VBMS deployment helper function</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>8</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-9">
  <h2 class="option-title">9. Add WebLogic start with Oracle DB verification helper functions </h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>9</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-10">
  <h2 class="option-title">10. Create WebLogic domain with Oracle DB verification</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>10</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-11">
  <h2 class="option-title">11. Verify Oracle DB container for WebLogic </h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>11</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-12">
  <h2 class="option-title">12. Verify Oracle WebLogic standardized directory structure</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>12</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-13">
  <h2 class="option-title">13. Manage Oracle Database (with Apple Silicon support)</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>13</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-14">
  <h2 class="option-title">14. Check Apple Silicon compatibility</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>14</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-15">
  <h2 class="option-title">15. Clean up temporary files and artifacts</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>15</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-16">
  <h2 class="option-title">16. Update GitHub Pages index from README</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>16</strong> to select this option.</p>
    </div>
  </div>
</div>
<div class="option-card" id="option-17">
  <h2 class="option-title">17. Exit</h2>
  <div class="option-content">
<p>For more information, please refer to the repository documentation.</p>
    <div class="run-option">
      <h4>Run this option</h4>
      <div class="command-box">
        <code>cd ~/dev/local-arm-mac && ./setup.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
      <p class="option-note">When prompted, enter <strong>17</strong> to select this option.</p>
    </div>
  </div>
</div>
</div>

<script>
function copyToClipboard(btn) {
  const commandText = btn.previousElementSibling.textContent;
  navigator.clipboard.writeText(commandText).then(() => {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<span class="copy-icon">✅</span><span class="copy-text">Copied!</span>';
    
    setTimeout(() => {
      btn.innerHTML = originalText;
    }, 2000);
  });
}
</script>
