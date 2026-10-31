// Basic widget test for the StunGuard app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stuntguardmobile/main.dart';
import 'package:stuntguardmobile/screens/home/home_screen.dart';

void main() {
  testWidgets('Welcome screen shows the main actions', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StunGuardApp());

    // The welcome screen should render the login and register buttons.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);
  });

  testWidgets('Home screen displays demo data and switches active child', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomeScreen(onOpenCalculator: () {})),
      ),
    );

    expect(find.text('Danendra (14 Bulan)'), findsOneWidget);
    expect(find.text('Gizi Normal'), findsOneWidget);
    expect(find.text('Cek Gizi WHO'), findsOneWidget);
    expect(find.text('Resep MPASI'), findsOneWidget);

    await tester.tap(find.byTooltip('Pilih anak'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aluna (8 Bulan)').last);
    await tester.pumpAndSettle();

    expect(find.text('Aluna (8 Bulan)'), findsOneWidget);
  });
}
