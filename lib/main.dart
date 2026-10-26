import 'package:flutter/material.dart';

import 'database/database_factory_stub.dart'
    if (dart.library.js_interop) 'database/database_factory_web.dart';
import 'database/database_helper.dart';
import 'models/mahasiswa.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDatabaseFactory();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Mahasiswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MahasiswaPage(),
    );
  }
}

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  final _formKey = GlobalKey<FormState>();

  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _prodiController = TextEditingController();

  final _db = DatabaseHelper.instance;

  List<Mahasiswa> _data = [];
  int? _editingId;
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final hasil = await _db.getMahasiswa();
      if (!mounted) return;
      setState(() => _data = hasil);
    } catch (e) {
      _showMessage('Gagal memuat data: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearForm() {
    _nimController.clear();
    _namaController.clear();
    _prodiController.clear();
    setState(() => _editingId = null);
  }

  void _editData(Mahasiswa mahasiswa) {
    setState(() {
      _editingId = mahasiswa.id;
      _nimController.text = mahasiswa.nim;
      _namaController.text = mahasiswa.nama;
      _prodiController.text = mahasiswa.prodi;
    });
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final mahasiswa = Mahasiswa(
        id: _editingId,
        nim: _nimController.text.trim(),
        nama: _namaController.text.trim(),
        prodi: _prodiController.text.trim(),
      );

      final isEdit = _editingId != null;

      if (isEdit) {
        await _db.updateMahasiswa(mahasiswa);
      } else {
        await _db.insertMahasiswa(mahasiswa);
      }

      if (!mounted) return;

      _clearForm();
      await _loadData();

      _showMessage(
        isEdit ? 'Data berhasil diperbarui' : 'Data berhasil ditambahkan',
      );
    } catch (e) {
      _showMessage(
        'Gagal menyimpan data. Periksa apakah NIM sudah digunakan. $e',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _hapusData(Mahasiswa mahasiswa) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mahasiswa'),
        content: Text('Yakin ingin menghapus ${mahasiswa.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    try {
      await _db.deleteMahasiswa(mahasiswa.id!);

      if (_editingId == mahasiswa.id) {
        _clearForm();
      }

      await _loadData();
      _showMessage('Data berhasil dihapus');
    } catch (e) {
      _showMessage('Gagal menghapus: $e');
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _prodiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Data Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _editingId == null
                            ? 'Tambah Mahasiswa'
                            : 'Edit Mahasiswa',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nimController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'NIM',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'NIM wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _prodiController,
                        decoration: const InputDecoration(
                          labelText: 'Program Studi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Prodi wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saving ? null : _simpanData,
                        icon: const Icon(Icons.save),
                        label: Text(
                          _saving
                              ? 'Menyimpan...'
                              : _editingId == null
                                  ? 'Simpan Data'
                                  : 'Simpan Perubahan',
                        ),
                      ),
                      if (_editingId != null)
                        TextButton(
                          onPressed: _saving ? null : _clearForm,
                          child: const Text('Batal Edit'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Daftar Mahasiswa (${_data.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_data.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Belum ada data mahasiswa')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final mahasiswa = _data[index];

                  return Card(
                    child: ListTile(
                      title: Text(mahasiswa.nama),
                      subtitle: Text(
                        '${mahasiswa.nim}\n${mahasiswa.prodi}',
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editData(mahasiswa),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusData(mahasiswa),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
