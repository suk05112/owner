# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Kotlin serialization / JSON models (json_annotation, retrofit)
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keep class com.gifnut.owner.** { *; }

# OkHttp / Retrofit (used internally by Dio on Android)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Prevent stripping of Crashlytics stack trace info
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Kakao SDK
-keep class com.kakao.** { *; }
-dontwarn com.kakao.**
