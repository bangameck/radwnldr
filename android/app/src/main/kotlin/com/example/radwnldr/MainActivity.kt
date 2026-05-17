package com.radevanka.radwnldr

import android.content.Context
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.PowerManager
import android.os.StrictMode
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

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
            val dir = File(path)
            if (!dir.exists()) {
              dir.mkdirs()
            }

            // ==========================================
            // PERBAIKAN LOGIKA MEMBUKA FOLDER NATIVE
            // ==========================================
            val intent = Intent(Intent.ACTION_VIEW)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP

            // Coba buka menggunakan standar SAF Android 11+
            if (path.startsWith("/storage/emulated/0/")) {
              val relativePath = path.replace("/storage/emulated/0/", "")
              // Memformat path agar diterima oleh Content Provider Google Files
              val uri =
                      Uri.parse(
                              "content://com.android.externalstorage.documents/document/primary%3A${Uri.encode(relativePath)}"
                      )

              intent.setDataAndType(uri, "vnd.android.document/directory")
              intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

              try {
                startActivity(intent)
                result.success(null)
                return@setMethodCallHandler
              } catch (e: Exception) {
                // Lanjut ke fallback jika aplikasi Files bawaan menolak format ini
              }
            }

            // Fallback 1: Cara Lama (File Uri)
            val builder = StrictMode.VmPolicy.Builder()
            StrictMode.setVmPolicy(builder.build())
            val fileUri = Uri.fromFile(dir)
            intent.setDataAndType(fileUri, "resource/folder")

            try {
              startActivity(intent)
            } catch (e: Exception) {
              // Fallback 2: Buka File Manager default secara umum (tanpa nyasar ke Downloads)
              val intentGeneral = Intent(Intent.ACTION_GET_CONTENT)
              val uriGeneral = Uri.parse("file://$path")
              intentGeneral.setDataAndType(uriGeneral, "*/*")
              intentGeneral.flags = Intent.FLAG_ACTIVITY_NEW_TASK

              try {
                startActivity(intentGeneral)
              } catch (ex: Exception) {
                // Fallback TERAKHIR BANGET: Barulah buka Downloads (Biar nggak force close)
                val fallbackIntent = Intent(android.app.DownloadManager.ACTION_VIEW_DOWNLOADS)
                fallbackIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(fallbackIntent)
              }
            }
          } catch (e: Exception) {
            // Error fatal, tetap buka folder Downloads
            val fallbackIntent = Intent(android.app.DownloadManager.ACTION_VIEW_DOWNLOADS)
            fallbackIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(fallbackIntent)
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
