import 'package:flutter/foundation.dart';

import '../models/catalog_models.dart';

/// Products catalog — empty until API is wired.
class ProductsRepository extends ChangeNotifier {
  ProductsRepository._();
  static final ProductsRepository instance = ProductsRepository._();

  List<ShopProductDto> products = const [];
  List<String> categories = const ['همه'];
  bool loading = false;
  String? error;

  bool get hasData => products.isNotEmpty;

  static const int homePreviewCount = 8;

  List<ShopProductDto> get homePreview =>
      products.take(homePreviewCount).toList(growable: false);

  Future<void> load({bool force = false}) async {
    if (loading) return;
    if (hasData && !force) return;

    loading = true;
    error = null;
    notifyListeners();

    // No mock / no API yet — intentionally empty.
    products = const [];
    categories = const ['همه'];
    loading = false;
    notifyListeners();
  }

  List<ShopProductDto> filtered(String category) {
    if (category.isEmpty || category == 'همه') return products;
    return products.where((p) => p.category == category).toList();
  }

  Future<ShopProductDto> fetchDetail(String id) async {
    final match = products.where((p) => p.id == id);
    if (match.isEmpty) {
      throw StateError('محصول یافت نشد — API هنوز متصل نیست');
    }
    return match.first;
  }
}
