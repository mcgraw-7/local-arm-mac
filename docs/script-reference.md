---
layout: default
title: Script Reference
---

# Script Reference Documentation

This document provides detailed information about each script in the repository, their purposes, and usage.

## Directory Structure

```
scripts/
├── java/           # Java environment configuration
├── weblogic/       # WebLogic configuration and management
├── utils/          # Utility scripts and helper functions
└── vbms/           # VBMS-specific scripts
```

## Java Environment Scripts

### `scripts/java/limited-access-java-env.sh`

- **Purpose**: Configures Java environment without sudo access
- **Usage**: Run during initial setup
- **Changes**: Modifies `.zshrc` and creates Java wrapper scripts
- **Dependencies**: Oracle JDK 1.8.0_45

### `scripts/java/verify-java-limited.sh`

- **Purpose**: Verifies Java environment configuration
- **Usage**: Run after environment setup
- **Checks**: Java version, paths, and environment variables

## WebLogic Scripts

### `scripts/weblogic/create-domain-m3-fixed.sh`

- **Purpose**: Creates WebLogic domain for M3 Macs
- **Usage**: Run after Oracle DB is verified
- **Prerequisites**: Oracle DB container running
- **Features**: ARM64 compatibility, Oracle DB verification

### `scripts/weblogic/check-weblogic-status.sh`

- **Purpose**: Checks WebLogic server status
- **Usage**: Run to verify server health
- **Checks**: Server status, ports, and connections

### `scripts/weblogic/start-weblogic.sh`

- **Purpose**: Starts WebLogic server
- **Usage**: Run to start the server
- **Features**: Environment verification, error handling

### `scripts/weblogic/verify-oracle-db.sh`

- **Purpose**: Verifies Oracle DB configuration
- **Usage**: Run before domain creation
- **Checks**: Container status, connection, and configuration

### `scripts/weblogic/manage-oracle-db.sh`

- **Purpose**: Manages Oracle Database
- **Usage**: Run to start/stop/verify database
- **Features**: Apple Silicon support, Colima integration

### `scripts/weblogic/setup-wl-java.sh`

- **Purpose**: Configures Java for WebLogic
- **Usage**: Run during initial setup
- **Changes**: Sets up WebLogic-specific Java environment

### `scripts/weblogic/weblogic-java-env-limited.sh`

- **Purpose**: Sets up limited-access Java environment for WebLogic
- **Usage**: Run after Java environment setup
- **Features**: No sudo required, standardized paths

### `scripts/weblogic/cleanup-weblogic.sh`

- **Purpose**: Cleans up WebLogic artifacts
- **Usage**: Run to remove temporary files
- **Scope**: WebLogic-specific cleanup

## Utility Scripts

### `scripts/utils/verify-standardization.sh`

- **Purpose**: Verifies environment standardization
- **Usage**: Run to check configuration
- **Checks**: Java, WebLogic, and Oracle DB configuration

### `scripts/utils/check-apple-silicon.sh`

- **Purpose**: Verifies Apple Silicon compatibility
- **Usage**: Run during setup and after updates
- **Checks**: Architecture, Rosetta 2, system requirements

### `scripts/utils/verify-oracle-directory.sh`

- **Purpose**: Verifies WebLogic directory structure
- **Usage**: Run to check installation
- **Standard Path**: `${HOME}/dev/Oracle/Middleware/Oracle_Home`

### `scripts/utils/show-complete-configuration.sh`

- **Purpose**: Shows complete environment configuration
- **Usage**: Run to view all settings
- **Output**: Detailed configuration report

### `scripts/utils/update-scripts-without-sudo.sh`

- **Purpose**: Updates scripts without sudo
- **Usage**: Run to update script files
- **Features**: No sudo required, safe updates

### `scripts/utils/cleanup-artifacts.sh`

- **Purpose**: Cleans up temporary files
- **Usage**: Run before commits
- **Scope**: Git repository cleanup

### Helper Function Scripts

#### `scripts/utils/add-va-env-function.sh`

- **Purpose**: Adds VA environment function
- **Function**: `va_env()`
- **Usage**: Run during setup

#### `scripts/utils/add-va-weblogic-status-function.sh`

- **Purpose**: Adds WebLogic status function
- **Function**: `va_weblogic_status()`
- **Usage**: Run during setup

#### `scripts/utils/add-va-deploy-vbms-function.sh`

- **Purpose**: Adds VBMS deployment function
- **Function**: `va_deploy_vbms()`
- **Usage**: Run during setup

#### `scripts/utils/add-va-start-weblogic-function.sh`

- **Purpose**: Adds WebLogic startup functions
- **Functions**: `va_start_weblogic()`, `va_start_oracle_db()`
- **Usage**: Run during setup

## VBMS Scripts

### `scripts/vbms/check-vbms-compatibility.sh`

- **Purpose**: Verifies VBMS compatibility
- **Usage**: Run to check VBMS setup
- **Checks**: VBMS-specific requirements

## Best Practices

1. **Script Execution Order**:

   - Start with environment verification
   - Configure Java environment
   - Set up WebLogic
   - Verify Oracle DB
   - Create domain

2. **Environment Setup**:

   - Use limited-access scripts when possible
   - Verify standardization regularly
   - Check Apple Silicon compatibility

3. **Maintenance**:
   - Clean up artifacts regularly
   - Update scripts as needed
   - Verify configuration after changes

## Troubleshooting

1. **Common Issues**:

   - Java version mismatches
   - WebLogic directory structure
   - Oracle DB connection problems
   - Apple Silicon compatibility

2. **Resolution Steps**:
   - Run verification scripts
   - Check error logs
   - Verify prerequisites
   - Consult specific script documentation

## Script Dependencies

- Oracle JDK 1.8.0_45
- WebLogic 12.2.1.4.0
- Oracle Database (container)
- Apple Silicon Mac with Rosetta 2

## Security Considerations

1. **Limited Access**:

   - Scripts designed to work without sudo
   - Environment-specific permissions
   - Secure credential handling

2. **Best Practices**:
   - Regular verification
   - Cleanup of sensitive data
   - Proper error handling

## Maintenance

1. **Regular Tasks**:

   - Verify standardization
   - Clean up artifacts
   - Check compatibility
   - Update scripts

2. **Update Process**:
   - Use update scripts
   - Verify changes
   - Test functionality
   - Document updates

<div class="script-search-container">
  <input type="text" id="scriptSearchInput" placeholder="Search for scripts..." onkeyup="filterScripts()">
  <select id="categoryFilter" onchange="filterScripts()">
    <option value="all">All Categories</option>
    <option value="java">Java Environment</option>
    <option value="weblogic">WebLogic</option>
    <option value="utils">Utilities</option>
  </select>
</div>

<script>
function filterScripts() {
  const input = document.getElementById('scriptSearchInput');
  const filter = input.value.toLowerCase();
  const category = document.getElementById('categoryFilter').value;
  
  const sections = document.querySelectorAll('.script-section');
  const cards = document.querySelectorAll('.script-card');
  
  // First hide/show sections based on category
  sections.forEach(section => {
    const sectionCategory = section.getAttribute('data-category');
    if(category === 'all' || sectionCategory === category) {
      section.style.display = '';
    } else {
      section.style.display = 'none';
    }
  });
  
  // Then filter cards by search term
  let visibleCount = 0;
  cards.forEach(card => {
    const section = card.closest('.script-section');
    const sectionVisible = section.style.display !== 'none';
    
    const title = card.querySelector('h3').textContent.toLowerCase();
    const desc = card.querySelector('.script-description').textContent.toLowerCase();
    
    if(sectionVisible && (title.includes(filter) || desc.includes(filter))) {
      card.style.display = '';
      visibleCount++;
    } else {
      card.style.display = 'none';
    }
  });
  
  document.getElementById('noResultsMsg').style.display = visibleCount === 0 ? 'block' : 'none';
}
</script>

<p id="noResultsMsg" style="display:none;">No scripts match your search criteria. Try a different search term or category.</p>

<section class="script-section" data-category="java">
## Java Environment Scripts

<div class="script-grid">
<div class="script-card">
  <h3>limited-access-java-env.sh</h3>
  <div class="script-description">Java Environment Configuration for Limited Access Users</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/java/limited-access-java-env.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>run-with-oracle-jdk.sh</h3>
  <div class="script-description">Run a command using Oracle JDK 1.8.0_45</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p> echo "Runs the specified command with Oracle JDK 1.8.0_45" exit 1 fi </p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/java/run-with-oracle-jdk.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>verify-java-limited.sh</h3>
  <div class="script-description">Java Configuration Verification Script (Limited Access)</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/java/verify-java-limited.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
</div>
</section>
<section class="script-section" data-category="weblogic">
## WebLogic Scripts

<div class="script-grid">
<div class="script-card">
  <h3>check-weblogic-status.sh</h3>
  <div class="script-description">Comprehensive WebLogic Status & Diagnostics Script for Apple Silicon Compatibility Issues</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>Run this script to get a comprehensive diagnostic report of your WebLogic server, including status, configuration, Java compatibility, and common error detection focused on Apple Silicon compatibility issues.</p>
      
      <h4>Key Features</h4>
      <ul>
        <li>Detects BouncyCastle cryptography library compatibility issues</li>
        <li>Analyzes deployment failures and NullPointerExceptions</li>
        <li>Checks Java version and JVM compatibility with Apple Silicon</li>
        <li>Monitors system resources and WebLogic process health</li>
        <li>Provides specific remediation steps for common errors</li>
      </ul>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/weblogic/check-weblogic-status.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>create-domain-m3.sh</h3>
  <div class="script-description">WebLogic Domain Creation Script for VBMS on M3 Mac with Oracle DB Verification</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/weblogic/create-domain-m3.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>manage-oracle-db.sh</h3>
  <div class="script-description"></div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/weblogic/manage-oracle-db.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>setup-wl-java.sh</h3>
  <div class="script-description">Simple WebLogic Java Environment Setup (No Sudo Required)</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p> echo "Runs the specified command with Oracle JDK 1.8.0_45" exit 1 fi </p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/weblogic/setup-wl-java.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>standardize-weblogic-scripts.sh</h3>
  <div class="script-description">Script to update WebLogic scripts to use the standardized JDK</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p> SCRIPT_DIR="\$(dirname "\$0")" ORACLE_JDK="$JDK_PATH" </p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/weblogic/standardize-weblogic-scripts.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>start-weblogic.sh</h3>
  <div class="script-description">WebLogic Start Script with Oracle DB Container Check</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/weblogic/start-weblogic.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>verify-oracle-db.sh</h3>
  <div class="script-description">Script to verify WebLogic domain configuration with Oracle Database</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/weblogic/verify-oracle-db.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>weblogic-java-env-limited.sh</h3>
  <div class="script-description">WebLogic-specific Java Environment Configuration</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/weblogic/weblogic-java-env-limited.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
</div>
</section>
<section class="script-section" data-category="utils">
## Utility Scripts

<div class="script-grid">
<div class="script-card">
  <h3>add-va-deploy-vbms-function.sh</h3>
  <div class="script-description">Add va_deploy_vbms helper function to user's .zshrc</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/add-va-deploy-vbms-function.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>add-va-env-function.sh</h3>
  <div class="script-description">Add VA Environment Function to User Profile</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/add-va-env-function.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>add-va-start-weblogic-function.sh</h3>
  <div class="script-description">Add VA WebLogic Start Function to User Profile</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/add-va-start-weblogic-function.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>add-va-weblogic-status-function.sh</h3>
  <div class="script-description">Add va_weblogic_status helper function to user's .zshrc</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/add-va-weblogic-status-function.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>check-apple-silicon.sh</h3>
  <div class="script-description">Script to check and set up Apple Silicon compatibility for Oracle and WebLogic</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/check-apple-silicon.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>cleanup-artifacts.sh</h3>
  <div class="script-description">Script to clean up temporary files and artifacts in the WebLogic environment</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/cleanup-artifacts.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>cleanup-untracked-files.sh</h3>
  <div class="script-description">Script to clean up unnecessary files that shouldn't be in the repository</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/cleanup-untracked-files.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>update-github-pages.sh</h3>
  <div class="script-description">Script to update GitHub Pages content from the repository - enhanced version</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p> if [ -z "$usage" ]; then usage="See script for details" </p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/update-github-pages.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>update-scripts-without-sudo.sh</h3>
  <div class="script-description">Script to update JAVA_HOME in WebLogic shell scripts without sudo</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/update-scripts-without-sudo.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>verify-oracle-directory.sh</h3>
  <div class="script-description">Verify and enforce Oracle WebLogic standardized directory structure</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/verify-oracle-directory.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
<div class="script-card">
  <h3>verify-standardization.sh</h3>
  <div class="script-description">WebLogic Java Standardization Verification</div>
  
  <details>
    <summary>Usage & Details</summary>
    <div class="script-details">
      <h4>Usage</h4>
      <p>See script for details</p>
      
      <h4>Run Command</h4>
      <div class="command-box">
        <code>./scripts/utils/verify-standardization.sh</code>
        <button class="copy-btn" onclick="copyToClipboard(this)">
          <span class="copy-icon">📋</span>
          <span class="copy-text">Copy</span>
        </button>
      </div>
    </div>
  </details>
</div>
</div>
</section>

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
