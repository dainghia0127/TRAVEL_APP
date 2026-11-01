import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/main.dart';

void main() {
  testWidgets('TravelOutdoorApp navigation verification and smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelOutdoorApp());
    await tester.pump(const Duration(milliseconds: 200));

    // Verify app starts and displays the Explore screen title
    expect(find.text('Khám Phá & Dã Ngoại'), findsOneWidget);

    // Verify bottom navigation bar has all 5 sections
    expect(find.text('Khám phá'), findsOneWidget);
    expect(find.text('Bản đồ'), findsOneWidget);
    expect(find.text('Lịch trình'), findsOneWidget);
    expect(find.text('Cẩm nang'), findsOneWidget);
    expect(find.text('SOS Cứu hộ'), findsOneWidget);

    // Tap on 'SOS Cứu hộ'
    await tester.tap(find.text('SOS Cứu hộ'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Cứu Hộ & SOS'), findsOneWidget);

    // Tap on 'Cẩm nang'
    await tester.tap(find.text('Cẩm nang'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Cẩm Nang Sinh Tồn'), findsOneWidget);

    // Tap on 'Lịch trình'
    await tester.tap(find.text('Lịch trình'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Kế Hoạch Khám Phá'), findsOneWidget);

    // Tap back to 'Khám phá'
    await tester.tap(find.text('Khám phá'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Khám Phá & Dã Ngoại'), findsOneWidget);
  });
}
