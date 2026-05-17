import 'dart:io';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/download_task.dart';
import '../services/download_service.dart';

class QueueProvider extends ChangeNotifier {
  final List<DownloadTask> _queue = [];
  final DownloadService _dlService = DownloadService();

  bool _isProcessing = false;

  List<DownloadTask> get queue => _queue;

  void addTask(DownloadTask task) {
    _queue.add(task);
    notifyListeners();
    _startQueue();
  }

  void removeTask(int id) {
    _queue.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _queue.removeWhere(
      (task) =>
          task.status == TaskStatus.success || task.status == TaskStatus.error,
    );
    notifyListeners();
  }

  Future<void> openFolder(String path) async {
    await _dlService.openFolder(path);
  }

  Future<void> _startQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_queue.any((task) => task.status == TaskStatus.waiting)) {
      final task = _queue.firstWhere((t) => t.status == TaskStatus.waiting);
      await _processSingleTask(task);
    }

    _isProcessing = false;
  }

  Future<void> _processSingleTask(DownloadTask task) async {
    task.status = TaskStatus.downloading;
    task.statusText = 'Menyiapkan Unduhan...';
    notifyListeners();
    _updateNotification(task, 0.0, 'Memulai...', '');

    // Modifikasi ekstensi agar format "tiktok_slideshow" dipaksa dibaca sebagai "mp4" oleh sistem finalisasi
    String ext = task.isAudio ? 'mp3' : task.videoFormat;
    if (task.videoFormat == 'tiktok_slideshow') ext = 'mp4';

    final cleanTitle = task.title.replaceAll(RegExp(r'[^\w\s]+'), '').trim();
    final String finalPath = '${task.saveDirectory}/$cleanTitle.$ext';

    final dir = Directory(task.saveDirectory);
    if (!await dir.exists()) await dir.create(recursive: true);

    try {
      // ========================================================
      // LOGIKA CERDAS: DETEKSI PLATFORM DARI URL!
      // ========================================================
      bool isYouTube =
          task.videoUrl.contains('youtube.com') ||
          task.videoUrl.contains('youtu.be');

      if (isYouTube) {
        // --- 1. JALUR YOUTUBE EXPLODE ---
        var yt = YoutubeExplode();
        task.statusText = 'Mendapatkan Jalur Bebas JS...';
        notifyListeners();

        var manifest = await yt.videos.streamsClient.getManifest(
          task.videoUrl,
          ytClients: [YoutubeApiClient.safari, YoutubeApiClient.androidVr],
        );

        if (task.isAudio) {
          task.statusText = 'Menghubungkan Server Audio...';
          notifyListeners();

          var audioStream = manifest.audioOnly.withHighestBitrate();
          var stream = yt.videos.streamsClient.get(audioStream);

          String tempAudio = await _dlService.downloadFromStream(
            stream,
            'temp_${task.id}.webm',
            audioStream.size.totalBytes,
            onProgress: (p, details) =>
                _updateProgress(task, p, 'Mengunduh Audio', details),
          );

          task.status = TaskStatus.processing;
          task.statusText = 'Mempersiapkan FFmpeg...';
          notifyListeners();

          final command =
              '-i "$tempAudio" -vn -ar 44100 -ac 2 -b:a ${task.audioBitrate ?? "192k"} "$finalPath" -y';
          bool success = await _dlService.executeFFmpeg(
            command,
            totalDurationMs: task.totalDurationMs,
            onProgress: (p, details) =>
                _updateProgress(task, p, 'Mengkonversi MP3', details),
          );

          await _dlService.cleanUpTempFiles([tempAudio]);
          if (!success) throw Exception('Gagal konversi FFmpeg');
        } else if (task.requiresMuxing) {
          task.statusText = 'Menyiapkan Jalur HD...';
          notifyListeners();

          VideoStreamInfo videoStream;
          try {
            videoStream = manifest.videoOnly.firstWhere(
              (s) => s.qualityLabel == task.qualityLabel,
            );
          } catch (_) {
            videoStream = manifest.videoOnly.sortByVideoQuality().last;
          }
          var audioStream = manifest.audioOnly.withHighestBitrate();

          String vExt = videoStream.container.name.toString();
          String aExt = audioStream.container.name.toString();

          task.statusText = 'Mengunduh Video HD...';
          notifyListeners();

          var vidStream = yt.videos.streamsClient.get(videoStream);
          String tempVideo = await _dlService.downloadFromStream(
            vidStream,
            'temp_vid_${task.id}.$vExt',
            videoStream.size.totalBytes,
            onProgress: (p, details) =>
                _updateProgress(task, p * 0.5, 'Mengunduh Video HD', details),
          );

          task.statusText = 'Mengunduh Audio HD...';
          notifyListeners();

          var audStream = yt.videos.streamsClient.get(audioStream);
          String tempAudio = await _dlService.downloadFromStream(
            audStream,
            'temp_aud_${task.id}.$aExt',
            audioStream.size.totalBytes,
            onProgress: (p, details) => _updateProgress(
              task,
              0.5 + (p * 0.2),
              'Mengunduh Audio HD',
              details,
            ),
          );

          task.status = TaskStatus.processing;
          notifyListeners();

          String command;
          if (task.videoFormat == 'mkv') {
            command = '-i "$tempVideo" -i "$tempAudio" -c copy "$finalPath" -y';
          } else {
            command =
                '-i "$tempVideo" -i "$tempAudio" -c:v libx264 -preset ultrafast -crf 28 -c:a aac -b:a 128k "$finalPath" -y';
          }

          bool success = await _dlService.executeFFmpeg(
            command,
            totalDurationMs: task.totalDurationMs,
            onProgress: (p, details) {
              String titleText = task.videoFormat == 'mp4'
                  ? 'Konversi ke MP4'
                  : 'Menggabungkan Video (MKV)';
              _updateProgress(task, 0.7 + (p * 0.3), titleText, details);
            },
          );

          await _dlService.cleanUpTempFiles([tempVideo, tempAudio]);
          if (!success) throw Exception('Gagal memproses Video dengan FFmpeg');
        } else {
          task.statusText = 'Menghubungkan Server Video...';
          notifyListeners();

          MuxedStreamInfo muxedStream;
          try {
            muxedStream = manifest.muxed.firstWhere(
              (s) => s.qualityLabel == task.qualityLabel,
            );
          } catch (_) {
            muxedStream = manifest.muxed.sortByVideoQuality().last;
          }

          var stream = yt.videos.streamsClient.get(muxedStream);
          String tempFile = await _dlService.downloadFromStream(
            stream,
            'temp_muxed_${task.id}.mp4',
            muxedStream.size.totalBytes,
            onProgress: (p, details) =>
                _updateProgress(task, p, 'Mengunduh Video', details),
          );

          File(tempFile).copySync(finalPath);
          await _dlService.cleanUpTempFiles([tempFile]);
        }
        yt.close();
      } else {
        // --- 2. JALUR TIKTOK / FB / IG / DIRECT LINK ---

        // ========================================================
        // FITUR SAKTI: JADIKAN GAMBAR TIKTOK MENJADI VIDEO MP4
        // ========================================================
        if (task.videoFormat == 'tiktok_slideshow') {
          task.statusText = 'Mengunduh Komponen...';
          notifyListeners();

          // 1. Download Gambar Cover
          String tempImg = await _dlService.downloadFromUrl(
            task.thumbnail,
            'temp_img_${task.id}.jpg',
            onProgress: (p, details) =>
                _updateProgress(task, p * 0.3, 'Mengunduh Gambar', details),
          );

          // 2. Download Audio
          String tempAud = await _dlService.downloadFromUrl(
            task.videoUrl,
            'temp_aud_${task.id}.mp3',
            onProgress: (p, details) => _updateProgress(
              task,
              0.3 + (p * 0.3),
              'Mengunduh Audio',
              details,
            ),
          );

          task.status = TaskStatus.processing;
          task.statusText = 'Muxing Gambar ke MP4...';
          notifyListeners();

          // ========================================================
          // PERBAIKAN COMMAND FFMPEG: ANTI TERSEDAK + ANTI GANJIL
          // ========================================================
          final String finalSlidePath = '${task.saveDirectory}/$cleanTitle.mp4';

          // Tambahan: -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2"
          // Fungsi ini memaksa lebar (iw) dan tinggi (ih) menjadi bilangan genap
          // dengan cara memotong sisa desimalnya, jadi FFmpeg (libx264) nggak bakal ngambek lagi!

          final command =
              '-loop 1 -framerate 2 -i "$tempImg" -i "$tempAud" -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -tune stillimage -c:a aac -b:a 128k -pix_fmt yuv420p -shortest "$finalSlidePath" -y';

          bool success = await _dlService.executeFFmpeg(
            command,
            totalDurationMs: 30000,
            onProgress: (p, details) => _updateProgress(
              task,
              0.6 + (p * 0.4),
              'Muxing ke MP4',
              'Tunggu sebentar...',
            ),
          );

          await _dlService.cleanUpTempFiles([tempImg, tempAud]);
          if (!success) throw Exception('Gagal membuat Video MP4 dari gambar.');

          await _dlService.scanFile(finalSlidePath);
        }
        // ========================================================
        // JIKA BUKAN SLIDESHOW (DOWNLOAD VIDEO BIASA/MP3/JPG)
        // ========================================================
        else {
          task.statusText = 'Menghubungkan ke Server...';
          notifyListeners();

          // Perbaiki penamaan ekstensi kalau formatnya jpg
          final String extFix = task.videoFormat == 'jpg' ? 'jpg' : ext;
          final String finalNormalPath =
              '${task.saveDirectory}/$cleanTitle.$extFix';

          String tempFile = await _dlService.downloadFromUrl(
            task.videoUrl,
            'temp_direct_${task.id}.$extFix',
            onProgress: (p, details) =>
                _updateProgress(task, p, 'Mengunduh File', details),
          );

          File(tempFile).copySync(finalNormalPath);
          await _dlService.cleanUpTempFiles([tempFile]);

          await _dlService.scanFile(finalNormalPath);
        }
      }

      // --- FINALISASI SUKSES (UNIVERSAL) ---
      task.status = TaskStatus.success;
      task.progress = 1.0;
      task.statusText = 'Selesai diunduh!';
      await _dlService.scanFile(finalPath);
      _updateNotification(
        task,
        100.0,
        'Berhasil!',
        'Disimpan di:\n${task.saveDirectory}',
      );
      notifyListeners();
    } catch (e) {
      task.status = TaskStatus.error;
      task.statusText = 'Gagal: $e';
      _updateNotification(
        task,
        0.0,
        'Gagal Mengunduh!',
        e.toString(),
        isError: true,
      );
      notifyListeners();
    }
  }

  void _updateProgress(
    DownloadTask task,
    double progress,
    String title,
    String details,
  ) {
    task.progress = progress;
    task.statusText = '$title (${(progress * 100).toInt()}%)\n$details';
    notifyListeners();
    _updateNotification(
      task,
      (progress * 100),
      '$title (${(progress * 100).toInt()}%)',
      details,
    );
  }

  void _updateNotification(
    DownloadTask task,
    double percent,
    String title,
    String body, {
    bool isError = false,
  }) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: task.id,
        channelKey: 'download_channel',
        title: title,
        body: '${task.title}\n$body',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: percent,
        color: isError ? Colors.red : Colors.blue,
        locked: percent < 100 && !isError,
      ),
    );
  }
}
