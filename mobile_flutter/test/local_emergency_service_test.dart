import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/safety/services/local_emergency_service.dart';

void main() {
  group('LocalEmergencyService Tests', () {
    test('Resolves Lam Dong emergency contacts accurately by coordinates', () async {
      // Tọa độ Tà Năng - Lâm Đồng: 11.6420, 108.4230
      final area = await LocalEmergencyService.resolveEmergencyContacts(11.6420, 108.4230);
      expect(area.provinceName, contains('Lâm Đồng'));
      expect(area.contacts.isNotEmpty, isTrue);
      expect(area.contacts.any((c) => c.phone.contains('0263') || c.phone == '114'), isTrue);
    });

    test('Resolves Lao Cai emergency contacts for Sa Pa / Fansipan', () async {
      // Tọa độ Sa Pa - Lào Cai: 22.3551, 103.7745
      final area = await LocalEmergencyService.resolveEmergencyContacts(22.3551, 103.7745);
      expect(area.provinceName, contains('Lào Cai'));
      expect(area.contacts.any((c) => c.title.contains('Hoàng Liên') || c.phone.contains('0214')), isTrue);
    });

    test('Resolves Ha Giang emergency contacts for Ma Pi Leng', () async {
      // Tọa độ Mã Pí Lèng - Hà Giang: 23.2389, 105.4180
      final area = await LocalEmergencyService.resolveEmergencyContacts(23.2389, 105.4180);
      expect(area.provinceName, contains('Hà Giang'));
      expect(area.contacts.any((c) => c.title.contains('Đồng Văn') || c.phone.contains('0219')), isTrue);
    });

    test('Falls back to National emergency contacts for unknown coordinates', () async {
      // Tọa độ ngoài biển hoặc không xác định: 0.0, 0.0
      final area = await LocalEmergencyService.resolveEmergencyContacts(0.0, 0.0);
      expect(area.contacts.any((c) => c.phone == '112'), isTrue);
      expect(area.contacts.any((c) => c.phone == '115'), isTrue);
    });
  });
}
