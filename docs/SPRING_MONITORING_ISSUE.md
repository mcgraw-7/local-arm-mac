# Disabling Spring Monitoring in WebLogic for VBMS

## Problem

When deploying the VBMS application on WebLogic 12.1.3, the following error was encountered:

```
weblogic.application.ModuleException: java.lang.NullPointerException
    at weblogic.application.internal.ExtensibleModuleWrapper.prepare(ExtensibleModuleWrapper.java:114)
    ...
Caused By: java.lang.NullPointerException
    at java.util.concurrent.ConcurrentHashMap.putVal(ConcurrentHashMap.java:1011)
    at java.util.concurrent.ConcurrentHashMap.put(ConcurrentHashMap.java:1006)
    at weblogic.spring.monitoring.instrumentation.SpringClassPreprocessor.createSpringInstrumentorEngineIfNecessary(SpringClassPreprocessor.java:67)
    at weblogic.spring.monitoring.instrumentation.SpringClassPreprocessor.<init>(SpringClassPreprocessor.java:26)
    at weblogic.spring.monitoring.instrumentation.SpringInstrumentationUtils.addSpringInstrumentor(SpringInstrumentationUtils.java:87)
    ...
```

This is caused by WebLogic's Spring monitoring subsystem attempting to instrument Spring beans, which can fail due to classpath or version conflicts.

## Solution

1. **Disable Spring Monitoring in All WARs**
   - Add the following to each `WEB-INF/weblogic.xml` in every WAR module:
     - For files using the `wls:` namespace:
       ```xml
       <wls:container-descriptor>
         <wls:spring-monitoring-enabled>false</wls:spring-monitoring-enabled>
       </wls:container-descriptor>
       ```
     - For files without the `wls:` namespace:
       ```xml
       <container-descriptor>
         <spring-monitoring-enabled>false</spring-monitoring-enabled>
       </container-descriptor>
       ```
2. **Clean WebLogic Temp/Cache/Stage Directories**
   - Stop WebLogic.
   - Delete all files in `servers/AdminServer/tmp`, `servers/AdminServer/cache`, and `servers/AdminServer/stage`.
   - Optionally, clear `servers/AdminServer/data/ldap` and `servers/AdminServer/data/store`.

3. **Rebuild and Redeploy**
   - Run `mvn clean install` to rebuild all modules.
   - Redeploy the EAR/WARs to WebLogic.

## Additional Notes
- Ensure there are no Spring JARs in the WebLogic global `lib` directories.
- Verify that every deployed WAR contains the updated `weblogic.xml`.
- If the error persists, check the full server log for the specific module causing the issue.

---

**Summary:** Disabling Spring monitoring in all WARs and cleaning up WebLogic's temp/cache directories resolves the `SpringClassPreprocessor` NullPointerException during deployment.
