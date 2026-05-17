import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/settings_screen.dart';
import '../screens/youtube_screen.dart';
import '../screens/tiktok_screen.dart';

// ======================================================================
// FUNGSI GLOBAL UNTUK MODAL (Bisa dipanggil dari mana saja)
// ======================================================================

void showChangelogModal(BuildContext context, String currentVersion) {
  final theme = Theme.of(context);
  final primary = theme.colorScheme.primary;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * 0.85,
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
                    color: primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.new_releases_rounded,
                    color: primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apa yang Baru?',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Riwayat Pembaruan RaDwnldr',
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
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                // --- VERSI 1.2.0 ---
                _changelogVersion(
                  theme,
                  '1.2.0',
                  '18 Mei 2026',
                  isLatest: true,
                  primary: primary,
                  changes: [
                    _clItem(
                      theme,
                      Icons.video_library_rounded,
                      'TikTok Downloader Engine',
                      'Unduh video tanpa watermark, ekstrak MP3, dan fitur Magic Muxing untuk post foto Slide.',
                      Colors.pinkAccent,
                    ),
                    _clItem(
                      theme,
                      Icons.folder_special_rounded,
                      'Universal Download Manager',
                      'Arsitektur cerdas pemisah unduhan YouTube dan TikTok beserta direktori khusus Social Media.',
                      Colors.blue,
                    ),
                    _clItem(
                      theme,
                      Icons.cleaning_services_rounded,
                      'Bulk Clean & Smart Naming',
                      'Penamaan otomatis anti-overwrite dan sapu bersih histori antrian.',
                      const Color(0xFF00FF9D),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // --- VERSI 1.1.0 ---
                _changelogVersion(
                  theme,
                  '1.1.0',
                  '17 Mei 2026',
                  isLatest: false,
                  primary: primary,
                  changes: [
                    _clItem(
                      theme,
                      Icons.search_rounded,
                      'YouTube Search Integration',
                      'Pencarian video langsung di dalam aplikasi tanpa perlu copy-paste link.',
                      Colors.red,
                    ),
                    _clItem(
                      theme,
                      Icons.folder_rounded,
                      'Native SAF Folder Navigation',
                      'Sistem navigasi folder dengan format URI Android 11+ Scoped Storage.',
                      Colors.amber,
                    ),
                    _clItem(
                      theme,
                      Icons.memory_rounded,
                      'OOM RAM Optimization',
                      'Pencegahan crash di HP entry-level dengan mode largeHeap dan perbaikan JNI Release Mode.',
                      Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // --- VERSI 1.0.0 ---
                _changelogVersion(
                  theme,
                  '1.0.0',
                  '15 Mei 2026',
                  isLatest: false,
                  primary: primary,
                  changes: [
                    _clItem(
                      theme,
                      Icons.dashboard_rounded,
                      'Smart Queue System',
                      'Sistem antrian pintar dengan tampilan visual premium dan fitur auto-sorting.',
                      Colors.blue,
                    ),
                    _clItem(
                      theme,
                      Icons.battery_charging_full_rounded,
                      'Native WakeLock',
                      'Mencegah CPU tertidur saat mengunduh atau melakukan muxing FFmpeg di latar belakang.',
                      const Color(0xFF00FF9D),
                    ),
                    _clItem(
                      theme,
                      Icons.shield_rounded,
                      'Bypass 403 Forbidden',
                      'Client spoofing menggunakan iOS/VR signatures untuk menghindari pemblokiran YouTube.',
                      Colors.orange,
                    ),
                    _clItem(
                      theme,
                      Icons.movie_creation_rounded,
                      'FFmpeg Muxing',
                      'Penggabungan otomatis video HD dan audio resolusi tinggi menggunakan library native.',
                      Colors.purple,
                    ),
                    _clItem(
                      theme,
                      Icons.auto_awesome_rounded,
                      'Premium UI',
                      'Desain antarmuka eksklusif dengan efek Glassmorphism, Video Background, dan Skeleton Loading.',
                      primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void showTutorialModal(BuildContext context) {
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
                      'Panduan Mengunduh Media (YT & TikTok)',
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                _privacySectionGlobal(
                  theme,
                  '1️⃣ Cari atau Salin Tautan',
                  'Buka aplikasi YouTube / TikTok, lalu salin tautan (Copy Link) dari video atau postingan yang Anda inginkan.\n\n💡 Tip: Khusus YouTube, Anda juga bisa langsung mengetikkan judul lagu/video di kolom pencarian aplikasi RaDwnldr.',
                ),
                _privacySectionGlobal(
                  theme,
                  '2️⃣ Tempel (Paste) Tautan',
                  'Pilih menu YouTube atau TikTok di layar utama RaDwnldr, lalu tempel tautan ke kolom yang disediakan. Aplikasi akan otomatis menganalisa metadata media tersebut.',
                ),
                _privacySectionGlobal(
                  theme,
                  '3️⃣ Pilih Resolusi & Format Khusus',
                  '• YouTube: Pilih resolusi Video kualitas tinggi (Membutuhkan proses penggabungan/Muxing) atau unduh Audio (MP3).\n\n• TikTok: Unduh Video (Tanpa Watermark), MP3 Audio, atau simpan foto dari postingan Slide. \n\n✨ Fitur Premium: Pada postingan TikTok Slide, tekan "Jadikan Video MP4" untuk otomatis menggabungkan gambar dan lagu menjadi satu video utuh!',
                ),
                _privacySectionGlobal(
                  theme,
                  '4️⃣ Smart Queue & Pemrosesan',
                  'Media akan masuk ke daftar "Antrian Unduhan". Sistem akan mengunduh dan melakukan pemrosesan native FFmpeg secara otomatis. Anda dapat memantau progres langsung dari dalam aplikasi maupun panel notifikasi.',
                ),
                _privacySectionGlobal(
                  theme,
                  '⚠️ Peringatan Penting',
                  'Selama proses pemrosesan/Muxing sedang berjalan (terutama pembuatan Video MP4 dari gambar atau YouTube 4K), mohon jangan menutup paksa (force close) aplikasi. Fitur Android WakeLock sudah aktif, sehingga proses tetap aman berjalan meskipun layar HP mati.',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper Widget untuk Changelog Modal
Widget _changelogVersion(
  ThemeData theme,
  String ver,
  String date, {
  required List<Widget> changes,
  bool isLatest = false,
  required Color primary,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isLatest
                  ? primary.withValues(alpha: 0.15)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'v$ver',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                color: isLatest ? primary : theme.colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ),
          if (isLatest) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Terbaru',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            date,
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...changes,
    ],
  );
}

// Helper Widget untuk Item Changelog
Widget _clItem(
  ThemeData theme,
  IconData icon,
  String title,
  String desc,
  Color color,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.12)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper Widget untuk Privacy/Tutorial Section Global
Widget _privacySectionGlobal(ThemeData theme, String title, String body) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: GoogleFonts.workSans(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    ),
  );
}

// ======================================================================
// KELAS APP DRAWER UTAMA
// ======================================================================
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // 1. CUSTOM PREMIUM HEADER
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.primary,
                          child: const Icon(
                            Icons.cloud_download_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RaDwnldr',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Premium Edition',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. DAFTAR MENU PLATFORM
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10),
                  child: Text(
                    'PLATFORMS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                _buildMenu(
                  context,
                  'YouTube',
                  const FaIcon(
                    FontAwesomeIcons.youtube,
                    color: Colors.red,
                    size: 22,
                  ),
                  'Available',
                ),
                _buildMenu(
                  context,
                  'Instagram',
                  const FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Colors.grey,
                    size: 22,
                  ),
                  'Soon',
                ),
                _buildMenu(
                  context,
                  'TikTok',
                  const FaIcon(
                    FontAwesomeIcons.tiktok,
                    color: Colors.grey,
                    size: 22,
                  ),
                  'Available',
                ),
                _buildMenu(
                  context,
                  'Facebook',
                  const FaIcon(
                    FontAwesomeIcons.facebookF,
                    color: Colors.grey,
                    size: 22,
                  ),
                  'Soon',
                ),
              ],
            ),
          ),

          // 3. FOOTER (SETTINGS, ABOUT, PRIVACY)
          _buildFooterMenu(
            context,
            'Tutorial Penggunaan',
            Icons.menu_book_rounded,
            () {
              Navigator.pop(context);
              showTutorialModal(context); // Panggil fungsi global
            },
          ),
          _buildFooterMenu(
            context,
            'Tentang Aplikasi',
            Icons.info_outline_rounded,
            () {
              Navigator.pop(context);
              _showAboutModal(context);
            },
          ),
          _buildFooterMenu(
            context,
            'Kebijakan Privasi',
            Icons.privacy_tip_outlined,
            () {
              Navigator.pop(context);
              _showPrivacyModal(context);
            },
          ),
          _buildFooterMenu(context, 'Pengaturan', Icons.settings_rounded, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '1.2.0';
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showChangelogModal(
                      context,
                      version,
                    ); // Panggil fungsi global
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
    );
  }

  // WIDGET CARD MENU PLATFORM
  Widget _buildMenu(
    BuildContext context,
    String title,
    Widget iconWidget,
    String badge,
  ) {
    bool isAvailable = badge == 'Available';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable
            ? colorScheme.primaryContainer.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAvailable
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: iconWidget,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
            color: isAvailable ? null : Colors.grey,
            fontSize: 15,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isAvailable
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAvailable
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 10,
              color: isAvailable ? Colors.green : Colors.grey.shade600,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        onTap: isAvailable
            ? () {
                Navigator.pop(context);
                if (title == 'YouTube') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const YoutubeScreen(),
                    ),
                  );
                }
                if (title == 'TikTok') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TiktokScreen(),
                    ),
                  );
                }
              }
            : null,
      ),
    );
  }

  Widget _buildFooterMenu(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ABOUT MODAL ──────────────────────────────────────────────
  void _showAboutModal(BuildContext context) async {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    if (!context.mounted) return;

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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 56,
                            height: 56,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.cloud_download_rounded,
                                size: 56,
                                color: primary,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'RaDwnldr',
                          style: GoogleFonts.workSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Premium Media Downloader',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            color: primary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.06,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Versi $appVersion (Pro Build)',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.03,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.07,
                        ),
                      ),
                    ),
                    child: Text(
                      'Aplikasi pengunduh media premium khusus Android dengan fitur Smart Queue, bypass proteksi YouTube, dan integrasi Native FFmpeg langsung dari smartphone Anda.',
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                        height: 1.65,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Fitur Utama',
                    style: GoogleFonts.workSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _featureRow(
                    theme,
                    Icons.security_rounded,
                    'Spoofing Anti 403 Forbidden',
                    primary,
                  ),
                  _featureRow(
                    theme,
                    Icons.movie_filter_rounded,
                    'Native FFmpeg Muxing Kit',
                    primary,
                  ),
                  _featureRow(
                    theme,
                    Icons.battery_saver_rounded,
                    'Android WakeLock Support',
                    primary,
                  ),
                  _featureRow(
                    theme,
                    Icons.dashboard_customize_rounded,
                    'Smart Queue Auto-Sorting',
                    primary,
                  ),
                  _featureRow(
                    theme,
                    Icons.folder_shared_rounded,
                    'Simpan Langsung ke Galeri',
                    primary,
                  ),

                  const SizedBox(height: 20),

                  // ===================================================
                  // SECTION BARU: CREDITS & OPEN SOURCE
                  // ===================================================
                  Text(
                    'Special Thanks & Credits',
                    style: GoogleFonts.workSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.03,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.07,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _creditRow(
                          theme,
                          Icons.code_rounded,
                          'youtube_explode_dart',
                          'Mesin utama bypass JavaScript & ekstraksi manifest YouTube.',
                          primary,
                        ),
                        const Divider(height: 20),
                        _creditRow(
                          theme,
                          Icons.api_rounded,
                          'TikWM Public API',
                          'Layanan API cerdas untuk unduhan video & slide foto TikTok.',
                          primary,
                        ),
                        const Divider(height: 20),
                        _creditRow(
                          theme,
                          Icons.video_settings_rounded,
                          'FFmpeg Kit',
                          'Pahlawan tanpa tanda jasa di balik layar re-encode & muxing.',
                          primary,
                        ),
                      ],
                    ),
                  ),

                  // ===================================================
                  const SizedBox(height: 20),
                  Text(
                    'Dikembangkan Oleh',
                    style: GoogleFonts.workSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.03,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.07,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/radevanka-logo.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person_rounded,
                                    size: 40,
                                    color: primary,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RadevankaProject',
                                  style: GoogleFonts.workSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '📍 Pekanbaru, Indonesia',
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _socialChip(
                              theme,
                              'Radevanka',
                              Icons.public_rounded,
                              'https://radevankaproject.web.id/',
                              Colors.blueAccent,
                            ),
                            _socialChip(
                              theme,
                              'GitHub',
                              Icons.code_rounded,
                              'https://github.com/bangameck',
                              Colors.grey,
                            ),
                            _socialChip(
                              theme,
                              'Instagram',
                              Icons.camera_alt_rounded,
                              'https://instagram.com/bangameck',
                              const Color(0xFFE4405F),
                            ),
                            _socialChip(
                              theme,
                              'TikTok',
                              Icons.music_note_rounded,
                              'https://tiktok.com/@bangameck.dev',
                              Colors.grey,
                            ),
                            _socialChip(
                              theme,
                              'Dukung Developer',
                              Icons.local_cafe_rounded,
                              'https://trakteer.id/rproject',
                              Colors.amber,
                              isFeatured: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '"Kami menjamin pengalaman premium tanpa iklan."',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: primary.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '© 2026 RadevankaProject. Hak cipta dilindungi.',
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER LAMA
  Widget _featureRow(
    ThemeData theme,
    IconData icon,
    String text,
    Color primary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primary),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER BARU UNTUK CREDITS WAK!
  Widget _creditRow(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    Color primary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialChip(
    ThemeData theme,
    String label,
    IconData icon,
    String url,
    Color color, {
    bool isFeatured = false,
  }) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isFeatured
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFeatured ? color : color.withValues(alpha: 0.25),
            width: isFeatured ? 1.5 : 1.0,
          ),
          boxShadow: isFeatured
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 12,
                fontWeight: isFeatured ? FontWeight.bold : FontWeight.w500,
                color: isFeatured
                    ? color
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PRIVACY POLICY MODAL ─────────────────────────────────────
  void _showPrivacyModal(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

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
                      color: Colors.indigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: Colors.indigo,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kebijakan Privasi',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Terakhir Diperbarui : Mei 2026',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  _privacySectionGlobal(
                    theme,
                    '🔒 Pengumpulan Data',
                    'Aplikasi ini beroperasi 100% secara lokal. Kami tidak mengumpulkan atau membagikan data unduhan Anda ke server manapun.',
                  ),
                  _privacySectionGlobal(
                    theme,
                    '📁 Akses Penyimpanan',
                    'Izin penyimpanan (Storage/Media) hanya digunakan untuk menyimpan file hasil unduhan langsung ke HP Anda.',
                  ),
                  _privacySectionGlobal(
                    theme,
                    '🔐 Keamanan',
                    'Semua proses unduhan dilakukan melalui jalur aman (HTTPS) langsung dari server penyedia konten (seperti YouTube).',
                  ),
                  _privacySectionGlobal(
                    theme,
                    '🧬 Data Analytics',
                    'Kami tidak menyertakan SDK pelacakan (tracking) atau analitik pihak ketiga demi menjaga privasi pengguna secara maksimal.',
                  ),
                  _privacySectionGlobal(
                    theme,
                    '🌐 Koneksi Internet',
                    'Akses internet mutlak diperlukan untuk mengunduh media yang Anda minta beserta mengambil metadatanya.',
                  ),
                  _privacySectionGlobal(
                    theme,
                    '📝 Perubahan Kebijakan',
                    'Jika ada perubahan mendasar pada pengelolaan izin, kami akan merilis pemberitahuan melalui changelog resmi.',
                  ),
                  _privacySectionGlobal(
                    theme,
                    '📬 Kontak Developer',
                    'Jika ada pertanyaan mengenai keamanan dan privasi, hubungi pengembang melalui Instagram @bangameck.',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'Singkatnya: RaDwnldr sepenuhnya berjalan secara lokal di perangkat Anda, menjaga privasi Anda tetap aman tanpa celah bocornya riwayat unduhan.',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: primary.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
