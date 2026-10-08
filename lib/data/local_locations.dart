import '../models/account_models.dart';

/// Local static locations (no remote API).
class LocalLocations {
  static const provinces = <LocationItem>[
    LocationItem(legacyId: 1, title: 'تهران', parentLegacyId: 0, sortOrder: 1),
    LocationItem(legacyId: 2, title: 'اصفهان', parentLegacyId: 0, sortOrder: 2),
    LocationItem(legacyId: 3, title: 'فارس', parentLegacyId: 0, sortOrder: 3),
    LocationItem(legacyId: 4, title: 'خراسان رضوی', parentLegacyId: 0, sortOrder: 4),
    LocationItem(legacyId: 5, title: 'آذربایجان شرقی', parentLegacyId: 0, sortOrder: 5),
  ];

  static const _cities = <int, List<LocationItem>>{
    1: [
      LocationItem(legacyId: 101, title: 'تهران', parentLegacyId: 1, sortOrder: 1),
      LocationItem(legacyId: 102, title: 'شمیرانات', parentLegacyId: 1, sortOrder: 2),
      LocationItem(legacyId: 103, title: 'ری', parentLegacyId: 1, sortOrder: 3),
    ],
    2: [
      LocationItem(legacyId: 201, title: 'اصفهان', parentLegacyId: 2, sortOrder: 1),
      LocationItem(legacyId: 202, title: 'کاشان', parentLegacyId: 2, sortOrder: 2),
    ],
    3: [
      LocationItem(legacyId: 301, title: 'شیراز', parentLegacyId: 3, sortOrder: 1),
    ],
    4: [
      LocationItem(legacyId: 401, title: 'مشهد', parentLegacyId: 4, sortOrder: 1),
    ],
    5: [
      LocationItem(legacyId: 501, title: 'تبریز', parentLegacyId: 5, sortOrder: 1),
    ],
  };

  static Future<List<LocationItem>> fetchProvinces() async => provinces;

  static Future<List<LocationItem>> fetchCities(int provinceId) async =>
      List<LocationItem>.from(_cities[provinceId] ?? const []);
}
