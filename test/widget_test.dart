import 'package:flutter_test/flutter_test.dart';
import 'package:apotek_kita/main.dart';
import 'package:apotek_kita/splash_screen.dart';

void main() {
  testWidgets('SplashScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ApoteKitaApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
