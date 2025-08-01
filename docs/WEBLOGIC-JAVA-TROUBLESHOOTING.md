# WebLogic Java Version Troubleshooting on macOS

## Problem

WebLogic 12.2.1.4.0 was failing to start, showing errors like:

```
Starting WLS with line:
/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/bin/java ...
<BEA-000386> <Server subsystem failed. Reason: ... ExceptionInInitializerError ... IllegalStateException ... IIOPClientService ...>
```

```sh
JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
```

**Hardcode `JAVA_HOME` to the correct Java 8 path in `startWebLogic.sh`:**

Replace:

```sh
JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
```

with:

```sh
JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home
```
