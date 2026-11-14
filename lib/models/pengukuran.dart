class Pengukuran {
  final String id;
  final String balitaId;
  final DateTime tanggal;
  final double beratBadan;
  final double tinggiBadan;
  final Map<String, dynamic>? hasil;

  const Pengukuran({
    required this.id,
    required this.balitaId,
    required this.tanggal,
    required this.beratBadan,
    required this.tinggiBadan,
    this.hasil,
  });

  factory Pengukuran.fromJson(Map<String, dynamic> json, {String? balitaId}) {
    final id = json['id'];
    final rawBalitaId = json['balita_id'] ?? balitaId;
    final rawTanggal = json['tanggal_pengukuran'];
    final rawBerat = json['berat_badan'];
    final rawTinggi = json['tinggi_badan'];
    final rawHasil = json['hasil'];

    if (id == null || rawBalitaId == null || rawTanggal is! String) {
      throw const FormatException('Data pengukuran dari server tidak valid.');
    }
    if (rawHasil != null && rawHasil is! Map) {
      throw const FormatException('Hasil pengukuran dari server tidak valid.');
    }

    final tanggal = DateTime.tryParse(rawTanggal);
    final berat = _parseDouble(rawBerat);
    final tinggi = _parseDouble(rawTinggi);
    if (tanggal == null || berat == null || tinggi == null) {
      throw const FormatException('Data pengukuran dari server tidak valid.');
    }

    return Pengukuran(
      id: id.toString(),
      balitaId: rawBalitaId.toString(),
      tanggal: tanggal,
      beratBadan: berat,
      tinggiBadan: tinggi,
      hasil: rawHasil == null ? null : Map<String, dynamic>.from(rawHasil),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final text = value.replaceAll(',', '.').trim();
      if (text.isEmpty) return null;
      return double.tryParse(text);
    }
    return null;
  }

  String get tanggalLabel {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${tanggal.day} ${monthNames[tanggal.month - 1]} ${tanggal.year}';
  }

  String get beratLabel => _formatNumber(beratBadan);
  String get tinggiLabel => _formatNumber(tinggiBadan);

  String _formatNumber(double value) {
    if (value == 0) return '-';

    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }
}
