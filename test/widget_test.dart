import 'package:flutter_test/flutter_test.dart';
import 'package:snake_game/main.dart';

void main() {
  testWidgets('Snake game app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SnakeGameApp());
    expect(find.text('SNAKE'), findsOneWidget);
  });
}
