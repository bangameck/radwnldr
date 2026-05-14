import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../screens/settings_screen.dart';
import '../screens/youtube_screen.dart';

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
          // ==========================================
          // 1. CUSTOM PREMIUM HEADER
          // ==========================================
          Container(
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(context).padding.top +
                  20, // Aman dari notch/status bar
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
                // --- GLOWING LOGO ---
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
                        // Fallback keren kalau logo belum ada
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

                // --- NAMA APLIKASI ---
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

          // ==========================================
          // 2. DAFTAR MENU PLATFORM
          // ==========================================
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
                  'Soon',
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

          // ==========================================
          // 3. FOOTER (SETTINGS)
          // ==========================================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
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
                      child: Icon(
                        Icons.settings_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          // Versi Aplikasi di paling bawah biar kayak aplikasi profesional
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '1.0.0';
                return Text(
                  'v$version (Pro Build)',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET CARD MENU PLATFORM
  // ==========================================
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
                Navigator.pop(context); // Tutup drawer dulu
                if (title == 'YouTube') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const YoutubeScreen(),
                    ),
                  );
                }
              }
            : null,
      ),
    );
  }
}
