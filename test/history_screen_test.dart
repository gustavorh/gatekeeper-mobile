import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/history_screen.dart';

void main() {
  group('HistoryScreen', () {
    testWidgets('should display header with title and back button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HistoryScreen(onBack: () {})));

      // Should show header immediately
      expect(find.text('Historial de Turnos'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should call onBack when back button is tapped', (
      WidgetTester tester,
    ) async {
      bool backCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: HistoryScreen(
            onBack: () {
              backCalled = true;
            },
          ),
        ),
      );

      // Tap the back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Should have called onBack
      expect(backCalled, isTrue);
    });

    testWidgets('should show loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HistoryScreen(onBack: () {})));

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
