# WebLogic JDK Compatibility

## Problem Description

WebLogic using wrong version of java 

### Error Symptoms

```
<Critical> <WebLogicServer> <BEA-000386> <Server subsystem failed. Reason: A MultiException has 2 exceptions. They are:
1. java.lang.ExceptionInInitializerError
2. java.lang.IllegalStateException: Unable to perform operation: post construct on weblogic.iiop.IIOPClientService

Caused By: java.lang.NullPointerException: Cannot invoke "java.lang.reflect.Method.invoke(Object, Object[])" because "weblogic.utils.io.ObjectStreamClass.GET_FIELD_METHOD" is null
```
### Verification

You can verify this issue by running:

```bash
/usr/libexec/java_home -v 1.8
# Returns: /Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home (incorrect)

/usr/libexec/java_home -v 1.8.0_202
# Returns: /Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home (correct)
```

## Solution

### The Fix

**Before (problematic):**

```bash
JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
```

**After (fixed):**

```bash
JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
```

### Implementation

1. **Locate the startup script:**

   ```bash
   cd /Users/michaelmcgraw/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV
   ```

2. **Edit the startup script:**

   ```bash
   vim bin/startWebLogic.sh
   ```

3. **Find line 202 and replace:**

   ```bash
   # Find this line:
   JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

   # Replace with:
   JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
   ```

### Verification Steps

1. **Check the fix:**

   ```bash
   grep -n "JAVA_HOME" bin/startWebLogic.sh
   # Should show: 202:JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home"
   ```

2. **Start WebLogic:**

   ```bash
   source /Users/michaelmcgraw/.wljava_env
   ./bin/startWebLogic.sh
   ```

3. **Verify correct Java version:**

   ```bash
   ps aux | grep java | grep weblogic
   # Should show: /Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home/bin/java
   ```

4. **Check logs for success:**
   ```bash
   tail -20 servers/AdminServer/logs/AdminServer.log
   # Should show normal startup messages, no JDK 17 errors
   ```


## Related Files

- **Startup Script:** `/Users/michaelmcgraw/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV/bin/startWebLogic.sh`
- **Environment File:** `/Users/michaelmcgraw/.wljava_env`
- **Log File:** `/Users/michaelmcgraw/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV/servers/AdminServer/logs/AdminServer.log`

## Troubleshooting

1. Check if there are multiple startup scripts
2. Verify no environment variables are overriding JAVA_HOME
3. Ensure the correct Java version is installed
4. Check for cached configurations

### Common commands:

```bash
# Check installed Java versions
/usr/libexec/java_home -V

# Check current Java version
java -version

# Check JAVA_HOME
echo $JAVA_HOME

# Check WebLogic process
ps aux | grep java | grep weblogic
```

---
