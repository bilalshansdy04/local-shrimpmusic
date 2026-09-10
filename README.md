# ShrimpMusic

Pemutar musik lokal yang ringan, cepat, dan offline-first untuk Windows.

Tanpa login. Tanpa iklan. Tanpa upload. Buka aplikasi, pilih folder musik, langsung putar.

## Download

**Windows 64-bit — v1.0.0 (rilis awal):**

[Download ShrimpMusic](https://github.com/bilalshansdy04/local-shrimpmusic/releases/latest)

> File bernama `ShrimpMusic-v1.0.0-windows-x64.zip` di halaman Releases. Jika link di atas membuka daftar rilis, pilih file ZIP paling baru.

### Cara install (3 langkah)

1. Download file ZIP dari link di atas.
2. Klik kanan file ZIP > **Extract All**, simpan di folder bebas, misal `Documents`.
3. Buka folder hasil extract, jalankan `ShrimpMusic.exe`. Tidak perlu admin, tidak perlu installer.

## Kenapa ShrimpMusic

- **Ringan:** fokus satu tugas, putar koleksi lokal dengan cepat.
- **Offline-first:** semua fitur inti jalan tanpa internet.
- **Privasi terjaga:** file musik tetap di perangkat kamu.
- **Mudah:** tambah folder sumber sekali, cari lagu instan.

## Fitur

- Scan folder musik lokal (MP3, FLAC, WAV, M4A).
- Baca metadata Title, Artist, Album, dan cover art dari file.
- Pencarian lagu cepat.
- Playlist lokal dan lagu favorit (Liked Songs).
- Lirik `.lrc` lokal dari folder yang sama dengan lagu.
- Fallback lirik online otomatis via lrclib.net bila `.lrc` tidak ada.
- Pengaturan folder sumber musik dari halaman Settings.
- Halaman Tentang Aplikasi: versi, changelog, Terms, Privacy, Open Source Licenses.

## Cara pakai

1. Buka ShrimpMusic.
2. Masuk ke **Settings > Music Library > Add a source**, pilih folder musik kamu.
3. Kembali ke library, cari dan putar lagu.
4. Cek versi dan pembaruan di **Settings > Tentang Aplikasi**.

## Build dari source

Butuh [Flutter](https://docs.flutter.dev/get-started/install) 3.x.

```powershell
flutter pub get
flutter build windows --release
```

Hasil build ada di `build\windows\x64\runner\Release\`.

## Versi

Format: `MAJOR.MINOR.PATCH`

- `MAJOR` naik saat perubahan besar tidak kompatibel mundur.
- `MINOR` naik saat tambah fitur baru yang tetap kompatibel.
- `PATCH` naik saat perbaikan bug kecil.

Versi saat ini: `1.0.0` (lihat `pubspec.yaml`).

## Changelog

### v1.0.0

- Rilis awal pemutar musik lokal.
- Putar musik lokal, cari lagu, atur folder sumber.
- Halaman Tentang Aplikasi: versi, check updates, changelog, legal.

## Legal

- [Terms of Service](TERMS_OF_SERVICE.md)
- Kebijakan Privasi dan Terms lengkap menyusul sebelum rilis stabil berikutnya.
- Lisensi open source dependensi: buka aplikasi > **Settings > Tentang Aplikasi > Open Source Licenses**.

## FAQ

**Apakah butuh internet?**
Tidak untuk fitur inti. Internet hanya dipakai untuk fallback lirik dan cek pembaruan.

**Windows SmartScreen muncul peringatan, aman?**
Wajar untuk aplikasi baru tanpa sertifikat EV. Klik **More info > Run anyway** bila file diunduh dari halaman Releases resmi repo ini.

**Aplikasi 32-bit tersedia?**
Belum. Rilis awal hanya Windows 64-bit.

**Data saya dikirim ke mana?**
Tidak ke mana-mana. Koleksi musik dan pengaturan tersimpan lokal di perangkat.
