import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeService {
  // Inisialisasi client
  final YoutubeExplode _yt = YoutubeExplode();

  /// 1. Fetch Metadata (Judul, Thumbnail, Durasi, Author)
  Future<Video> getVideoMetadata(String url) async {
    try {
      var video = await _yt.videos.get(url);
      return video;
    } catch (e) {
      throw Exception('Gagal mengambil data video. Pastikan link valid.');
    }
  }

  /// 2. Fetch Stream Manifest & Logic Filter
  /// Mengembalikan Map berisi kategori stream yang sudah dipisah
  Future<Map<String, List<dynamic>>> getStreamManifest(VideoId videoId) async {
    try {
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Muxed: Video + Audio gabung (Maksimal biasanya 720p)
      var muxedStreams = manifest.muxed.sortByVideoQuality().toList();

      // Adaptive / Video Only: Resolusi tinggi (1080p, 2K, 4K) TANPA AUDIO
      var videoOnlyStreams = manifest.videoOnly.sortByVideoQuality().toList();

      // Audio Only: Untuk MP3 / Muxing FFmpeg nanti
      var audioOnlyStreams = manifest.audioOnly.sortByBitrate().toList();

      return {
        'muxed': muxedStreams,
        'video_only': videoOnlyStreams,
        'audio_only': audioOnlyStreams,
      };
    } catch (e) {
      throw Exception('Gagal mengambil daftar resolusi.');
    }
  }

  /// Bersihkan memori saat service tidak dipakai
  void dispose() {
    _yt.close();
  }
}
