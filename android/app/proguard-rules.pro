# ─────────────────────────────────────────────────────────────────────
# Zunga R8 / ProGuard rules
# Two jobs: (1) let bundleRelease link without the Play Core deferred-
# component classes we don't use, (2) keep everything the release build
# touches via reflection/JNI so the installed APK doesn't crash at start.
# ─────────────────────────────────────────────────────────────────────

# --- Flutter engine & embedding ---------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# --- Play Core: Flutter's embedding references these deferred-component
#     / split-install classes, but Zunga bundles no dynamic features, so
#     they are absent. Tell R8 not to fail on the missing references.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# --- Zunga native layer (declared in the manifest / used over channels).
#     The accessibility service and MainActivity must not be renamed.
-keep class rw.zunga.** { *; }
-keepclassmembers class rw.zunga.** { *; }

# --- flutter_secure_storage -> AndroidX Security Crypto -> Tink.
#     This is what main() hits first (reading the registered number).
#     Tink resolves key types by reflection, so it must survive R8 or the
#     app crashes on launch.
-keep class androidx.security.crypto.** { *; }
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**
-keepclassmembers class * extends com.google.crypto.tink.shaded.protobuf.GeneratedMessageLite {
    <fields>;
}

# --- Keep native methods and enum values (JNI + reflection). -----------
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# --- Parcelables / serialization used across platform channels. --------
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# --- Silence the harmless notes for missing optional deps. -------------
-dontwarn javax.annotation.**
