// This is a basic Flutter widget test for Playas RD app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:playas_rd_flutter/main.dart';

void main() {
  testWidgets('Playas RD app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlayasRDApp());

    // Verify that the app title is present.
    expect(find.text('Playas RD'), findsOneWidget);

    // Verify that the bottom navigation bar is present.
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Reportar'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
