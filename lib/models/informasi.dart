class Informasi {
  final String id;
  final String judul;
  final String kategori;
  final String ringkasan;
  final String? content;
  final String? thumbnailUrl;
  final DateTime? createdAt;

  const Informasi({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.ringkasan,
    this.content,
    this.thumbnailUrl,
    this.createdAt,
  });

  factory Informasi.fromJson(Map<String, dynamic> json) {
    final id = json['id_informasi'];
    final judul = json['judul'];
    final kategori = json['category'];
    final ringkasan = json['summary'];
    final content = json['content'];
    final thumbnailUrl = json['thumbnail_url'];
    final createdAt = json['created_at'];

    if (id == null ||
        judul is! String ||
        kategori is! String ||
        ringkasan is! String ||
        (content != null && content is! String) ||
        (thumbnailUrl != null && thumbnailUrl is! String) ||
        (createdAt != null && createdAt is! String)) {
      throw const FormatException('Data artikel dari server tidak valid.');
    }

    final parsedCreatedAt = createdAt == null
        ? null
        : DateTime.tryParse(createdAt);
    if (createdAt != null && parsedCreatedAt == null) {
      throw const FormatException('Tanggal artikel dari server tidak valid.');
    }

    return Informasi(
      id: id.toString(),
      judul: judul,
      kategori: kategori,
      ringkasan: ringkasan,
      content: content as String?,
      thumbnailUrl: thumbnailUrl as String?,
      createdAt: parsedCreatedAt,
    );
  }
}
