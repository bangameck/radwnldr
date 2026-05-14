# 📋 Changelog - RaDwnldr Premium

Semua perubahan penting pada proyek ini akan didokumentasikan di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
dan proyek ini mengikuti [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v1.0.0] - 2026-05-15

### 🎉 Initial Release - RaDwnldr Premium (Android)

Rilis perdana aplikasi **RaDwnldr**, sebuah aplikasi pengunduh media premium dengan fitur *Smart Queue* dan pemrosesan native.

---

### ✨ Added (Fitur Baru)

#### 📱 Core Application & Premium UI
- **Inisialisasi proyek Flutter** dengan struktur berbasis `provider`.
- **Desain UI Premium:** Animasi *Skeleton Loading*, Video Banner yang *cinematic*, *Glassmorphism*, dan transisi transparan *System UI Bar*.
- **Mode Gelap & Terang:** Sistem tema dinamis *Deep Navy* menggunakan palet warna premium.

#### 🎥 YouTube Downloader Engine
- **Anti 403 Forbidden:** Implementasi `YoutubeApiClient.androidVr` dan `safari` untuk melakukan kompensasi dan pengelabuan terhadap tantangan JavaScript dari server YouTube (Bot Challenge).
- **Smart Manifest Refreshing:** Pengambilan *Stream URL* terbaru tepat sesaat sebelum diunduh untuk menghindari link yang basi / *expired* (menghindari error server timeout).
- **Format Pilihan Lengkap:** Kemampuan mendeteksi resolusi khusus Video Only (1080p, 2K, 4K), Audio Only (M4A/MP3), maupun *Muxed* langsung (MP4).

#### 🚀 Smart Queue Download Manager
- **Multi-Download List:** Daftar antrian dengan UI progres bar, tampilan thumbnail cerdas, serta tombol interaktif *"Buka Folder"*.
- **Native WakeLock (Kotlin):** Integrasi *MethodChannel* dengan `PowerManager.WakeLock` di Android untuk mencegah layar HP mematikan CPU saat aplikasi diminimalkan, sehingga FFmpeg dan unduhan jalan terus.
- **FFmpeg Muxing Kit:** Integrasi dengan `ffmpeg_kit_flutter_new` untuk menggabungkan file `.mkv` (cepat/copy codec) dan file `.mp4` (aman/re-encode).

#### 🔔 Notification & Permission
- **Storage Scoped Access:** Meminta akses tulis `WRITE_EXTERNAL_STORAGE` dan izin notifikasi secara elegan.
- **Awesome Notifications:** Progress pop-up bar interaktif langsung di *status bar* pengguna (mendukung *High Priority alert*).
- **Media Scanner Connection:** Memicu *Media Scanner* Android sehingga video dan audio langsung muncul di Galeri sistem tanpa perlu men- *restart* HP.

---

### 🛠️ Tech Stack (v1.0.0)

| Komponen | Teknologi |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Extractor | `youtube_explode_dart` |
| Video Processor | `ffmpeg_kit_flutter_new` |
| Permission | `permission_handler` |
| Download Task | Custom Stream Handler |
| Notifications | `awesome_notifications` |

---

### 🔗 Kompatibilitas

- **Android:** API Level 24+ (Android 7.0 Nougat ke atas) - Diperlukan untuk FFmpeg Kit
- **FFmpeg:** Menggunakan paket min-gpl-lts untuk kinerja maksimal di prosesor ARM64.

---

### 👨💻 Developer

**RadevankaProject** — [@bangameck](https://instagram.com/bangameck)
📍 Pekanbaru, Riau, Indonesia

---

*Changelog ini dibuat mengikuti standar [Keep a Changelog](https://keepachangelog.com/).*
