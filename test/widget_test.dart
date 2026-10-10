// Basic widget test for the StunGuard app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';

import 'package:stuntguardmobile/main.dart';

void main() {
  testWidgets('Welcome screen shows the main actions', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StunGuardApp());

    // The welcome screen should render the login and register buttons.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);
  });
}
