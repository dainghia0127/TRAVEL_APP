import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rootBundle can load destinations asset', () async {
    final data = await rootBundle.load('assets/images/destinations/dest_vn_ma_pi_leng.jpg');
    expect(data.lengthInBytes, greaterThan(0));
  });

  test('rootBundle can load default nature asset', () async {
    final data = await rootBundle.load('assets/images/default_nature.jpg');
    expect(data.lengthInBytes, greaterThan(0));
  });
}
