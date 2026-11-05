import 'package:flutter_test/flutter_test.dart';
import 'package:stuntguardmobile/models/mpasi.dart';

void main() {
  Map<String, dynamic> recipeJson() => {
    'id_resep': 'RSP-2601-00001-K8Q4',
    'nama_resep': 'Bubur Ayam Wortel',
    'kategori_usia': '6-8',
    'waktu_memasak': 25,
    'porsi': 2,
    'gambar_url': null,
    'kalori': '185.25',
    'karbohidrat': '22.00',
    'lemak': 0,
    'protein': 9,
    'zat_besi': '1.80',
    'seng': '1.20',
    'bahan': ['Beras 50 g'],
    'cara_pembuatan': ['Masak hingga matang'],
  };

  test('Reads custom string ID, decimals, arrays, and missing photo', () {
    final recipe = Mpasi.fromJson(recipeJson());

    expect(recipe.id, 'RSP-2601-00001-K8Q4');
    expect(recipe.usia, '6–8 bulan');
    expect(recipe.gizi, [
      '185,25 kkal',
      '22 g',
      '0 g',
      '9 g',
      '1,8 mg',
      '1,2 mg',
    ]);
    expect(recipe.gambarUrl, isNull);
    expect(recipe.bahan, ['Beras 50 g']);
    expect(recipe.langkah, ['Masak hingga matang']);
  });

  test('Uses page numbers rather than server pagination URLs', () {
    final page = MpasiPage.fromJson({
      'data': [recipeJson()],
      'current_page': 1,
      'last_page': 2,
      'total': 13,
      'next_page_url': 'http://localhost/api/mpasi?page=2',
    });

    expect(page.recipes, hasLength(1));
    expect(page.total, 13);
    expect(page.nextPage, 2);
  });

  test('Empty final page has no next page', () {
    final page = MpasiPage.fromJson({
      'data': [],
      'current_page': 1,
      'last_page': 1,
      'total': 0,
    });

    expect(page.recipes, isEmpty);
    expect(page.nextPage, isNull);
  });
}
