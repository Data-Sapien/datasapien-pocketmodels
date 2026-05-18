# Flutter / embedding (https://docs.flutter.dev/deployment/android#enabling-proguard-r8)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Native SDK / JNI surfaces (tighten if vendor ships consumer rules)
-keep class com.datasapien.** { *; }

# Crashlytics / readable stack traces
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Gson / optional reflection (common in Firebase deps)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.**
-dontwarn okhttp3.**
-dontwarn okio.**

# Play Core: optional refs from Flutter deferred-components embedding (not bundled)
-dontwarn com.google.android.play.core.**
