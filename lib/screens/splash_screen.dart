import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Kontroler Animasi selama 3 detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Animasi Progres Bar (0.0 ke 1.0)
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    _controller.forward();

    // Navigasi ke Home setelah selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 1000),
              pageBuilder: (_, _, _) => const HomeScreen(),
              transitionsBuilder: (_, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(
        0xFF0B1120,
      ), // Deep Navy murni biar logo standout
      body: Stack(
        children: [
          // 1. KONTEN TENGAH (LOGO & BRAND)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- GLOWING & PULSING LOGO ---
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(
                              alpha: 0.4 * _controller.value,
                            ),
                            blurRadius: 30 + (20 * _controller.value),
                            spreadRadius: 5 + (5 * _controller.value),
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
                                size: 60,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // --- APP NAME ---
                Text(
                  'RaDwnldr',
                  style: GoogleFonts.workSans(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PREMIUM EDITION',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.0,
                  ),
                ),

                const SizedBox(height: 60),

                // --- CUSTOM PREMIUM PROGRESS BAR (PLAYBACK STYLE) ---
                Column(
                  children: [
                    Container(
                      width: 250,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 250 * _progressAnimation.value,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary,
                                      Colors.purpleAccent.shade100,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Icon(
                      Icons.cloud_done_outlined,
                      color: Colors.white24,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. FOOTER (MOTO & BRANDING)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '"Build with logic. Secure with discipline. Deliver with pride."',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
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
                        color: Colors.white38,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'RadevankaProject',
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
