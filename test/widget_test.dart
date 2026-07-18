import 'package:flutter_test/flutter_test.dart';
import 'package:echo_memory/app.dart';

void main() {
  group('EchoMemoryApp', () {
    testWidgets('app should start without errors', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const EchoMemoryApp());

      await tester.pumpAndSettle();

      // Verify the app title is displayed somewhere
      expect(find.textContaining('Echo'), findsWidgets);
    });

    testWidgets('home screen should display game modes', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const EchoMemoryApp());

      // Complete animations
      await tester.pumpAndSettle();

      // Verify key game modes are visible
      expect(find.text('Start Classic Echo'), findsOneWidget);
      expect(find.text('Lumina Matrix'), findsOneWidget);
    });
  });
}
