import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/app_drawer.dart'; // Pastikan nama file ini sesuai dan sudah di-save!
import 'youtube_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _checkWelcomeModal();
      }
    });

    _videoController = VideoPlayerController.asset('assets/videos/banner.mp4')
      ..initialize()
          .then((_) {
            _videoController.setVolume(0.0);
            _videoController.setLooping(true);
            _videoController.play();
            if (mounted) {
              setState(() {
                _isVideoInitialized = true;
              });
            }
          })
          .catchError((error) {
            debugPrint("Gagal meload video banner: $error");
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  // ==========================================
  // LOGIKA MODAL WELCOME & TUTORIAL
  // ==========================================
  Future<void> _checkWelcomeModal() async {
    final prefs = await SharedPreferences.getInstance();
    bool hideModal = prefs.getBool('hideWelcomeModal') ?? false;

    if (!hideModal && mounted) {
      _showWelcomeDialog();
    }
  }

  void _showWelcomeDialog() {
    bool dontShowAgain = false;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        // Menggunakan dialogCtx agar tidak bentrok
        return StatefulBuilder(
          builder: (innerContext, setStateBuilder) {
            // innerContext khusus untuk state dalam dialog
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'RaDwnldr adalah aplikasi pengunduh media premium dengan fitur Bypass dan Muxing berkecepatan tinggi.\n\nApakah Anda ingin melihat panduan cara menggunakannya terlebih dahulu?',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: CheckboxListTile(
                      value: dontShowAgain,
                      activeColor: theme.colorScheme.primary,
                      title: const Text(
                        'Jangan tampilkan pesan ini lagi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setStateBuilder(() {
                          dontShowAgain = val ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () async {
                    if (dontShowAgain) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hideWelcomeModal', true);
                    }
                    // Cek mounted menggunakan context milik dialog (innerContext)
                    if (!innerContext.mounted) return;
                    Navigator.pop(innerContext);
                  },
                  child: const Text(
                    'Tutup',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (dontShowAgain) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hideWelcomeModal', true);
                    }

                    // 1. Tutup dialognya dulu
                    if (!innerContext.mounted) return;
                    Navigator.pop(innerContext);

                    // 2. Buka tutorial menggunakan context utama (Screen)
                    if (!mounted) return;
                    _showTutorialModal(context);
                  },
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: const Text('Lihat Tutorial'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTutorialModal(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.88,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.orange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tutorial Penggunaan',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Panduan Mengunduh Media',
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  _privacySection(
                    theme,
                    '1️⃣ Salin Tautan (Copy Link)',
                    'Buka aplikasi YouTube resmi, cari video yang ingin Anda unduh, lalu klik tombol "Bagikan" dan pilih "Salin Tautan".',
                  ),
                  _privacySection(
                    theme,
                    '2️⃣ Tempel Tautan (Paste Link)',
                    'Buka aplikasi RaDwnldr, masuk ke menu YouTube, dan tempel (paste) tautan tersebut ke dalam kolom pencarian di bagian atas layar.',
                  ),
                  _privacySection(
                    theme,
                    '3️⃣ Pilih Resolusi & Format',
                    'Aplikasi akan memproses video dan menampilkan daftar resolusi. Anda dapat memilih mode "Video" (Resolusi HD/4K) atau "Audio" (MP3 Murni).',
                  ),
                  _privacySection(
                    theme,
                    '4️⃣ Proses Unduhan & Muxing',
                    'Setelah tombol di-klik, file akan masuk ke daftar "Antrian". Untuk video beresolusi tinggi (1080p ke atas), aplikasi otomatis menggunakan teknologi Muxing FFmpeg untuk menggabungkan video resolusi tinggi dengan audio.',
                  ),
                  _privacySection(
                    theme,
                    '⚠️ Peringatan Penting',
                    'Selama proses Muxing (penggabungan), sangat disarankan untuk tidak menutup paksa (force close) aplikasi. Aplikasi ini memiliki fitur WakeLock yang mencegah HP Anda tertidur, sehingga aman diletakkan meskipun layar mati.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangelogModal(BuildContext context, String version) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.65,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Changelog (Riwayat Update)',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Versi saat ini: v$version',
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  _changelogSection(theme, 'v1.0.0 (Pro Build)', [
                    '🚀 Rilis Perdana RaDwnldr Premium Edition',
                    '🛡️ Integrasi Bypass YouTube JS Challenge (Anti 403)',
                    '⚡ Konversi Cepat Muxing FFmpeg untuk MP4 & MKV',
                    '🔋 Fitur Native WakeLock & Download Latar Belakang',
                    '🎨 UI Cinematic dengan Video Background & Glassmorphism',
                    '📋 Sistem Antrian Pintar (Smart Queue)',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacySection(ThemeData theme, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _changelogSection(
    ThemeData theme,
    String title,
    List<String> changes,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          ...changes.map(
            (change) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      change,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      drawer: const AppDrawer(),
      body: _isLoading
          ? _buildSkeletonUI(colorScheme)
          : _buildPremiumUI(colorScheme),
    );
  }

  // ==========================================
  // 1. TAMPILAN SKELETON (LOADING PREMIUM)
  // ==========================================
  Widget _buildSkeletonUI(ColorScheme colorScheme) {
    final baseColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.4,
    );
    final highlightColor = colorScheme.surfaceContainerHighest;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 30,
            width: 220,
            margin: const EdgeInsets.only(right: 150),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 15,
            width: double.infinity,
            margin: const EdgeInsets.only(right: 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // 2. TAMPILAN UTAMA (SETELAH LOADING)
  // ==========================================
  Widget _buildPremiumUI(ColorScheme colorScheme) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_isVideoInitialized)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                else
                  Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Container(color: Colors.black.withValues(alpha: 0.1)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),

        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [colorScheme.primary, Colors.purpleAccent.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'RaDwnldr Premium ✨',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Unduh media favoritmu tanpa batas kecepatan.\nKualitas tinggi, proses cepat, langsung simpan.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 30),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.apps_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Pilih Platform',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.1,
          children: [
            _buildActionCard(
              context: context,
              title: 'YouTube',
              icon: FontAwesomeIcons.youtube,
              color: Colors.red,
              isAvailable: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const YoutubeScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              context: context,
              title: 'Instagram',
              icon: FontAwesomeIcons.instagram,
              color: const Color(0xFFE1306C),
              isAvailable: false,
              onTap: () {},
            ),
            _buildActionCard(
              context: context,
              title: 'TikTok',
              icon: FontAwesomeIcons.tiktok,
              color: const Color(0xFF000000),
              isAvailable: false,
              onTap: () {},
            ),
            _buildActionCard(
              context: context,
              title: 'Facebook',
              icon: FontAwesomeIcons.facebookF,
              color: const Color(0xFF1877F2),
              isAvailable: false,
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 50),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '"Build with logic. Secure with discipline. Deliver with pride."',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 10,
                  color: Colors.grey.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'by ',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    color: Colors.grey.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  'RadevankaProject',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '1.0.0';
                  return GestureDetector(
                    onTap: () {
                      _showChangelogModal(context, version);
                    },
                    child: Text(
                      'v$version (Pro Build)',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required dynamic icon,
    required Color color,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isAvailable
              ? color.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAvailable
                ? color.withValues(alpha: 0.5)
                : colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? color
                          : Colors.grey.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      boxShadow: isAvailable
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: FaIcon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isAvailable ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (!isAvailable)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'SOON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
