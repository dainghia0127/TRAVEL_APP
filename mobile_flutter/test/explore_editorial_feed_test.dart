import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/area_hero_banner.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/category_selector.dart';
import 'package:mobile_flutter/features/explore/presentation/widgets/explore_tab_bar.dart';

void main() {
  testWidgets('ExploreScreen renders complete Editorial Discovery Sections', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const TravelOutdoorApp());
    await tester.pump(const Duration(milliseconds: 500));

    // 1. Kiểm tra có Top Bar TabBar (TRONG NƯỚC / QUỐC TẾ)
    expect(find.byType(ExploreTabBar), findsOneWidget);

    // 2. Kiểm tra có Hero Banner giới thiệu khu vực
    expect(find.byType(AreaHeroBanner), findsOneWidget);
    expect(find.text('Việt Nam • Dải Đất Gấm Hoa'), findsOneWidget);

    // 3. Kiểm tra có Danh mục trải nghiệm (CategorySelector)
    expect(find.byType(CategorySelector), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Trekking / Leo núi'), findsOneWidget);

    // 4. Thử chuyển sang Tab QUỐC TẾ
    await tester.tap(find.text('QUỐC TẾ'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Kỳ Quan Thế Giới • 6 Châu Lục'), findsOneWidget);
  });
}

