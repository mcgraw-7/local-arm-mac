# WebLogic Java Version Troubleshooting on macOS

## Problem

WebLogic 12.2.1.4.0 was failing to start, showing errors like:

```
Starting WLS with line:
/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/bin/java ...
<BEA-000386> <Server subsystem failed. Reason: ... ExceptionInInitializerError ... IllegalStateException ... IIOPClientService ...>
```

Even though the environment and scripts were set to use Java 8, WebLogic was launching with Java 17, causing critical startup failures.

## Root Cause

On macOS, the script used:

```sh
JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
```

But `/usr/libexec/java_home -v 1.8` can return Java 17 if Java 8 is not properly registered with macOS, or if the Java 8 install is missing metadata. This caused `JAVA_HOME` to be set to Java 17, even when Java 8 was installed and available.

## Solution

**Hardcode `JAVA_HOME` to the correct Java 8 path in `startWebLogic.sh`:**

Replace:
```sh
JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
```
with:
```sh
JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home
```

This ensures WebLogic always uses Java 8, regardless of macOS's Java registration.

## Debugging Steps Used

1. Added debug output to print `JAVA_HOME`, `which java`, and `java -version` before and after setting `JAVA_HOME`.
2. Observed that `/usr/libexec/java_home -v 1.8` returned Java 17, not Java 8.
3. Hardcoded the correct Java 8 path, which resolved the issue.

## Key Takeaways

- Always verify what `/usr/libexec/java_home -v 1.8` returns on your system.
- For critical scripts, hardcode `JAVA_HOME` if you need a specific JDK version.
- WebLogic 12.2.1.4.0 is not compatible with Java 17; use Java 8.

---

**Last updated:** June 26, 2025
