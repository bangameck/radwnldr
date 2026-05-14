import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'providers/queue_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================
  // UI SYSTEM PREMIUM (TRANSPARENT STATUS BAR)
  // ==========================================
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'download_channel',
      channelName: 'Progres Unduhan',
      channelDescription: 'Menampilkan progres unduhan dan konversi',
      defaultColor: const Color(0xFF0D47A1),
      ledColor: Colors.white,
      importance: NotificationImportance.High,
      onlyAlertOnce: true,
      criticalAlerts: true,
    ),
  ], debug: true);

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
      ],
      child: const RaDwnldrApp(),
    ),
  );
}

class RaDwnldrApp extends StatelessWidget {
  const RaDwnldrApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Setup Tema Dasar
    // PENTING: useMaterial3 sudah otomatis true di constructor ini
    final baseTheme = provider.isDarkMode
        ? ThemeData(brightness: Brightness.dark, useMaterial3: true)
        : ThemeData(brightness: Brightness.light, useMaterial3: true);

    final scaffoldColor = provider.isDarkMode
        ? AppProvider.deepNavy
        : const Color(0xFFF8F9FA);

    return MaterialApp(
      title: 'RaDwnldr',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: scaffoldColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: provider.accentColor,
          brightness: provider.isDarkMode ? Brightness.dark : Brightness.light,
          primary: provider.accentColor,
        ),

        textTheme: GoogleFonts.workSansTextTheme(baseTheme.textTheme),

        // 1. APP BAR PREMIUM
        appBarTheme: AppBarTheme(
          backgroundColor: scaffoldColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: provider.isDarkMode ? Colors.white : Colors.black87,
          ),
          titleTextStyle: GoogleFonts.workSans(
            color: provider.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),

        // 2. CARD PREMIUM (PERBAIKAN: Gunakan CardThemeData)
        cardTheme: CardThemeData(
          elevation: 0,
          color: provider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // 3. BOTTOM SHEET PREMIUM
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        // 4. TOMBOL PREMIUM
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // 5. INPUT FORM PREMIUM
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: provider.isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
