import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stuntguardmobile/widgets/who_result_card.dart';

void main() {
  testWidgets(
    'shows all WHO indicators from the registered calculation result',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                WhoResultCard(
                  result: {
                    'jenis_kelamin': 'Laki-laki',
                    'usia_bulan': 13,
                    'berat': 9.8,
                    'tinggi': 78.0,
                    'tinggi_koreksi': 78.0,
                    'posisi_badan': 'terlentang',
                    'indikator_tinggi': 'PB/U',
                    'indikator_berat_tinggi': 'BB/PB',
                    'z_bbu': -0.07,
                    'z_score': 0.45,
                    'z_bb_tb': -0.34,
                    'z_lku': null,
                    'z_lilau': null,
                    'status_stunting': 'Normal',
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jenis kelamin'), findsOneWidget);
      expect(find.text('BB/U'), findsOneWidget);
      expect(find.text('PB/U'), findsOneWidget);
      expect(find.text('BB/PB'), findsOneWidget);
      expect(find.text('LK/U'), findsOneWidget);
      expect(find.text('LiLA/U'), findsOneWidget);
      expect(find.text('0,45 SD'), findsWidgets);
      expect(find.text('Tidak tersedia / di luar rentang'), findsNWidgets(2));
      expect(find.text('Normal'), findsOneWidget);
    },
  );

  testWidgets('reads the website response shape when indicators are nested', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: const [
              WhoResultCard(
                result: {
                  'jenis_kelamin_label': 'Laki-laki',
                  'usia_bulan': 13,
                  'berat': 9.8,
                  'tinggi_input': 78,
                  'posisi_badan_label': 'Terlentang',
                  'indikator_tinggi': 'PB/U',
                  'indikator_proporsi': 'BB/PB',
                  'bbu': {'z_score': -0.07},
                  'pbu': {'z_score': 0.45, 'status': 'Normal'},
                  'bbpb': {'z_score': -0.34},
                  'lku': {'z_score': null},
                  'lilau': {'z_score': null},
                  'ringkasan': 'Normal',
                  'panjang_tinggi_terkoreksi': 78,
                },
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0,45 SD'), findsWidgets);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Panjang/tinggi terkoreksi: 78 cm'), findsOneWidget);
  });
}
