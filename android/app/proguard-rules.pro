# --- Flutter Core ---
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# --- Dart/Flutter Reflection (used internally) ---
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# --- Firebase Core ---
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# --- Firebase Modules ---
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firebase.storage.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.**

# --- Razorpay ---
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }
-dontwarn com.razorpay.**

# --- Google Mobile Ads ---
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# --- Cloudinary SDK ---
-keep class com.cloudinary.** { *; }
-dontwarn com.cloudinary.**

# --- Kotlin and Coroutines ---
-keep class kotlin.Metadata
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**

# --- Annotations and Lifecycle (used by Firebase & Jetpack) ---
-keepattributes *Annotation*
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# --- Image Picker (if using native image picker or file provider) ---
-keep class com.zhihu.matisse.** { *; }
-dontwarn com.zhihu.matisse.**

# --- Google Play Core / SplitCompat ---
-keep class com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.splitcompat.**
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }

# --- Flutter Play Store Split ---
-keep class io.flutter.app.FlutterPlayStoreSplitApplication { *; }
-dontwarn io.flutter.app.FlutterPlayStoreSplitApplication

# --- Optional: Keep Flutter debug info for logs ---
# -keepattributes SourceFile,LineNumberTable

# --- App-specific Models (optional, adjust based on your package) ---
-keep class com.digitalbhikari.app.digital_bhikari.** { *; }

# Ignore missing proguard annotations (used by Razorpay internally)
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Safe fallback if referenced
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }


# --- Razorpay SDK fix for missing proguard.annotation classes ---


# Suppress warnings for shared_preferences plugin
-dontwarn io.flutter.plugins.sharedpreferences.LegacySharedPreferencesPlugin
-dontwarn io.flutter.plugins.sharedpreferences.SharedPreferencesListEncoder


