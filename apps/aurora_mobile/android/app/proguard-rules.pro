## Rules for NewPipeExtractor (Rhino JS engine must survive R8).
-keep class org.mozilla.javascript.** { *; }
-keep class org.mozilla.classfile.ClassFileWriter
-dontwarn org.mozilla.javascript.tools.**
# Rhino references desktop-only JDK APIs absent on Android.
-dontwarn java.beans.**
-dontwarn javax.script.**
-dontwarn jdk.dynalink.**
