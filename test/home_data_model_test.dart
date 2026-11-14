import 'package:flutter_test/flutter_test.dart';
import 'package:stuntguardmobile/core/services/api_client.dart';
import 'package:stuntguardmobile/models/informasi.dart';
import 'package:stuntguardmobile/models/pengukuran.dart';

void main() {
  test('Pengukuran parses the Laravel API response without fake defaults', () {
    final measurement = Pengukuran.fromJson({
      'id': 42,
      'balita_id': 7,
      'tanggal_pengukuran': '2026-10-12T00:00:00.000000Z',
      'berat_badan': 9.25,
      'tinggi_badan': 78.5,
      'hasil': {
        'usia_bulan': 10,
        'z_score': -2.3,
        'status_stunting': 'Pendek (Stunted)',
      },
    });

    expect(measurement.id, '42');
    expect(measurement.balitaId, '7');
    expect(measurement.tanggalLabel, '12 Oktober 2026');
    expect(measurement.beratLabel, '9,25');
    expect(measurement.tinggiLabel, '78,5');
    expect(measurement.hasil?['z_score'], -2.3);
  });

  test('Pengukuran rejects incomplete API data', () {
    expect(
      () => Pengukuran.fromJson({'id': 42}),
      throwsA(isA<FormatException>()),
    );
  });

  test('Informasi parses article fields from the Laravel API', () {
    final article = Informasi.fromJson({
      'id_informasi': 12,
      'judul': 'Panduan nutrisi',
      'category': 'Gizi Anak',
      'summary': 'Ringkasan dari server.',
      'content': 'Isi artikel lengkap.',
      'thumbnail_url': '/storage/informasi/panduan.jpg',
      'created_at': '2026-11-14T10:00:00+07:00',
    });

    expect(article.id, '12');
    expect(article.judul, 'Panduan nutrisi');
    expect(article.kategori, 'Gizi Anak');
    expect(article.ringkasan, 'Ringkasan dari server.');
    expect(article.content, 'Isi artikel lengkap.');
    expect(article.thumbnailUrl, '/storage/informasi/panduan.jpg');
    expect(article.createdAt, DateTime.parse('2026-11-14T10:00:00+07:00'));
  });

  test('API asset paths resolve against the configured backend host', () {
    final articleUrl = ApiClient.resolveServerUri(
      '/storage/informasi/panduan.jpg',
    );
    final apiUrl = ApiClient.buildUri('informasi');

    expect(articleUrl.host, apiUrl.host);
    expect(articleUrl.port, apiUrl.port);
    expect(articleUrl.path, '/storage/informasi/panduan.jpg');
  });
}
