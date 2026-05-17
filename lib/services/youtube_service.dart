import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeService {
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
  Future<Map<String, List<dynamic>>> getStreamManifest(VideoId videoId) async {
    try {
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);
      var muxedStreams = manifest.muxed.sortByVideoQuality().toList();
      var videoOnlyStreams = manifest.videoOnly.sortByVideoQuality().toList();
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

  /// 3. SEARCH VIDEO (FITUR BARU v1.2.0)
  /// Mengembalikan list video hasil pencarian berdasarkan kata kunci
  Future<List<Video>> searchVideos(String query) async {
    try {
      // Ambil 15 hasil pencarian teratas
      var searchList = await _yt.search.search(query);
      return searchList.take(15).toList();
    } catch (e) {
      throw Exception('Gagal mencari video. Periksa koneksi internet Anda.');
    }
  }

  /// Bersihkan memori saat service tidak dipakai
  void dispose() {
    _yt.close();
  }
}
