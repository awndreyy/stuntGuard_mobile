class Balita {
  final String id;
  final String nama;
  final String? nik;
  final String tanggalLahir;
  final String jenisKelamin;
  final int jumlahPengukuran;

  const Balita({
    required this.id,
    required this.nama,
    required this.nik,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.jumlahPengukuran,
  });

  factory Balita.fromJson(Map<String, dynamic> json) => Balita(
    id: json['id_balita'].toString(),
    nama: json['nama_balita'].toString(),
    nik: json['nik']?.toString(),
    tanggalLahir: json['tanggal_lahir'].toString().substring(0, 10),
    jenisKelamin: json['jenis_kelamin'].toString(),
    jumlahPengukuran: (json['pengukurans_count'] as num?)?.toInt() ?? 0,
  );
}
