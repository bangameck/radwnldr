import 'dart:convert';
import 'package:http/http.dart' as http;

// ==========================================
// MODEL DATA TIKTOK
// ==========================================
class TiktokData {
  final String title;
  final String author;
  final String thumbnail;
  final String? videoUrl;
  final String? hdVideoUrl;
  final String musicUrl;
  final List<String>? images;

  TiktokData({
    required this.title,
    required this.author,
    required this.thumbnail,
    this.videoUrl,
    this.hdVideoUrl,
    required this.musicUrl,
    this.images,
  });

  factory TiktokData.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    // Parsing list gambar jika postingan berupa Slide Foto
    List<String>? parsedImages;
    if (data['images'] != null) {
      parsedImages = List<String>.from(data['images']);
    }

    return TiktokData(
      title: data['title'] ?? 'Video TikTok',
      author: data['author']['nickname'] ?? 'Unknown User',
      thumbnail: data['cover'] ?? '',
      videoUrl: data['play'], // Video SD (No Watermark)
      hdVideoUrl: data['hdplay'], // Video HD (No Watermark)
      musicUrl: data['music'] ?? '', // Original Audio MP3
      images: parsedImages, // List URL gambar jika ada
    );
  }
}

// ==========================================
// SERVICE API TIKTOK
// ==========================================
class TiktokService {
  Future<TiktokData> getTiktokData(String url) async {
    try {
      // Menembak Public API TikWM secara aman
      final response = await http.post(
        Uri.parse('https://www.tikwm.com/api/'),
        body: {
          'url': url,
          'hd': '1', // Request versi High Definition
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 0) {
          return TiktokData.fromJson(jsonResponse);
        } else {
          throw Exception(
            jsonResponse['msg'] ?? 'Gagal memproses link TikTok.',
          );
        }
      } else {
        throw Exception('Server Error: Gangguan pada API TikTok.');
      }
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan: Pastikan link valid dan koneksi internet stabil.',
      );
    }
  }
}
