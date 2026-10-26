// Smoke test untuk aplikasi CRUD Mahasiswa.
//
// Catatan: sqflite tidak tersedia di lingkungan unit test (tidak ada
// plugin native), sehingga pemuatan data awal akan gagal dan tertangkap
// oleh blok try/catch di _loadData. Test di bawah hanya memverifikasi
// bahwa UI utama tampil dan validasi form berjalan.

import 'package:flutter_test/flutter_test.dart';

import 'package:crud_mahasiswa/main.dart';

void main() {
  testWidgets('Halaman CRUD tampil dan validasi form berjalan',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Frame pertama + beri waktu SnackBar error plugin selesai.
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Judul dan elemen form utama harus ada.
    expect(find.text('CRUD Data Mahasiswa'), findsOneWidget);
    expect(find.text('Tambah Mahasiswa'), findsOneWidget);
    expect(find.text('NIM'), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Program Studi'), findsOneWidget);
    expect(find.text('Simpan Data'), findsOneWidget);

    // Tekan Simpan tanpa mengisi apa pun -> validasi harus muncul.
    await tester.tap(find.text('Simpan Data'));
    await tester.pump();

    expect(find.text('NIM wajib diisi'), findsOneWidget);
    expect(find.text('Nama wajib diisi'), findsOneWidget);
    expect(find.text('Prodi wajib diisi'), findsOneWidget);
  });
}
