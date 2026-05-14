# 1. Lindungi Core Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 2. Lindungi FFmpeg Kit
-keep class com.arthenica.** { *; }

# 3. Lindungi Awesome Notifications
-keep class me.carda.awesome_notifications.** { *; }
-keep class me.carda.awesome_notifications.core.** { *; }

# 4. Lindungi Native Bridge Kita (MainActivity Kotlin)
-keep class com.radevanka.radwnldr.MainActivity { *; }

# ============================================================
# 5. OBAT ERROR R8 (MENGABAIKAN MISSING CLASSES)
# ============================================================
# Abaikan warning dari Play Core (Penyebab utama error R8 di Flutter Engine baru)
-dontwarn com.google.android.play.core.**

# Abaikan warning dari library eksternal lainnya
-dontwarn com.arthenica.**
-dontwarn me.carda.awesome_notifications.**

# Jika R8 masih bawel soal library lain yang tidak lengkap referensinya, tambahkan ini:
-ignorewarnings