import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http; // <--- TAMBAHAN UNTUK TIKTOK/IG

class DownloadService {
  static const _channel = MethodChannel('com.radevanka.radwnldr/native_bridge');

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      bool storageGranted = false;
      if (await Permission.manageExternalStorage.isGranted ||
          await Permission.storage.isGranted) {
        storageGranted = true;
      } else {
        var statusManage = await Permission.manageExternalStorage.request();
        if (statusManage.isGranted) {
          storageGranted = true;
        } else {
          var statusStorage = await Permission.storage.request();
          storageGranted = statusStorage.isGranted;
        }
      }

      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
      return storageGranted;
    }
    return true;
  }

  Future<void> scanFile(String path) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('scanFile', {'path': path});
      } catch (e) {
        debugPrint("[CCTV] Scanner Error: $e");
      }
    }
  }

  Future<void> openFolder(String path) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('openFolder', {'path': path});
      } catch (e) {
        debugPrint("[CCTV] Open Folder Error: $e");
      }
    }
  }

  Future<void> _acquireWakeLock() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('acquireWakeLock');
      } catch (_) {}
    }
  }

  Future<void> _releaseWakeLock() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('releaseWakeLock');
      } catch (_) {}
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds <= 0) return "0s";
    int totalSeconds = (milliseconds / 1000).floor();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}j ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // --- DOWNLOAD DARI STREAM YOUTUBE (YOUTUBE EXPLODE) ---
  Future<String> downloadFromStream(
    Stream<List<int>> stream,
    String fileName,
    int totalBytes, {
    Function(double, String)? onProgress,
  }) async {
    await _acquireWakeLock();

    final tempDir = await getTemporaryDirectory();
    final savePath = '${tempDir.path}/$fileName';
    final file = File(savePath);
    final output = file.openWrite();

    int downloadedBytes = 0;
    int lastUpdateBytes = 0;
    DateTime lastUpdateTime = DateTime.now();
    final completer = Completer<String>();

    stream.listen(
      (chunk) {
        output.add(chunk);
        downloadedBytes += chunk.length;
        DateTime now = DateTime.now();
        Duration diff = now.difference(lastUpdateTime);

        if (diff.inMilliseconds >= 500 || downloadedBytes == totalBytes) {
          double speedBps =
              (downloadedBytes - lastUpdateBytes) /
              (diff.inMilliseconds / 1000.0);
          String speedText = '${_formatBytes(speedBps.toInt())}/s';
          String sizeText =
              '${_formatBytes(downloadedBytes)} / ${_formatBytes(totalBytes)}';
          double percent = totalBytes > 0
              ? (downloadedBytes / totalBytes)
              : 0.0;

          if (onProgress != null) onProgress(percent, "$sizeText • $speedText");

          lastUpdateTime = now;
          lastUpdateBytes = downloadedBytes;
        }
      },
      onDone: () async {
        await output.close();
        await _releaseWakeLock();
        completer.complete(savePath);
      },
      onError: (e) async {
        await output.close();
        await _releaseWakeLock();
        completer.completeError(e);
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  // --- DOWNLOAD DARI URL LANGSUNG (TIKTOK / IG / FB) ---
  Future<String> downloadFromUrl(
    String url,
    String fileName, {
    Function(double, String)? onProgress,
  }) async {
    await _acquireWakeLock();

    final tempDir = await getTemporaryDirectory();
    final savePath = '${tempDir.path}/$fileName';
    final file = File(savePath);
    final output = file.openWrite();

    int downloadedBytes = 0;
    int lastUpdateBytes = 0;
    DateTime lastUpdateTime = DateTime.now();
    final completer = Completer<String>();

    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      final totalBytes = response.contentLength ?? 0;

      response.stream.listen(
        (chunk) {
          output.add(chunk);
          downloadedBytes += chunk.length;
          DateTime now = DateTime.now();
          Duration diff = now.difference(lastUpdateTime);

          if (diff.inMilliseconds >= 500 || downloadedBytes == totalBytes) {
            double speedBps =
                (downloadedBytes - lastUpdateBytes) /
                (diff.inMilliseconds / 1000.0);
            String speedText = '${_formatBytes(speedBps.toInt())}/s';
            String sizeText =
                '${_formatBytes(downloadedBytes)} / ${_formatBytes(totalBytes)}';
            double percent = totalBytes > 0
                ? (downloadedBytes / totalBytes)
                : 0.0;

            if (onProgress != null) {
              onProgress(percent, "$sizeText • $speedText");
            }

            lastUpdateTime = now;
            lastUpdateBytes = downloadedBytes;
          }
        },
        onDone: () async {
          await output.close();
          await _releaseWakeLock();
          completer.complete(savePath);
        },
        onError: (e) async {
          await output.close();
          await _releaseWakeLock();
          completer.completeError(e);
        },
        cancelOnError: true,
      );
    } catch (e) {
      await output.close();
      await _releaseWakeLock();
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<bool> executeFFmpeg(
    String command, {
    Function(double, String)? onProgress,
    required int totalDurationMs,
  }) async {
    await _acquireWakeLock();
    final completer = Completer<bool>();
    DateTime lastUpdateTime = DateTime.now();

    await FFmpegKit.executeAsync(
      command,
      (session) async {
        final returnCode = await session.getReturnCode();
        await _releaseWakeLock();

        // ==========================================
        // CCTV FFMPEG: DETEKSI ERROR LENGKAP
        // ==========================================
        if (!ReturnCode.isSuccess(returnCode)) {
          final failStackTrace = await session.getFailStackTrace();
          final output = await session.getOutput();
          debugPrint("\n=== [CCTV FFMPEG ERROR] ===");
          debugPrint("Return Code: $returnCode");
          debugPrint("Output Log: $output");
          debugPrint("Stack Trace: $failStackTrace");
          debugPrint("===========================\n");
        }
        // ==========================================

        completer.complete(ReturnCode.isSuccess(returnCode));
      },
      null,
      (statistics) {
        DateTime now = DateTime.now();
        Duration diff = now.difference(lastUpdateTime);

        if (diff.inMilliseconds >= 500 &&
            onProgress != null &&
            totalDurationMs > 0) {
          int timeInMs = statistics.getTime();
          double percent = (timeInMs / totalDurationMs);
          double finalPercent = min(percent, 1.0);
          String timeStr =
              "${_formatDuration(timeInMs)} / ${_formatDuration(totalDurationMs)}";
          onProgress(finalPercent, timeStr);
          lastUpdateTime = now;
        }
      },
    );

    return completer.future;
  }

  Future<void> cleanUpTempFiles(List<String> paths) async {
    for (var path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}
