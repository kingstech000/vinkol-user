# android/app/proguard-rules.pro
# Add any project-specific ProGuard rules here.
# For more information about ProGuard, see
# http://developer.android.com/intl/en/tools/help/proguard.html

# Flutter specific rules (usually handled by Flutter's default ProGuard setup)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Firebase and Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn javax.annotation.**

# Google Play Core - Updated rules for missing classes
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Specific Play Core classes that were missing
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Flutter Play Store integration
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Additional safety rules for R8/ProGuard
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# For any specific packages you might be using that require rules
# -keep class com.example.somepackage.** { *; }