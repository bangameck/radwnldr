# 📋 Changelog - RaDwnldr Premium

Semua perubahan penting pada proyek ini akan didokumentasikan di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
dan proyek ini mengikuti [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v1.2.0] - 2026-05-18

### ✨ Added (Fitur Baru)
- **TikTok Downloader Engine:** Integrasi dengan API publik TikWM untuk mengunduh video TikTok tanpa *watermark* (HD/SD), ekstrak Audio murni (MP3), dan ekstrak postingan foto geser (*Slide/Carousel*).
- **Slide to Video Muxing (Magic Feature):** Kemampuan mengubah postingan foto slide TikTok menjadi video utuh (MP4) secara *offline* menggunakan mesin FFmpeg. Sistem akan me-*loop* gambar agar pas dengan durasi lagu bawaan.
- **Custom Cover Selection:** *Bottom Sheet* interaktif yang menampilkan *grid* foto slide, mengizinkan pengguna memilih gambar spesifik mana yang akan dijadikan *cover* untuk konversi ke video MP4.
- **Universal Download Manager:** Refaktor arsitektur antrian (`QueueProvider`) dan `DownloadService` agar cerdas membedakan metode unduhan: protokol YouTubeExplode untuk YouTube, dan *Direct HTTP Download* untuk TikTok/Instagram.
- **Smart File Naming:** Implementasi format penamaan file otomatis yang profesional dan anti-tertimpa (Anti-Overwrite): `[Prefix]_[Username]_[YYYYMMDDHHMMSS].[ext]`.
- **Bulk Clean History:** Tombol sapu bersih ("Bersihkan") pada UI antrian untuk menghapus masal semua tugas yang berstatus *Success* atau *Error* dalam satu klik.
- **Social Media Directory:** Menambahkan opsi pemilihan direktori khusus *Social Folder* di halaman *Preferences* (Default: `Pictures/RaDwnldr`) untuk memisahkan hasil unduhan TikTok/IG dengan YouTube.
- **Credits Section:** Penambahan area *Special Thanks & Credits* di panel *About* untuk menghargai komunitas *open-source* (`youtube_explode_dart`, `ffmpeg_kit`) dan penyedia API (`TikWM`).

### 🐛 Fixed & Optimized (Perbaikan Bug & Optimasi)
- **FFmpeg Odd Pixel Crash:** Menyembuhkan *error* fatal (`[libx264] height not divisible by 2`) saat me-render gambar dari TikTok beresolusi ganjil dengan menyisipkan filter *scale* otomatis: `-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2"`.
- **Dynamic Queue Thumbnail:** *Thumbnail* pada *list* antrian kini secara dinamis menampilkan foto spesifik yang diklik oleh pengguna saat mengunduh postingan slide, bukan sekadar *cover* utama video.

---

## [v1.1.0] - 2026-05-17

### ✨ Added (Fitur Baru)
- **YouTube Search Integration:** Menambahkan kemampuan pencarian video langsung di dalam aplikasi menggunakan kata kunci (menggunakan API bawaan `youtube_explode_dart`), tanpa harus *paste* link.
- **Interactive Search UI:** Antarmuka pencarian baru yang menampilkan daftar hasil (*Search Results*) lengkap dengan *thumbnail*, judul, nama *author*, dan durasi video yang siap diklik.

### 🐛 Fixed & Optimized (Perbaikan Bug & Optimasi)
- **Native SAF Folder Navigation:** Memperbaiki *bug* di mana tombol "Lihat Folder" selalu membuka folder `Downloads`. Mengimplementasikan format URI Android 11+ Scoped Storage (`content://...%3A...`) di Kotlin dengan sistem *fallback* bertingkat.
- **Release Mode Crash (JNI):** Menyembuhkan *Force Close* (Signal 11 SIGSEGV `null pointer dereference`) saat aplikasi dibuka di mode *Release* dengan mematikan pengacak kode R8 (`isMinifyEnabled = false`) yang sebelumnya menghancurkan *class bridge* FFmpeg dan Dart JNI.
- **OOM RAM Optimization:** Menambahkan `android:largeHeap="true"` di *Manifest* untuk memaksa sistem memberikan jatah RAM ekstra, mencegah *crash* saat mengekstrak Native Library C++ FFmpeg di HP *entry-level* (seperti Infinix/MediaTek).
- **Awesome Notifications Release Fix:** Memperbaiki *crash* notifikasi di mode Release dengan mengubah inisialisasi ikon *default* dari `null` menjadi referensi statis `'resource://mipmap/ic_launcher'`.

---

## [v1.0.0] - 2026-05-15

### 🎉 Initial Release - RaDwnldr Premium (Android)

Rilis perdana aplikasi **RaDwnldr**, sebuah aplikasi pengunduh media premium dengan fitur *Smart Queue* dan pemrosesan native.

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

### 🛠️ Tech Stack

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