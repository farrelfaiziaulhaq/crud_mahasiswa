# CRUD Mahasiswa (Flutter + SQLite)

Aplikasi CRUD (Create, Read, Update, Delete) data mahasiswa sederhana menggunakan
Flutter dan SQLite (`sqflite`). Tidak ada halaman login — aplikasi langsung
membuka halaman daftar/form mahasiswa.

## Fitur

- Tambah data mahasiswa (NIM, Nama, Program Studi)
- Tampilkan daftar mahasiswa (urut terbaru)
- Edit data mahasiswa
- Hapus data dengan dialog konfirmasi
- Validasi form (semua kolom wajib diisi)
- NIM unik (`UNIQUE`), duplikat ditolak dengan pesan error
- Data tersimpan permanen (SQLite di Android/iOS/desktop, WebAssembly + IndexedDB di web)

## Struktur Proyek

```
lib/
├── main.dart
├── models/
│   └── mahasiswa.dart
├── database/
│   ├── database_helper.dart
│   ├── database_factory_stub.dart   # non-web
│   └── database_factory_web.dart    # web (sqlite3.wasm)
web/
└── sqlite3.wasm                     # dibutuhkan saat run di browser
```

## Cara Menjalankan

Kebutuhan: Flutter 3.x / Dart 3.x (`flutter --version`), dan device/emulator
untuk platform yang dipilih.

```bash
git clone <url-repo-anda>
cd crud_mahasiswa
flutter pub get
flutter run -d chrome      # web (paling ringan, tanpa emulator)
```

Untuk Android (butuh emulator/perangkat + USB debugging):

```bash
flutter run -d <DEVICE_ID>   # lihat daftar dengan: flutter devices
```

Untuk build:

```bash
flutter build web --release     # hasil: build/web
flutter build apk --debug       # hasil: build/app/outputs/flutter-apk/app-debug.apk
```

## Catatan Platform

`sqflite` hanya punya implementasi native untuk Android/iOS. Agar aplikasi juga
berjalan di browser, proyek ini menambahkan `sqflite_common_ffi_web`:

- `lib/database/database_factory_web.dart` mengeset
  `databaseFactory = databaseFactoryFfiWebNoWebWorker` saat platform web.
- `web/sqlite3.wasm` wajib ikut ter-commit; tanpa file ini database gagal
  dimuat di browser.

Karena memakai varian "NoWebWorker", tidak perlu membangun `sqflite_sw.js`.
Jika ingin varian web worker, jalankan `dart run sqflite_common_ffi_web:setup`
lalu pakai `databaseFactoryFfiWeb`.

Menjalankan di Windows/Linux/macOS desktop akan gagal (`MissingPluginException`)
karena `sqflite` tidak mendukung desktop tanpa `sqflite_common_ffi`.
Gunakan Chrome/Edge atau emulator/perangkat Android/iOS.

## Verifikasi

```bash
flutter analyze
flutter test
```
