import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/main.dart';

void main() {
  testWidgets('TravelOutdoorApp smoke test and navigation verification', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelOutdoorApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify app starts and displays the Explore screen title
    expect(find.text('Khám Phá Địa Điểm Dã Ngoại'), findsOneWidget);

    // Verify bottom navigation bar has all 5 sections
    expect(find.text('Khám phá'), findsOneWidget);
    expect(find.text('Bản đồ'), findsOneWidget);
    expect(find.text('Lịch trình'), findsOneWidget);
    expect(find.text('Cẩm nang'), findsOneWidget);
    expect(find.text('SOS / An toàn'), findsOneWidget);

    // Tap on 'SOS / An toàn'
    await tester.tap(find.text('SOS / An toàn'));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify SOS screen is displayed
    expect(find.text('BẤM ĐỂ KÍCH HOẠT SOS'), findsOneWidget);

    // Tap on 'Cẩm nang'
    await tester.tap(find.text('Cẩm nang'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Cẩm Nang Sinh Tồn (Offline 100%)'), findsOneWidget);

    // Tap on 'Lịch trình'
    await tester.tap(find.text('Lịch trình'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Lập Kế Hoạch Chuyến Đi (Planner)'), findsOneWidget);
  });
}
