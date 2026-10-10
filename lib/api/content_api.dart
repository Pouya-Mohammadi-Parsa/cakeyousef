import '../models/catalog_models.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import 'api_client.dart';
import 'api_config.dart';

class ContentApi {
  ContentApi({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// GET /api/content/stories (not under /api/v1).
  Future<List<StoryItem>> fetchStories() async {
    final body = await _client.get('${ApiConfig.host}/api/content/stories');
    final raw = body['stories'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((e) => _storyFromJson(Map<String, dynamic>.from(e)))
        .where(
          (s) => s.pages.any(
            (p) => p.imageAsset != null && p.imageAsset!.isNotEmpty,
          ),
        )
        .toList(growable: false);
  }

  /// GET /api/content/courses — published courses list.
  Future<List<CourseDto>> fetchCourses() async {
    final body = await _client.get('${ApiConfig.host}/api/content/courses');
    final raw = body['courses'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((e) => CourseDto.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.title.isNotEmpty)
        .toList(growable: false);
  }

  /// GET /api/content/courses/{slug} — course detail.
  Future<CourseDto> fetchCourseDetail(String slugOrId) async {
    final encoded = Uri.encodeComponent(slugOrId);
    final body = await _client.get(
      '${ApiConfig.host}/api/content/courses/$encoded',
    );
    final raw = body['course'] ?? body;
    if (raw is! Map) {
      throw const ApiException('جزئیات دوره دریافت نشد');
    }
    return CourseDto.fromJson(Map<String, dynamic>.from(raw));
  }

  /// GET /api/content/products — shop list (+ categories).
  Future<({List<ShopProductDto> products, List<String> categories})>
      fetchProducts() async {
    final body = await _client.get('${ApiConfig.host}/api/content/products');
    final raw = body['products'];
    final products = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => ShopProductDto.fromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.title.isNotEmpty)
            .toList(growable: false)
        : const <ShopProductDto>[];

    final catsRaw = body['categories'];
    final categories = <String>['همه'];
    if (catsRaw is List) {
      for (final c in catsRaw) {
        final label = c?.toString().trim() ?? '';
        if (label.isEmpty || label == 'همه' || categories.contains(label)) {
          continue;
        }
        categories.add(label);
      }
    } else {
      final seen = <String>{};
      for (final p in products) {
        final cat = p.category.trim();
        if (cat.isEmpty || seen.contains(cat)) continue;
        seen.add(cat);
        categories.add(cat);
      }
    }
    return (products: products, categories: categories);
  }

  /// GET /api/content/products/{id} — product detail.
  Future<ShopProductDto> fetchProductDetail(String id) async {
    final encoded = Uri.encodeComponent(id);
    final body = await _client.get(
      '${ApiConfig.host}/api/content/products/$encoded',
    );
    final raw = body['product'] ?? body;
    if (raw is! Map) {
      throw const ApiException('جزئیات محصول دریافت نشد');
    }
    return ShopProductDto.fromJson(Map<String, dynamic>.from(raw));
  }

  static StoryItem _storyFromJson(Map<String, dynamic> json) {
    final id = '${json['id'] ?? ''}';
    final username = json['username']?.toString().trim() ?? '';
    final alt = json['alt']?.toString().trim() ?? '';
    final avatar = ApiConfig.mediaUrl(json['avatar']?.toString());
    final image = ApiConfig.mediaUrl(json['storyImageUrl']?.toString());

    final label =
        username.isNotEmpty ? username : (alt.isNotEmpty ? alt : 'استوری');
    final initial = _initial(label);

    return StoryItem(
      id: id.isEmpty ? image : id,
      username: label,
      emoji: initial,
      avatarGradient: const [AppColors.gold300, AppColors.gold600],
      coverAsset: avatar.isEmpty ? null : avatar,
      pages: [
        StoryPage(
          emoji: initial,
          caption: alt.isNotEmpty ? alt : label,
          gradientColors: [AppColors.dark900, AppColors.dark700],
          imageAsset: image.isEmpty ? null : image,
        ),
      ],
    );
  }

  static String _initial(String value) {
    if (value.isEmpty) return '•';
    return String.fromCharCodes(value.runes.take(1));
  }
}
