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
