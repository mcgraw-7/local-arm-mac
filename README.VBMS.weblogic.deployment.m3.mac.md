# VBMS WebLogic Deployment on M3 Mac

## Overview

This document outlines the process and known issues for deploying VA VBMS applications through WebLogic on Apple M3 Macs. The deployment process requires specific configurations and workarounds due to the ARM64 architecture of M3 chips.

## Prerequisites

### Required Software

- Java 8 (JDK 1.8.0_45 or later)
- WebLogic Server 12.2.1.4.0
- Docker (for Oracle database)
- Oracle Database 19c (running in Docker)

### Environment Setup

```bash
# Required environment variables
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_***.jdk/Contents/Home"
export WEBLOGIC_HOME="${HOME}/vbms-weblogic"
export DOMAIN_HOME="${WEBLOGIC_HOME}/user_projects/domains/P2-DEV"
```

## Known Issues and Solutions

### 1. ARM64 Compatibility

- **Issue**: WebLogic's default installation process includes CPU architecture checks that fail on M3 Macs
- **Solution**: Use the following environment variables to bypass checks:
  ```bash
  export BYPASS_CPU_CHECK=true
  export BYPASS_PREFLIGHT=true
  export DISABLE_WLSTARTMSGS=true
  ```

### 2. Memory Management

- **Issue**: Default memory settings can cause performance issues on M3 Macs
- **Solution**: Configure optimized JVM arguments:
  ```bash
  export CONFIG_JVM_ARGS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true"
  export USER_MEM_ARGS="-Xms512m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
  ```

### 3. Database Connection

- **Issue**: WebLogic requires Oracle database to be running before startup
- **Solution**: Script includes automatic database container check and startup:
  ```bash
  # Check if Oracle database is running
  DB_RUNNING=$(docker ps | grep "vbms-dev-docker-19c" | wc -l)
  if [ "$DB_RUNNING" -eq "0" ]; then
      docker start vbms-dev-docker-19c
      sleep 30  # Wait for database to initialize
  fi
  ```

### 4. File System Permissions

- **Issue**: WebLogic installation may fail due to permission issues
- **Solution**: Ensure proper directory permissions:
  ```bash
  mkdir -p "${WEBLOGIC_HOME}"
  chmod 755 "${WEBLOGIC_HOME}"
  ```

### 5. Silent Installation Issues

- **Issue**: Interactive prompts during installation can cause failures
- **Solution**: Use silent installation with response file:
  ```bash
  export ORACLE_NOWAIT=1
  export JAVA_OPTIONS="-Doracle.as.mode=core_complete -Djava.io.tmpdir=/tmp"
  ```

### 6. IIOP (Internet Inter-ORB Protocol) Issues

- **Issue**: IIOP communication failures between WebLogic and VBMS applications on M3 Mac
- **Symptoms**:
  - CORBA communication errors
  - Remote method invocation failures
  - Connection timeouts between components
- **Root Causes**:
  1. ARM64 architecture compatibility issues with IIOP implementation
  2. Default IIOP port conflicts with other services
  3. SSL/TLS handshake failures in IIOP communication
- **Solutions**:
  ```bash
  # Configure IIOP settings in WebLogic
  export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.enableSSL=true"
  export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.ssl.hostnameVerifier=weblogic.security.utils.SSLWLSHostnameVerifier"
  ```
  - Update domain configuration to use non-default IIOP ports
  - Ensure proper SSL certificates are configured for IIOP communication
  - Configure IIOP connection pool settings:
    ```bash
    # Add to domain configuration
    -Dweblogic.iiop.maxMessageSize=10485760
    -Dweblogic.iiop.connectionTimeout=30000
    ```

### IIOP Resolution Steps

1. **Domain Configuration Update**

   ```bash
   # Edit domain configuration
   cd ${DOMAIN_HOME}/config
   # Update config.xml to include IIOP settings
   <iiop>
     <enable-ssl>true</enable-ssl>
     <ssl-hostname-verifier>weblogic.security.utils.SSLWLSHostnameVerifier</ssl-hostname-verifier>
     <max-message-size>10485760</max-message-size>
     <connection-timeout>30000</connection-timeout>
   </iiop>
   ```

2. **SSL Certificate Configuration**

   ```bash
   # Generate SSL certificates for IIOP
   keytool -genkey -alias iiop-ssl -keyalg RSA -keystore iiop-keystore.jks
   # Import certificates into WebLogic trust store
   keytool -import -alias iiop-ssl -file iiop-cert.cer -keystore ${DOMAIN_HOME}/lib/keystore/trust.jks
   ```

3. **Port Configuration**

   ```bash
   # Update IIOP ports in domain configuration
   <iiop>
     <port>3700</port>
     <ssl-port>3701</ssl-port>
   </iiop>
   ```

4. **Connection Pool Settings**

   ```bash
   # Add to setDomainEnv.sh
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.minPoolSize=5"
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.maxPoolSize=50"
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.idleTimeout=300"
   ```

5. **Verification Steps**

   ```bash
   # Check IIOP status
   ${WL_HOME}/common/bin/wlst.sh
   connect('weblogic', 'weblogic1', 't3://localhost:7001')
   cd('Servers/AdminServer/IIOP')
   ls()
   ```

6. **Troubleshooting IIOP Issues**

   - Check IIOP logs: `${DOMAIN_HOME}/servers/AdminServer/logs/iiop.log`
   - Verify SSL handshake: `openssl s_client -connect localhost:3701`
   - Monitor IIOP connections: WebLogic Console -> Servers -> AdminServer -> Monitoring -> IIOP
   - Common error messages and solutions:
     ```
     "IIOP SSL handshake failed" -> Verify SSL certificates and trust store
     "Connection refused" -> Check port availability and firewall settings
     "CORBA communication error" -> Verify IIOP pool settings and connection timeouts
     ```

7. **Performance Tuning**

   ```bash
   # Add to setDomainEnv.sh for optimal IIOP performance
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.enableTunneling=true"
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.enableLocalOptimization=true"
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.enableServerSideThreadPool=true"
   ```

8. **Security Hardening**
   ```bash
   # Add to setDomainEnv.sh for enhanced IIOP security
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.enableClientAuthentication=true"
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.enableServerSideThreadPool=true"
   export CONFIG_JVM_ARGS="$CONFIG_JVM_ARGS -Dweblogic.iiop.enableTunneling=true"
   ```

## Deployment Process

### 1. Installation

```bash
# Run the installation script
./install-weblogic-fixed.sh
```

### 2. Domain Configuration

```bash
# Configure the domain
./vbmsDomain_buildSecurityRealm.py
```

### 3. Application Deployment

```bash
# Deploy VBMS applications
./deploy-vbms-m3.sh
```

## Application Access

After successful deployment, applications can be accessed at:

- JVM Proxy: http://localhost:7001/jvm-proxy-authentication-war
- VBMS Core: http://localhost:7001/vbms-core-app
- VBMS UI: http://localhost:7001/vbms-ui-app

## Troubleshooting

### Common Issues

1. **WebLogic Server Won't Start**

   - Check if Oracle database is running
   - Verify JAVA_HOME is correctly set
   - Check logs in `${DOMAIN_HOME}/servers/AdminServer/logs`

2. **Deployment Failures**

   - Ensure all required files are in the correct locations
   - Check application logs in WebLogic console
   - Verify keystore configurations

3. **Performance Issues**
   - Monitor memory usage
   - Check database connection pool settings
   - Review JVM garbage collection logs

### Log Files

- WebLogic Server Log: `${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log`
- Deployment Log: `${DOMAIN_HOME}/servers/AdminServer/logs/deployment.log`

## Security Considerations

1. **Keystore Configuration**

   - Ensure proper keystore paths in domain configuration
   - Verify keystore passwords are correctly set
   - Check SSL configuration in WebLogic console

2. **Cross-Domain Security**
   - Configure cross-domain security settings
   - Set up proper credential mappings
   - Verify security realm configuration

## Maintenance

### Regular Tasks

1. Monitor log files for errors
2. Check database connection status
3. Verify application health
4. Monitor system resources

### Backup

- Regularly backup domain configuration
- Maintain copies of deployment scripts
- Document any custom configurations

## Support

For additional support or to report new issues:

1. Check the VA VBMS documentation
2. Contact the development team
3. Review WebLogic documentation for M3 Mac-specific issues
