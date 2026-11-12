class Informasi {
  final String id;
  final String judul;
  final String kategori;
  final String ringkasan;

  const Informasi({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.ringkasan,
  });

  factory Informasi.fromJson(Map<String, dynamic> json) {
    final id = json['id_informasi'];
    final judul = json['judul'];
    final kategori = json['category'];
    final ringkasan = json['summary'];

    if (id == null ||
        judul is! String ||
        kategori is! String ||
        ringkasan is! String) {
      throw const FormatException('Data artikel dari server tidak valid.');
    }

    return Informasi(
      id: id.toString(),
      judul: judul,
      kategori: kategori,
      ringkasan: ringkasan,
    );
  }
}
