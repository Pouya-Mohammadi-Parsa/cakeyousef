import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_colors.dart';

/// Branded course video player (Chewie + video_player).
class CourseVideoPlayer extends StatefulWidget {
  final String url;
  final String? title;
  final String? posterUrl;
  final bool autoPlay;
  final VoidCallback? onEnded;

  const CourseVideoPlayer({
    super.key,
    required this.url,
    this.title,
    this.posterUrl,
    this.autoPlay = true,
    this.onEnded,
  });

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init(widget.url);
  }

  @override
  void didUpdateWidget(covariant CourseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _init(widget.url);
    }
  }

  Future<void> _init(String url) async {
    await _disposePlayers();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      setState(() {
        _loading = false;
        _error = 'آدرس ویدیو نامعتبر است';
      });
      return;
    }

    final video = VideoPlayerController.networkUrl(uri);
    try {
      await video.initialize();
      if (!mounted) {
        await video.dispose();
        return;
      }
      final chewie = ChewieController(
        videoPlayerController: video,
        autoPlay: widget.autoPlay,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.gold500,
          handleColor: AppColors.gold600,
          bufferedColor: AppColors.gold300.withValues(alpha: 0.45),
          backgroundColor: Colors.white24,
        ),
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: AppColors.gold500,
          handleColor: AppColors.gold600,
          bufferedColor: AppColors.gold300.withValues(alpha: 0.45),
          backgroundColor: Colors.white24,
        ),
        placeholder: Container(color: AppColors.dark900),
        autoInitialize: true,
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
        errorBuilder: (_, message) => _ErrorPane(message: message),
      );
      video.addListener(_onVideoTick);
      setState(() {
        _video = video;
        _chewie = chewie;
        _loading = false;
      });
    } catch (e) {
      await video.dispose();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'پخش ویدیو ممکن نیست';
      });
    }
  }

  void _onVideoTick() {
    final v = _video;
    if (v == null || !v.value.isInitialized) return;
    final pos = v.value.position;
    final dur = v.value.duration;
    if (dur.inMilliseconds > 0 &&
        pos >= dur - const Duration(milliseconds: 400)) {
      widget.onEnded?.call();
    }
  }

  Future<void> _disposePlayers() async {
    _video?.removeListener(_onVideoTick);
    _chewie?.dispose();
    await _video?.dispose();
    _chewie = null;
    _video = null;
  }

  @override
  void dispose() {
    _disposePlayers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: AppColors.dark900,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.gold500),
                )
              else if (_error != null)
                _ErrorPane(message: _error!)
              else if (_chewie != null)
                Chewie(controller: _chewie!)
              else
                const SizedBox.shrink(),
              if (widget.title != null && widget.title!.trim().isNotEmpty)
                Positioned(
                  left: 10,
                  right: 10,
                  top: 10,
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  final String message;
  const _ErrorPane({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded,
                color: Colors.white54, size: 36),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Poster placeholder before a lesson is selected / when locked.
class CourseVideoPoster extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onPlay;
  final bool locked;

  const CourseVideoPoster({
    super.key,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.onPlay,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: courseGradient,
                ),
              ),
            ),
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: locked ? null : AppColors.goldGradient,
                    color: locked ? Colors.black54 : null,
                    boxShadow: locked ? null : AppColors.goldGlow,
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: locked ? 28 : 40,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const courseGradient = [Color(0xFFF59E0B), Color(0xFFB45309)];
