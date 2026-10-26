import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Implementasi untuk platform web (Chrome/Edge).
///
/// `sqflite` tidak punya implementasi native di browser, sehingga dipakai
/// SQLite versi WebAssembly. Varian "NoWebWorker" dipilih agar tidak perlu
/// membangun `sqflite_sw.js`; cukup `web/sqlite3.wasm` yang disediakan.
void initDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
