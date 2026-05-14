package com.radevanka.radwnldr

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.radevanka.radwnldr/native_bridge"
  private var wakeLock: PowerManager.WakeLock? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call,
            result ->
      when (call.method) {
        "scanFile" -> {
          val path = call.argument<String>("path")
          MediaScannerConnection.scanFile(this, arrayOf(path), null) { _, _ -> }
          result.success(null)
        }
        "openFolder" -> {
          // MENGAMBIL PATH DARI SETTING FLUTTER
          val path = call.argument<String>("path") ?: ""

          try {
            // Pastikan direktori ada
            val dir = java.io.File(path)
            if (!dir.exists()) {
              dir.mkdirs()
            }

            // Bypass StrictMode untuk mengizinkan file:// uri (menghindari FileUriExposedException)
            val builder = android.os.StrictMode.VmPolicy.Builder()
            android.os.StrictMode.setVmPolicy(builder.build())

            // Coba buka folder secara spesifik
            val intent = android.content.Intent(android.content.Intent.ACTION_VIEW)
            val uri = Uri.parse("file://$path")
            intent.setDataAndType(uri, "resource/folder")
            intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK

            if (intent.resolveActivity(packageManager) != null) {
              startActivity(intent)
            } else {
              intent.setDataAndType(uri, "*/*")
              startActivity(intent)
            }
          } catch (e: Exception) {
            // Fallback: Jika File Manager HP tidak support direct-path, buka folder Downloads
            // bawaan
            try {
              val fallbackIntent =
                      android.content.Intent(android.app.DownloadManager.ACTION_VIEW_DOWNLOADS)
              fallbackIntent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
              startActivity(fallbackIntent)
            } catch (ex: Exception) {}
          }
          result.success(null)
        }
        "acquireWakeLock" -> {
          if (wakeLock == null) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock =
                    powerManager.newWakeLock(
                            PowerManager.PARTIAL_WAKE_LOCK,
                            "RaDwnldr::FFmpegWakeLock"
                    )
          }
          if (wakeLock?.isHeld == false) {
            wakeLock?.acquire()
          }
          result.success(null)
        }
        "releaseWakeLock" -> {
          if (wakeLock?.isHeld == true) {
            wakeLock?.release()
          }
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
  }
}
