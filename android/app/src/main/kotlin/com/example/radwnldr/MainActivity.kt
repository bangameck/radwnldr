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
          val path = call.argument<String>("path") ?: ""

          try {
            val dir = java.io.File(path)
            if (!dir.exists()) {
              dir.mkdirs()
            }

            val intent = android.content.Intent(android.content.Intent.ACTION_VIEW)
            intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK

            if (path.startsWith("/storage/emulated/0/")) {
              val relativePath = path.removePrefix("/storage/emulated/0/")
              val uri = Uri.parse("content://com.android.externalstorage.documents/document/primary:$relativePath")
              intent.setDataAndType(uri, "vnd.android.document/directory")
            } else {
              val builder = android.os.StrictMode.VmPolicy.Builder()
              android.os.StrictMode.setVmPolicy(builder.build())
              val uri = Uri.parse("file://$path")
              intent.setDataAndType(uri, "*/*")
            }
            
            startActivity(intent)
          } catch (e: Exception) {
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
