import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../utils/network_image.dart';

/// Full-screen Instagram-like story player.
class StoryViewer extends StatefulWidget {
  final List<StoryItem> stories;
  final int initialIndex;
  final ValueChanged<String>? onStorySeen;

  const StoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.onStorySeen,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  static const _pageDuration = Duration(seconds: 5);

  late int _storyIndex;
  late int _pageIndex;
  late AnimationController _progress;
  bool _holding = false;
  double _dragOffset = 0;

  StoryItem get _story => widget.stories[_storyIndex];
  StoryPage get _page => _story.pages[_pageIndex];

  @override
  void initState() {
    super.initState();
    _storyIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _pageIndex = 0;
    _progress = AnimationController(vsync: this, duration: _pageDuration)
      ..addStatusListener(_onProgressStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStorySeen?.call(_story.id);
      _progress.forward(from: 0);
    });
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goNext();
    }
  }

  void _goNext() {
    if (_pageIndex < _story.pages.length - 1) {
      setState(() => _pageIndex++);
      _progress.forward(from: 0);
      return;
    }
    if (_storyIndex < widget.stories.length - 1) {
      setState(() {
        _storyIndex++;
        _pageIndex = 0;
      });
      widget.onStorySeen?.call(_story.id);
      _progress.forward(from: 0);
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _goPrevious() {
    if (_pageIndex > 0) {
      setState(() => _pageIndex--);
      _progress.forward(from: 0);
      return;
    }
    if (_storyIndex > 0) {
      setState(() {
        _storyIndex--;
        _pageIndex = widget.stories[_storyIndex].pages.length - 1;
      });
      widget.onStorySeen?.call(_story.id);
      _progress.forward(from: 0);
      return;
    }
    _progress.forward(from: 0);
  }

  void _pause() {
    _holding = true;
    _progress.stop();
  }

  void _resume() {
    if (!_holding) return;
    _holding = false;
    _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onLongPressStart: (_) => _pause(),
          onLongPressEnd: (_) => _resume(),
          onVerticalDragUpdate: (d) {
            setState(() => _dragOffset = (_dragOffset + d.delta.dy).clamp(0, 400));
            if (_dragOffset > 8) _pause();
          },
          onVerticalDragEnd: (d) {
            if (_dragOffset > 120 || (d.primaryVelocity ?? 0) > 800) {
              Navigator.of(context).maybePop();
              return;
            }
            setState(() => _dragOffset = 0);
            _resume();
          },
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: Opacity(
              opacity: (1 - _dragOffset / 400).clamp(0.4, 1),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Story content
                  Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _page.gradientColors,
                          ),
                        ),
                      ),
                      if (_page.imageAsset != null)
                        AppNetworkImage(
                          url: _page.imageAsset!,
                          fit: BoxFit.cover,
                        ),
                      if (_page.imageAsset == null)
                        Column(
                          children: [
                            SizedBox(height: top + 72),
                            const Spacer(),
                            Text(_page.emoji, style: const TextStyle(fontSize: 120)),
                            const SizedBox(height: 28),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Text(
                                _page.caption,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.5,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 12,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                    ],
                  ),

                  // Tap zones (physical LTR: left = previous, right = next)
                  Positioned.fill(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _goPrevious,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _goNext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top chrome: progress + header
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                        child: Column(
                          children: [
                            _ProgressBars(
                              count: _story.pages.length,
                              current: _pageIndex,
                              animation: _progress,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: _story.avatarGradient,
                                    ),
                                    border: Border.all(
                                      color: Colors.white70,
                                      width: 1.5,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _story.coverAsset != null
                                      ? AppNetworkImage(
                                          url: _story.coverAsset!,
                                          fit: BoxFit.cover,
                                          width: 36,
                                          height: 36,
                                        )
                                      : Center(
                                          child: Text(
                                            _story.emoji,
                                            style: GoogleFonts.vazirmatn(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _story.username,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.vazirmatn(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _page.timeAgo,
                                        style: GoogleFonts.vazirmatn(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Reply bar (Instagram-style bottom)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: MediaQuery.paddingOf(context).bottom + 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white54,
                                width: 1.2,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            child: Text(
                              'ارسال پیام...',
                              style: GoogleFonts.vazirmatn(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                        const SizedBox(width: 14),
                        const Icon(Icons.send_outlined, color: Colors.white, size: 26),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  final int count;
  final int current;
  final Animation<double> animation;

  const _ProgressBars({
    required this.count,
    required this.current,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: List.generate(count, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 3,
                right: i == count - 1 ? 0 : 3,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 2.5,
                  child: i < current
                      ? const ColoredBox(color: Colors.white)
                      : i > current
                          ? ColoredBox(
                              color: Colors.white.withValues(alpha: 0.35),
                            )
                          : AnimatedBuilder(
                              animation: animation,
                              builder: (_, __) {
                                return LinearProgressIndicator(
                                  value: animation.value,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.35),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                  minHeight: 2.5,
                                );
                              },
                            ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
