import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:shimmer/shimmer.dart';

import '../services/youtube_service.dart';
import '../services/download_service.dart';
import '../widgets/alert_premium.dart';
import '../models/download_task.dart';
import '../providers/queue_provider.dart';
import '../providers/app_provider.dart';

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({super.key});

  @override
  State<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen>
    with WidgetsBindingObserver {
  final TextEditingController _urlController = TextEditingController();
  final YoutubeService _ytService = YoutubeService();
  final DownloadService _dlService = DownloadService();

  bool _isLoading = false;
  Video? _videoMetadata;
  Map<String, List<dynamic>>? _streams;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkClipboardForLink();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _urlController.dispose();
    _ytService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForLink();
    }
  }

  Future<void> _checkClipboardForLink() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      String text = data.text!;
      if ((text.contains('youtube.com') || text.contains('youtu.be')) &&
          _urlController.text != text) {
        setState(() {
          _urlController.text = text;
        });
        _analyzeVideo();
      }
    }
  }

  Future<void> _analyzeVideo() async {
    if (_urlController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _videoMetadata = null;
      _streams = null;
    });

    try {
      FocusScope.of(context).unfocus();
      var video = await _ytService.getVideoMetadata(_urlController.text);
      var streams = await _ytService.getStreamManifest(video.id);

      if (!mounted) return;

      setState(() {
        _videoMetadata = video;
        _streams = streams;
      });
    } catch (e) {
      if (!mounted) return;
      AlertPremium.showError(context, 'Gagal mengambil data: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatVideoDuration(Duration? duration) {
    if (duration == null) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  // --- DIALOG PEMILIHAN FORMAT (PREMIUM) ---
  void _showFormatDialog(dynamic streamInfo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Pilih Format Video',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Video resolusi HD membutuhkan proses penggabungan. Pilih format akhir:',
            style: TextStyle(color: Colors.grey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              children: [
                _buildFormatButton(
                  title: 'MKV (Original)',
                  subtitle: 'Proses Super Cepat (Copy Codec)',
                  color: Colors.blueAccent,
                  icon: Icons.flash_on_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    _processDownload(
                      streamInfo: streamInfo,
                      isAudio: false,
                      requiresMuxing: true,
                      format: 'mkv',
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildFormatButton(
                  title: 'MP4 (Layar Mobil)',
                  subtitle: 'Re-Encode (Butuh waktu ekstra)',
                  color: Colors.orange.shade600,
                  icon: Icons.directions_car_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    _processDownload(
                      streamInfo: streamInfo,
                      isAudio: false,
                      requiresMuxing: true,
                      format: 'mp4',
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormatButton({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA UTAMA DOWNLOAD ---
  Future<void> _processDownload({
    required dynamic streamInfo,
    required bool isAudio,
    required bool requiresMuxing,
    String audioBitrate = '192k',
    String format = 'mp4',
  }) async {
    Navigator.pop(context);

    bool hasPermission = await _dlService.requestStoragePermission();
    if (!mounted) return;

    if (!hasPermission) {
      AlertPremium.showError(context, 'Izin penyimpanan ditolak!');
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final String baseDir = isAudio
        ? appProvider.audioPath
        : appProvider.videoPath;

    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      videoUrl: _urlController.text,
      title: _videoMetadata!.title,
      thumbnail: _videoMetadata!.thumbnails.highResUrl,
      qualityLabel: streamInfo.qualityLabel,
      isAudio: isAudio,
      requiresMuxing: requiresMuxing,
      totalDurationMs: _videoMetadata!.duration?.inMilliseconds ?? 0,
      audioBitrate: audioBitrate,
      saveDirectory: baseDir,
      videoFormat: format,
    );

    Provider.of<QueueProvider>(context, listen: false).addTask(task);
    AlertPremium.showSuccess(context, 'Masuk Antrian:\n${task.title}');
  }

  // --- BOTTOM SHEET PREMIUM (FULL CODE) ---
  void _showResolutionBottomSheet() {
    if (_streams == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.65,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              DefaultTabController(
                length: 2,
                child: Expanded(
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Tab(
                            icon: Icon(Icons.video_library_rounded),
                            text: 'Video',
                          ),
                          Tab(
                            icon: Icon(Icons.library_music_rounded),
                            text: 'Audio',
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                const Text(
                                  'Kualitas Tinggi (Pilih Format Nanti)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                ..._streams!['video_only']!.map(
                                  (stream) => ListTile(
                                    leading: const Icon(
                                      Icons.hd,
                                      color: Colors.blueAccent,
                                    ),
                                    title: Text(
                                      'Resolusi: ${stream.qualityLabel}',
                                    ),
                                    subtitle: Text(
                                      'Ukuran Dasar: ${stream.size.totalMegaBytes.toStringAsFixed(1)} MB',
                                    ),
                                    trailing: const Icon(
                                      Icons.download_rounded,
                                    ),
                                    onTap: () => _showFormatDialog(stream),
                                  ),
                                ),
                                const Divider(),
                                const Text(
                                  'Standar (Langsung MP4)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                ..._streams!['muxed']!.map(
                                  (stream) => ListTile(
                                    leading: const Icon(
                                      Icons.sd,
                                      color: Colors.orange,
                                    ),
                                    title: Text(
                                      'Resolusi: ${stream.qualityLabel}',
                                    ),
                                    subtitle: Text(
                                      'Ukuran: ${stream.size.totalMegaBytes.toStringAsFixed(1)} MB',
                                    ),
                                    trailing: const Icon(
                                      Icons.download_rounded,
                                    ),
                                    onTap: () => _processDownload(
                                      streamInfo: stream,
                                      isAudio: false,
                                      requiresMuxing: false,
                                      format: 'mp4',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                if (_streams!['audio_only']!.isNotEmpty) ...[
                                  ListTile(
                                    leading: const Icon(
                                      Icons.audiotrack,
                                      color: Colors.green,
                                    ),
                                    title: const Text(
                                      'Kualitas Tinggi (320kbps)',
                                    ),
                                    trailing: const Icon(
                                      Icons.download_rounded,
                                    ),
                                    onTap: () => _processDownload(
                                      streamInfo: _streams!['audio_only']!.last,
                                      isAudio: true,
                                      requiresMuxing: false,
                                      audioBitrate: '320k',
                                    ),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.audiotrack,
                                      color: Colors.green,
                                    ),
                                    title: const Text(
                                      'Kualitas Sedang (192kbps)',
                                    ),
                                    trailing: const Icon(
                                      Icons.download_rounded,
                                    ),
                                    onTap: () => _processDownload(
                                      streamInfo: _streams!['audio_only']!.last,
                                      isAudio: true,
                                      requiresMuxing: false,
                                      audioBitrate: '192k',
                                    ),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.audiotrack,
                                      color: Colors.green,
                                    ),
                                    title: const Text(
                                      'Kualitas Rendah (128kbps)',
                                    ),
                                    trailing: const Icon(
                                      Icons.download_rounded,
                                    ),
                                    onTap: () => _processDownload(
                                      streamInfo: _streams!['audio_only']!.last,
                                      isAudio: true,
                                      requiresMuxing: false,
                                      audioBitrate: '128k',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'RaDwnldr',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // 1. PREMIUM SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Icon(Icons.link_rounded, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'Paste link YouTube di sini...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _analyzeVideo,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. MAIN CONTENT AREA (SCROLLABLE)
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // --- CINEMATIC METADATA CARD ---
                if (_videoMetadata != null && !_isLoading) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Background Image
                          Image.network(
                            _videoMetadata!.thumbnails.highResUrl,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                          // Dark Gradient Overlay
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.9),
                                  Colors.black.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          // Text Content
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _formatVideoDuration(
                                          _videoMetadata!.duration,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _videoMetadata!.author,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _videoMetadata!.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _showResolutionBottomSheet,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download_rounded),
                                        SizedBox(width: 10),
                                        Text(
                                          'PILIH RESOLUSI',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // --- SHIMMER LOADING ---
                if (_isLoading) ...[
                  Shimmer.fromColors(
                    baseColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    highlightColor: colorScheme.surfaceContainerHighest,
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // --- SMART QUEUE SYSTEM ---
                const Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 20,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Antrian Unduhan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Consumer<QueueProvider>(
                  builder: (context, queueProvider, child) {
                    if (queueProvider.queue.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Belum ada tugas...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // --- LOGIKA SMART SORTING ---
                    final allTasks = queueProvider.queue;
                    final activeTasks = allTasks
                        .where(
                          (t) =>
                              t.status == TaskStatus.downloading ||
                              t.status == TaskStatus.processing,
                        )
                        .toList();
                    final waitingTasks = allTasks
                        .where((t) => t.status == TaskStatus.waiting)
                        .toList();
                    final completedTasks = allTasks
                        .where(
                          (t) =>
                              t.status == TaskStatus.success ||
                              t.status == TaskStatus.error,
                        )
                        .toList()
                        .reversed
                        .toList();

                    final displayQueue = [
                      ...activeTasks,
                      ...waitingTasks,
                      ...completedTasks,
                    ];

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayQueue.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = displayQueue[index];
                        final isActive =
                            task.status == TaskStatus.downloading ||
                            task.status == TaskStatus.processing;
                        final isDone = task.status == TaskStatus.success;
                        final isError = task.status == TaskStatus.error;

                        return Container(
                          decoration: BoxDecoration(
                            color: isActive
                                ? colorScheme.primaryContainer.withValues(
                                    alpha: 0.1,
                                  )
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? colorScheme.primary.withValues(alpha: 0.5)
                                  : colorScheme.outlineVariant.withValues(
                                      alpha: 0.3,
                                    ),
                              width: isActive ? 1.5 : 1.0,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Thumbnail dengan Status Overlay
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 80,
                                  height: 60,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        task.thumbnail,
                                        fit: BoxFit.cover,
                                      ),
                                      if (isDone)
                                        Container(
                                          color: Colors.green.withValues(
                                            alpha: 0.7,
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      if (isError)
                                        Container(
                                          color: Colors.red.withValues(
                                            alpha: 0.7,
                                          ),
                                          child: const Icon(
                                            Icons.error,
                                            color: Colors.white,
                                          ),
                                        ),
                                      if (!isActive && !isDone && !isError)
                                        Container(
                                          color: Colors.black45,
                                          child: const Icon(
                                            Icons.schedule,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Detail Teks & Progress
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDone ? Colors.grey : null,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      task.statusText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isError
                                            ? Colors.red
                                            : Colors.grey,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    // PROGRESS BAR (JIKA SEDANG JALAN)
                                    if (isActive) ...[
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: LinearProgressIndicator(
                                          value: task.progress,
                                          backgroundColor: colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          color:
                                              task.status ==
                                                  TaskStatus.processing
                                              ? Colors.orange
                                              : colorScheme.primary,
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],

                                    // ==========================================
                                    // TOMBOL AKSI PREMIUM (MUNCUL KALAU SELESAI/GAGAL)
                                    // ==========================================
                                    if (isDone || isError) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          // Tombol Lihat Folder (Hanya Muncul Jika Sukses)
                                          if (isDone)
                                            InkWell(
                                              onTap: () =>
                                                  queueProvider.openFolder(
                                                    task.saveDirectory,
                                                  ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.folder_open_rounded,
                                                      size: 14,
                                                      color:
                                                          colorScheme.primary,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      'Lihat Folder',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          if (isDone) const SizedBox(width: 10),

                                          // Tombol Hapus Riwayat (Muncul Jika Sukses / Gagal)
                                          InkWell(
                                            onTap: () => queueProvider
                                                .removeTask(task.id),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    size: 14,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    'Hapus',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
