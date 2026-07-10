# jing validator for DHQ
## written 2026-02-02 by Syd

The version of `jing` that we use is the one patched by the folks at
SyncRO Soft called
[oxygen-patched-jing](https://mvnrepository.com/artifact/com.oxygenxml/oxygen-patched-jing/28.0.0.2).
Because the JAR file supplied includes the release number in the
filename, we have a symlink that points to the actual JAR file so that
references do not have to be updated for every patch release. (I do
not know if this will work in Windows, though.)
