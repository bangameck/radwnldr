import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import '../widgets/app_drawer.dart';
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

    // Trik Fake Loading Skeleton Premium
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Inisialisasi Video Background
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
        // Skeleton Banner (Polos)
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 200, // Diperbesar dikit biar makin cinematic
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        const SizedBox(height: 25),

        // Skeleton Judul Premium yang dipindah ke luar
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

        // Skeleton Grid
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
        // --- BANNER UTAMA DENGAN VIDEO MP4 (KINI POLOS & LEBIH BESAR) ---
        Container(
          height: 200, // Ditinggikan biar lebih memanjakan mata
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

                // Overlay tipis banget biar warna video tetep tajam tapi gak menyilaukan
                Container(color: Colors.black.withValues(alpha: 0.1)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),

        // --- TEKS HEADER PREMIUM (DIPINDAH KE LUAR BANNER) ---
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

        // --- TEKS SUB-HEADER ---
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

        // --- GRID ACTION BUTTONS ---
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
        const SizedBox(height: 20), // Ekstra padding di bawah
      ],
    );
  }

  // --- WIDGET CARD CUSTOM ---
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
