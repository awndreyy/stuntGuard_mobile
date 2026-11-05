class Mpasi {
  final String id;
  final String nama;
  final String kategoriUsia;
  final int waktuMenit;
  final int jumlahPorsi;
  final String? gambarUrl;
  final List<String> gizi;
  final List<String> bahan;
  final List<String> langkah;

  const Mpasi({
    required this.id,
    required this.nama,
    required this.kategoriUsia,
    required this.waktuMenit,
    required this.jumlahPorsi,
    required this.gambarUrl,
    required this.gizi,
    required this.bahan,
    required this.langkah,
  });

  String get usia => '${kategoriUsia.replaceAll('-', '–')} bulan';

  factory Mpasi.fromJson(Map<String, dynamic> json) {
    return Mpasi(
      id: json['id_resep'] as String,
      nama: json['nama_resep'] as String,
      kategoriUsia: json['kategori_usia'] as String,
      waktuMenit: _integer(json['waktu_memasak']),
      jumlahPorsi: _integer(json['porsi']),
      gambarUrl: json['gambar_url'] as String?,
      gizi: [
        _nutrition(json['kalori'], 'kkal'),
        _nutrition(json['karbohidrat'], 'g'),
        _nutrition(json['lemak'], 'g'),
        _nutrition(json['protein'], 'g'),
        _nutrition(json['zat_besi'], 'mg'),
        _nutrition(json['seng'], 'mg'),
      ],
      bahan: List<String>.from(json['bahan'] as List? ?? const []),
      langkah: List<String>.from(json['cara_pembuatan'] as List? ?? const []),
    );
  }

  static int _integer(Object? value) =>
      value is num ? value.toInt() : int.parse(value.toString());

  static String _nutrition(Object? value, String unit) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null || !number.isFinite) return '—';
    final text = number.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    return '${text.replaceAll('.', ',')} $unit';
  }
}

class MpasiPage {
  final List<Mpasi> recipes;
  final int total;
  final int? nextPage;

  const MpasiPage({
    required this.recipes,
    required this.total,
    required this.nextPage,
  });

  factory MpasiPage.fromJson(Map<String, dynamic> json) {
    final current = Mpasi._integer(json['current_page']);
    final last = Mpasi._integer(json['last_page']);
    return MpasiPage(
      recipes: (json['data'] as List)
          .map((item) => Mpasi.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      total: Mpasi._integer(json['total']),
      nextPage: current < last ? current + 1 : null,
    );
  }
}
