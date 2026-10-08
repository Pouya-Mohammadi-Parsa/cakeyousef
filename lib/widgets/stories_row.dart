import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/stories_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/network_image.dart';
import 'story_viewer.dart';

/// Instagram-style stories strip from `/api/content/stories`.
class StoriesRow extends StatefulWidget {
  const StoriesRow({super.key});

  @override
  State<StoriesRow> createState() => _StoriesRowState();
}

class _StoriesRowState extends State<StoriesRow> {
  final _repo = StoriesRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepo);
    _repo.load();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  void _openStory(int index) {
    final stories = _repo.stories
        .where((s) => !s.isMine && s.pages.isNotEmpty)
        .toList(growable: false);
    if (stories.isEmpty) return;

    final tappedId = _repo.stories[index].id;
    final start = stories.indexWhere((s) => s.id == tappedId);
    if (start < 0) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewer(
          stories: stories,
          initialIndex: start,
          onStorySeen: _repo.markSeen,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stories = _repo.stories;
    if (stories.isEmpty) {
      if (_repo.loading) {
        return const SizedBox(
          height: 108,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      if (_repo.error != null) {
        return SizedBox(
          height: 48,
          child: Center(
            child: TextButton.icon(
              onPressed: () => _repo.load(force: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'تلاش مجدد استوری',
                style: AppFonts.vazirmatn(fontSize: 12),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _StoryAvatar(
            story: stories[index],
            onTap: () => _openStory(index),
          );
        },
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final StoryItem story;
  final VoidCallback onTap;

  const _StoryAvatar({required this.story, required this.onTap});

  static const _instagramRing = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFFEDA77),
      Color(0xFFF58529),
      Color(0xFFDD2A7B),
      Color(0xFF8134AF),
      Color(0xFF515BD4),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final ringGradient = story.seen ? null : _instagramRing;
    final ringColor = story.seen ? const Color(0xFFDBDBDB) : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ringGradient,
                      color: ringColor,
                    ),
                  ),
                  Container(
                    width: 66,
                    height: 66,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  ClipOval(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: story.coverAsset != null
                          ? AppNetworkImage(
                              url: story.coverAsset!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: story.avatarGradient,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  story.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              story.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.dark800,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
