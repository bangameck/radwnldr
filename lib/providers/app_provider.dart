import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class AppProvider extends ChangeNotifier {
  // --- Default Values ---
  bool _isDarkMode = true;
  Color _accentColor = emerald;
  String _videoPath = '/storage/emulated/0/Download/RaDwnldr/Video';
  String _audioPath = '/storage/emulated/0/Download/RaDwnldr/Audio';

  // --- Premium Colors ---
  static const Color emerald = Color(0xFF10B981);
  static const Color crimson = Color(0xFFEF4444);
  static const Color amethyst = Color(0xFF8B5CF6);
  static const Color deepNavy = Color(0xFF0B1120);

  // --- Getters ---
  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;
  String get videoPath => _videoPath;
  String get audioPath => _audioPath;

  AppProvider() {
    _loadSettings();
  }

  // 1. Load dari Shared Preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;

    // PERBAIKAN: Menggunakan toARGB32() untuk kompatibilitas Flutter terbaru
    _accentColor = Color(prefs.getInt('accentColor') ?? emerald.toARGB32());
    _videoPath = prefs.getString('videoPath') ?? _videoPath;
    _audioPath = prefs.getString('audioPath') ?? _audioPath;
    notifyListeners();
  }

  // 2. Ganti Tema (Light/Dark)
  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  // 3. Ganti Warna Aksen
  Future<void> changeAccent(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();

    // PERBAIKAN: Menggunakan toARGB32()
    await prefs.setInt('accentColor', color.toARGB32());
    notifyListeners();
  }

  // 4. Pilih Folder Penyimpanan
  Future<void> pickFolder({required bool isVideo}) async {
    String? path;

    try {
      // Kita panggil langsung fungsinya (kompatibel dengan versi terbaru file_picker)
      // Jika di VS Code masih ada garis merah, kamu bisa coba Restart VS Code kamu.
      path = await FilePicker.getDirectoryPath();
    } catch (e) {
      // Fallback jika API platform tidak terbaca
      debugPrint("Error mengambil folder: $e");
    }

    if (path != null) {
      final prefs = await SharedPreferences.getInstance();
      if (isVideo) {
        _videoPath = path;
        await prefs.setString('videoPath', path);
      } else {
        _audioPath = path;
        await prefs.setString('audioPath', path);
      }
      notifyListeners();
    }
  }
}
