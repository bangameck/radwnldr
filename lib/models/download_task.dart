enum TaskStatus { waiting, downloading, processing, success, error }

class DownloadTask {
  final int id;
  final String videoUrl;
  final String title;
  final String thumbnail;
  final String qualityLabel;
  final bool isAudio;
  final bool requiresMuxing;
  final String? audioBitrate;
  final int totalDurationMs;
  final String saveDirectory;
  final String videoFormat; // <--- TAMBAHAN: Menyimpan format MKV atau MP4

  TaskStatus status;
  double progress;
  String statusText;

  DownloadTask({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.thumbnail,
    required this.qualityLabel,
    required this.isAudio,
    required this.requiresMuxing,
    required this.totalDurationMs,
    required this.saveDirectory,
    this.videoFormat = 'mp4', // Default mp4
    this.audioBitrate,
    this.status = TaskStatus.waiting,
    this.progress = 0.0,
    this.statusText = 'Menunggu antrian...',
  });
}
