class Mahasiswa {
  final int? id;
  final String nim;
  final String nama;
  final String prodi;

  Mahasiswa({
    this.id,
    required this.nim,
    required this.nama,
    required this.prodi,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nim': nim,
      'nama': nama,
      'prodi': prodi,
    };
  }

  factory Mahasiswa.fromMap(Map<String, Object?> map) {
    return Mahasiswa(
      id: map['id'] as int?, // ✅ FIX: nullable
      nim: map['nim'] as String,
      nama: map['nama'] as String,
      prodi: map['prodi'] as String,
    );
  }
}
