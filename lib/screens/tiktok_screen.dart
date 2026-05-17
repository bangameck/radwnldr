import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../services/tiktok_service.dart';
import '../services/download_service.dart';
import '../widgets/alert_premium.dart';
import '../models/download_task.dart';
import '../providers/queue_provider.dart';
import '../providers/app_provider.dart';

class TiktokScreen extends StatefulWidget {
  const TiktokScreen({super.key});

  @override
  State<TiktokScreen> createState() => _TiktokScreenState();
}

class _TiktokScreenState extends State<TiktokScreen>
    with WidgetsBindingObserver {
  final TextEditingController _urlController = TextEditingController();
  final TiktokService _tiktokService = TiktokService();
  final DownloadService _dlService = DownloadService();

  bool _isLoading = false;
  TiktokData? _tiktokData;

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
      if ((text.contains('tiktok.com') || text.contains('vt.tiktok.com')) &&
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
      _tiktokData = null;
    });

    try {
      FocusScope.of(context).unfocus();
      var data = await _tiktokService.getTiktokData(_urlController.text);

      if (!mounted) return;
      setState(() {
        _tiktokData = data;
      });
    } catch (e) {
      if (!mounted) return;
      AlertPremium.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ========================================================
  // PERBAIKAN: TAMBAH PARAMETER customThumbnail
  // ========================================================
  Future<void> _processDownload({
    required String targetUrl,
    required bool isAudio,
    required String format,
    required String titlePrefix,
    String? customThumbnail, // <--- INI TAMBAHANNYA WAK
  }) async {
    bool hasPermission = await _dlService.requestStoragePermission();
    if (!mounted) return;

    if (!hasPermission) {
      AlertPremium.showError(context, 'Izin penyimpanan ditolak!');
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final String baseDir = isAudio
        ? appProvider.audioPath
        : appProvider.socialPath;

    final cleanAuthor = _tiktokData!.author
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '');
    final now = DateTime.now();
    final timestamp =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

    final finalTitle = "${titlePrefix}_${cleanAuthor}_$timestamp";

    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      videoUrl: targetUrl,
      title: finalTitle.length > 40
          ? "${finalTitle.substring(0, 40)}..."
          : finalTitle,
      thumbnail:
          customThumbnail ??
          _tiktokData!.thumbnail, // <--- THUMBNAIL NYA JADI DINAMIS
      qualityLabel: isAudio
          ? 'MP3 Audio'
          : (format == 'tiktok_slideshow' ? 'Cover + Audio' : 'HD No-WM'),
      isAudio: isAudio,
      requiresMuxing: false,
      totalDurationMs: 0,
      audioBitrate: '320k',
      saveDirectory: baseDir,
      videoFormat: format,
    );

    Provider.of<QueueProvider>(context, listen: false).addTask(task);
    AlertPremium.showSuccess(context, 'Masuk Antrian:\n${task.title}');

    if (format != 'jpg') {
      setState(() {
        _urlController.clear();
        _tiktokData = null;
      });
    }
  }

  // ========================================================
  // FITUR PREMIUM: PILIH COVER UNTUK MUXING MP4
  // ========================================================
  void _showSlideSelectionBottomSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
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
              const SizedBox(height: 20),
              const Text(
                'Pilih Cover Utama',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 5),
              const Text(
                'Gambar yang dipilih akan digabungkan dengan lagu',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75, // Proporsi mirip layar HP
                  ),
                  itemCount: _tiktokData!.images!.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _tiktokData!.images![index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context); // Tutup dialog setelah milih
                        // Langsung hajar masuk antrian dengan customThumbnail!
                        _processDownload(
                          targetUrl: _tiktokData!.musicUrl,
                          isAudio: false,
                          format: 'tiktok_slideshow',
                          titlePrefix: 'SLIDE',
                          customThumbnail: imageUrl, // <--- MAGIC-NYA DI SINI
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                          // Label nomor urut di pojok kiri atas
                          Positioned(
                            top: 5,
                            left: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Slide ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colorCyan = const Color(0xFF00f2fe);
    final colorPink = const Color(0xFFfe0979);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'TikTok Downloader',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // 1. TIKTOK URL BAR
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorCyan.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Icon(Icons.link_rounded, color: colorPink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'Paste link TikTok di sini...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _analyzeVideo(),
                    ),
                  ),
                  if (_urlController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _urlController.clear();
                          _tiktokData = null;
                        });
                      },
                    ),
                  GestureDetector(
                    onTap: _isLoading ? null : _analyzeVideo,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorCyan, colorPink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
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

          // 2. MAIN CONTENT AREA
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (_isLoading) ...[
                  Shimmer.fromColors(
                    baseColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    highlightColor: theme.colorScheme.surfaceContainerHighest,
                    child: Container(
                      width: double.infinity,
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // --- HASIL ANALISA TIKTOK ---
                if (_tiktokData != null && !_isLoading) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ========================================================
                        // UI SLIDE GAMBAR DENGAN TOMBOL CERDAS
                        // ========================================================
                        if (_tiktokData!.images != null &&
                            _tiktokData!.images!.isNotEmpty) ...[
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(15),
                              itemCount: _tiktokData!.images!.length,
                              itemBuilder: (context, index) {
                                final imageUrl = _tiktokData!.images![index];
                                return Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 15),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      // KITA BUNGKUS TOMBOL DENGAN CONSUMER QUEUE
                                      Consumer<QueueProvider>(
                                        builder: (context, queueProvider, child) {
                                          // Ngecek apakah link gambar ini sudah ada di antrian/selesai
                                          bool isDownloaded = queueProvider
                                              .queue
                                              .any(
                                                (t) => t.videoUrl == imageUrl,
                                              );

                                          // Kalau sudah di-donlot, tampilkan centang hijau
                                          if (isDownloaded) {
                                            return Positioned(
                                              bottom: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withValues(alpha: 0.9),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white54,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            );
                                          }

                                          // Kalau belum di-donlot, tampilkan tombol donlot
                                          return Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: InkWell(
                                              onTap: () => _processDownload(
                                                targetUrl: imageUrl,
                                                isAudio: false,
                                                format: 'jpg',
                                                titlePrefix: 'IMG_${index + 1}',
                                                customThumbnail:
                                                    imageUrl, // Thumbnail Sesuai Foto Slide
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.7),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white24,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.download_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.collections_rounded,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Postingan Slide (Pilih gambar untuk unduh)',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                            child: Image.network(
                              _tiktokData!.thumbnail,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    color: colorPink,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _tiktokData!.author,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorPink,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _tiktokData!.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 25),

                              if (_tiktokData!.images != null) ...[
                                _buildActionBtn(
                                  icon: Icons.music_note_rounded,
                                  label: 'Download Lagu (MP3)',
                                  color: colorCyan,
                                  onTap: () => _processDownload(
                                    targetUrl: _tiktokData!.musicUrl,
                                    isAudio: true,
                                    format: 'mp3',
                                    titlePrefix: 'AUDIO',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildActionBtn(
                                  icon: Icons.auto_awesome_motion_rounded,
                                  label: 'Jadikan Video MP4',
                                  color: colorPink,

                                  // ==========================================
                                  // UBAH ONTAP MENJADI MANGGIL BOTTOM SHEET
                                  // ==========================================
                                  onTap: () => _showSlideSelectionBottomSheet(),
                                ),
                              ] else ...[
                                _buildActionBtn(
                                  icon: Icons.high_quality_rounded,
                                  label: 'Video HD (No Watermark)',
                                  color: colorPink,
                                  onTap: () => _processDownload(
                                    targetUrl:
                                        _tiktokData!.hdVideoUrl ??
                                        _tiktokData!.videoUrl!,
                                    isAudio: false,
                                    format: 'mp4',
                                    titlePrefix: 'TK',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildActionBtn(
                                  icon: Icons.sd_card_rounded,
                                  label: 'Video Biasa (No Watermark)',
                                  color: Colors.blueAccent,
                                  onTap: () => _processDownload(
                                    targetUrl: _tiktokData!.videoUrl!,
                                    isAudio: false,
                                    format: 'mp4',
                                    titlePrefix: 'TK',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildActionBtn(
                                  icon: Icons.music_note_rounded,
                                  label: 'Download Audio (MP3)',
                                  color: colorCyan,
                                  onTap: () => _processDownload(
                                    targetUrl: _tiktokData!.musicUrl,
                                    isAudio: true,
                                    format: 'mp3',
                                    titlePrefix: 'AUDIO',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                Consumer<QueueProvider>(
                  builder: (context, queueProvider, child) {
                    final hasHistory = queueProvider.queue.any(
                      (t) =>
                          t.status == TaskStatus.success ||
                          t.status == TaskStatus.error,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            if (hasHistory)
                              TextButton.icon(
                                onPressed: () => queueProvider.clearHistory(),
                                icon: const Icon(
                                  Icons.clear_all_rounded,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                                label: const Text(
                                  'Bersihkan',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        if (queueProvider.queue.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
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
                          )
                        else
                          _buildQueueList(queueProvider, theme),
                      ],
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

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildQueueList(QueueProvider queueProvider, ThemeData theme) {
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
          (t) => t.status == TaskStatus.success || t.status == TaskStatus.error,
        )
        .toList()
        .reversed
        .toList();
    final displayQueue = [...activeTasks, ...waitingTasks, ...completedTasks];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayQueue.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
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
                        errorBuilder: (c, e, s) =>
                            Container(color: Colors.grey),
                      ),
                      if (isDone)
                        Container(
                          color: Colors.green.withValues(alpha: 0.7),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ),
                      if (isError)
                        Container(
                          color: Colors.red.withValues(alpha: 0.7),
                          child: const Icon(Icons.error, color: Colors.white),
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
                        color: isError ? Colors.red : Colors.grey,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isActive) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: task.progress,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          color: task.status == TaskStatus.processing
                              ? Colors.orange
                              : theme.colorScheme.primary,
                          minHeight: 6,
                        ),
                      ),
                    ],
                    if (isDone || isError) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (isDone)
                            InkWell(
                              onTap: () {
                                final appProv = Provider.of<AppProvider>(
                                  context,
                                  listen: false,
                                );
                                queueProvider.openFolder(
                                  task.isAudio
                                      ? appProv.audioPath
                                      : appProv.socialPath,
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.folder_open_rounded,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Lihat Folder',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (isDone) const SizedBox(width: 10),
                          InkWell(
                            onTap: () => queueProvider.removeTask(task.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
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
  }
}
