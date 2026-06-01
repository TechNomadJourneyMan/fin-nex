# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }
-dontwarn io.flutter.embedding.**

# Drift / sqlite
-keep class com.simolus.** { *; }
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# Keep generated freezed/json classes
-keep class **$$* { *; }
-keep class * implements java.io.Serializable { *; }

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Kotlin
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
