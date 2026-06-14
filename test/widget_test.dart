import 'package:flutter_test/flutter_test.dart';
import 'package:prime/main.dart';

void main() {
  testWidgets('App inicia sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());
    expect(find.text('Prime'), findsOneWidget);
  });
}