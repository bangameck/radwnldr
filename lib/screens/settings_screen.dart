import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/alert_premium.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // SECTION: APPEARANCE
          _buildSectionHeader('Appearance'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Gunakan tema gelap (Deep Navy)'),
                    value: provider.isDarkMode,
                    activeThumbColor: provider.accentColor,
                    onChanged: (val) => provider.toggleTheme(val),
                  ),
                  const Divider(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Premium Accent Color',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _premiumColorBtn(
                        provider,
                        AppProvider.emerald,
                        'Emerald',
                      ),
                      _premiumColorBtn(
                        provider,
                        AppProvider.crimson,
                        'Crimson',
                      ),
                      _premiumColorBtn(
                        provider,
                        AppProvider.amethyst,
                        'Amethyst',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // SECTION: STORAGE
          _buildSectionHeader('Storage Locations'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'YouTube Video Folder',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    provider.videoPath,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () =>
                      provider.pickFolder(type: 'video'), // PERBAIKAN DI SINI
                ),
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(
                      Icons.library_music,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Audio Folder (All)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    provider.audioPath,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () =>
                      provider.pickFolder(type: 'audio'), // PERBAIKAN DI SINI
                ),
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),

                // --- MENU FOLDER BARU UNTUK TIKTOK/IG ---
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.pinkAccent,
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Social Folder (TikTok/IG)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    provider.socialPath,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => provider.pickFolder(
                    type: 'social',
                  ), // MENGGUNAKAN TYPE SOCIAL
                ),

                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(
                      Icons.cleaning_services_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Clear Temp Cache',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    provider.cacheSize,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      provider.clearCache();
                      AlertPremium.showSuccess(
                        context,
                        'Cache *temp* berhasil dibersihkan!',
                      );
                    },
                    child: const Text('Clean'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _premiumColorBtn(AppProvider provider, Color color, String name) {
    bool isSelected = provider.accentColor == color;
    return GestureDetector(
      onTap: () => provider.changeAccent(color),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: color,
              radius: 20,
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
