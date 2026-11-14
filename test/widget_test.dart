// Basic widget test for the StunGuard app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stuntguardmobile/main.dart';
import 'package:stuntguardmobile/models/balita.dart';
import 'package:stuntguardmobile/models/informasi.dart';
import 'package:stuntguardmobile/models/pengukuran.dart';
import 'package:stuntguardmobile/screens/education/education_screen.dart';
import 'package:stuntguardmobile/screens/home/home_screen.dart';
import 'package:stuntguardmobile/services/balita_service.dart';
import 'package:stuntguardmobile/services/informasi_service.dart';
import 'package:stuntguardmobile/services/pengukuran_service.dart';

class _FakeBalitaService extends BalitaService {
  @override
  Future<List<Balita>> fetchChildren() async {
    return const [
      Balita(
        id: '1',
        nama: 'Danendra',
        nik: null,
        tanggalLahir: '2025-01-01',
        jenisKelamin: 'Laki-laki',
        jumlahPengukuran: 2,
      ),
      Balita(
        id: '2',
        nama: 'Aluna',
        nik: null,
        tanggalLahir: '2025-04-01',
        jenisKelamin: 'Perempuan',
        jumlahPengukuran: 1,
      ),
    ];
  }
}

class _RefreshableBalitaService extends BalitaService {
  int fetchCount = 0;

  @override
  Future<List<Balita>> fetchChildren() async {
    fetchCount++;
    if (fetchCount == 1) return const [];

    return const [
      Balita(
        id: '3',
        nama: 'Bayi Baru',
        nik: null,
        tanggalLahir: '2026-01-01',
        jenisKelamin: 'Laki-laki',
        jumlahPengukuran: 0,
      ),
    ];
  }
}

class _FakePengukuranService extends PengukuranService {
  @override
  Future<List<Pengukuran>> fetchByChild(String childId) async {
    if (childId == '1') {
      return [
        Pengukuran(
          id: 'm1',
          balitaId: '1',
          tanggal: DateTime(2026, 9, 12),
          beratBadan: 9.8,
          tinggiBadan: 78,
          hasil: const {
            'jenis_kelamin': 'Laki-laki',
            'usia_bulan': 20,
            'berat': 9.8,
            'tinggi': 78,
            'posisi_badan': 'terlentang',
            'z_score': -2.4,
            'status_stunting': 'Pendek (Stunted)',
            'indikator_tinggi': 'PB/U',
            'indikator_berat_tinggi': 'BB/PB',
            'z_bbu': -1.0,
            'z_bb_tb': 0.2,
          },
        ),
        Pengukuran(
          id: 'm2',
          balitaId: '1',
          tanggal: DateTime(2026, 8, 12),
          beratBadan: 9.5,
          tinggiBadan: 77,
        ),
      ];
    }
    if (childId == '2') {
      return [
        Pengukuran(
          id: 'm3',
          balitaId: '2',
          tanggal: DateTime(2026, 7, 12),
          beratBadan: 7.4,
          tinggiBadan: 67,
        ),
      ];
    }
    return const [];
  }
}

class _FakeInformasiService extends InformasiService {
  static const article = Informasi(
    id: '1',
    judul: 'Artikel dari server',
    kategori: 'Tumbuh Kembang',
    ringkasan: 'Ringkasan artikel dari server.',
    content: 'Isi lengkap artikel dari server.',
  );

  @override
  Future<List<Informasi>> fetchArticles() async => const [article];

  @override
  Future<Informasi> fetchArticle(String id) async => article;
}

void main() {
  testWidgets('Splash screen displays the app branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StunGuardApp());

    expect(find.text('StunGuard'), findsOneWidget);
    expect(find.text('Pantau Tumbuh Kembang Si Kecil'), findsOneWidget);
  });

  testWidgets('Home screen loads real child and measurement data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            user: {'name': 'Ibu'},
            onOpenCalculator: () {},
            balitaService: _FakeBalitaService(),
            informasiService: _FakeInformasiService(),
            pengukuranService: _FakePengukuranService(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Danendra'), findsOneWidget);
    expect(find.text('Artikel dari server'), findsOneWidget);
    expect(find.text('Ringkasan artikel dari server.'), findsOneWidget);
    expect(find.text('Kalkulator gizi'), findsOneWidget);
    expect(find.text('Resep MPASI'), findsOneWidget);
  });

  testWidgets('Education screen loads API articles and opens article detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EducationScreen(
            isActive: true,
            informationService: _FakeInformasiService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Artikel dari server'), findsOneWidget);
    expect(find.text('Tumbuh Kembang'), findsOneWidget);

    await tester.tap(find.text('Artikel dari server'));
    await tester.pumpAndSettle();

    expect(find.text('Artikel Edukasi'), findsOneWidget);
    expect(find.text('Isi lengkap artikel dari server.'), findsOneWidget);
  });

  testWidgets('Growth chart shows dated details and switches metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            onOpenCalculator: () {},
            balitaService: _FakeBalitaService(),
            informasiService: _FakeInformasiService(),
            pengukuranService: _FakePengukuranService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Grafik pertumbuhan'), 400);
    await tester.pumpAndSettle();

    expect(find.text('12 Agustus 2026 - 12 September 2026'), findsOneWidget);
    expect(find.text('Berat: 9,5 kg'), findsOneWidget);
    expect(find.text('Tinggi: 77 cm'), findsOneWidget);
    expect(
      find.text('Perubahan dari pengukuran sebelumnya: +0,3 kg • +1 cm'),
      findsOneWidget,
    );

    await tester.tap(find.text('Tinggi (cm)'));
    await tester.pumpAndSettle();

    expect(find.text('Sumbu vertikal: Tinggi badan (cm)'), findsOneWidget);
  });

  testWidgets('Tapping a measurement opens its saved WHO result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            onOpenCalculator: () {},
            balitaService: _FakeBalitaService(),
            informasiService: _FakeInformasiService(),
            pengukuranService: _FakePengukuranService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final historyItem = find.byKey(const ValueKey('measurement-history-m1'));
    await tester.ensureVisible(historyItem);
    await tester.pumpAndSettle();
    await tester.tap(historyItem);
    await tester.pumpAndSettle();

    expect(find.text('Detail Pengukuran'), findsOneWidget);
    expect(find.text('Hasil perhitungan WHO'), findsOneWidget);
    expect(find.text('Pendek (Stunted)'), findsOneWidget);
  });

  testWidgets('Home screen refreshes children when its tab becomes active', (
    WidgetTester tester,
  ) async {
    final service = _RefreshableBalitaService();
    var isHomeActive = true;
    late StateSetter updateParent;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateParent = setState;
              return HomeScreen(
                isActive: isHomeActive,
                onOpenCalculator: () {},
                balitaService: service,
                informasiService: _FakeInformasiService(),
                pengukuranService: _FakePengukuranService(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(service.fetchCount, 1);
    expect(find.text('Bayi Baru'), findsNothing);

    updateParent(() => isHomeActive = false);
    await tester.pumpAndSettle();
    updateParent(() => isHomeActive = true);
    await tester.pumpAndSettle();

    expect(service.fetchCount, 2);
    expect(find.text('Bayi Baru'), findsOneWidget);
  });
}
