# Razorpay SDK keep rules
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }

# Fix for missing annotations
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers


# Required for Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**