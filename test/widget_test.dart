import 'package:flutter_test/flutter_test.dart';
import 'package:million_game/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const MillionApp());
    expect(find.text('من سيربح المليون'), findsWidgets);
  });
}
