import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';

/// Instagram-style live room UI (ready to plug a real stream later).
class LiveViewerScreen extends StatefulWidget {
  final LiveSession session;

  const LiveViewerScreen({super.key, required this.session});

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen>
    with TickerProviderStateMixin {
  final _commentController = TextEditingController();
  final _comments = <_LiveComment>[];
  final _hearts = <_FloatingHeart>[];
  Timer? _commentTimer;
  Timer? _viewerTimer;
  late int _viewers;
  late AnimationController _pulse;

  static const _seedComments = <String>[];

  @override
  void initState() {
    super.initState();
    _viewers = _parseViewers(widget.session.viewerCount);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _commentTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _seedComments.isEmpty) return;
      final rnd = math.Random();
      setState(() {
        _comments.add(
          _LiveComment(
            user: [
              'هنرجو',
              'نگین',
              'زهرا',
              'لیلا',
              'رضا',
              'مریم'
            ][rnd.nextInt(6)],
            text: _seedComments[rnd.nextInt(_seedComments.length)],
          ),
        );
        if (_comments.length > 40) {
          _comments.removeRange(0, _comments.length - 30);
        }
      });
    });

    _viewerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _viewers += math.Random().nextInt(7) - 2;
        if (_viewers < 200) _viewers = 200;
      });
    });
  }

  int _parseViewers(String fa) {
    final en = fa
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9')
        .replaceAll(',', '')
        .replaceAll('،', '');
    return int.tryParse(en) ?? 1000;
  }

  String _toFa(int n) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    final s = n.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        );
    return s.split('').map((c) => c == ',' ? '٬' : fa[int.parse(c)]).join();
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(_LiveComment(user: 'شما', text: text, isMine: true));
    });
    _commentController.clear();
  }

  void _addHeart(Offset global) {
    final id = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      _hearts.add(_FloatingHeart(id: id, x: global.dx));
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _hearts.removeWhere((h) => h.id == id));
    });
  }

  @override
  void dispose() {
    _commentTimer?.cancel();
    _viewerTimer?.cancel();
    _pulse.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onDoubleTapDown: (d) => _addHeart(d.globalPosition),
          onDoubleTap: () {},
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fake live video surface (replace later with real player)
              DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A1A0A),
                      Color(0xFF5C3A12),
                      Color(0xFFD4A843),
                      Color(0xFF1A1A2E),
                    ],
                  ),
                ),
              ),
              if (s.coverAsset != null)
                Opacity(
                  opacity: 0.22,
                  child: Image.asset(s.coverAsset!, fit: BoxFit.cover),
                ),
              // vignette
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0, 0.22, 0.55, 1],
                  ),
                ),
              ),

              // Center live watermark
              Align(
                alignment: const Alignment(0, -0.28),
                child: FadeTransition(
                  opacity: Tween(begin: 0.35, end: 0.7).animate(_pulse),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_rounded,
                          color: Colors.white54, size: 56),
                      const SizedBox(height: 8),
                      Text(
                        'پخش زنده',
                        style: GoogleFonts.vazirmatn(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'به‌زودی به استریم واقعی متصل می‌شود',
                        style: GoogleFonts.vazirmatn(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient:
                                    LinearGradient(colors: s.avatarGradient),
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: s.coverAsset != null
                                  ? Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Image.asset(s.coverAsset!,
                                          fit: BoxFit.contain),
                                    )
                                  : const Icon(Icons.cake,
                                      color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          s.hostName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.vazirmatn(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.verified_rounded,
                                          color: Color(0xFF3B82F6), size: 15),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.vazirmatn(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _LiveBadge(pulse: _pulse, viewers: _toFa(_viewers)),
                            const SizedBox(width: 2),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Comments
              Positioned(
                left: 40,
                right: 12,
                bottom: bottom + 74,
                height: 230,
                child: ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.zero,
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final c = _comments[_comments.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: RichText(
                            textDirection: TextDirection.rtl,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${c.user}  ',
                                  style: GoogleFonts.vazirmatn(
                                    color: c.isMine
                                        ? AppColors.gold300
                                        : Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: c.text,
                                  style: GoogleFonts.vazirmatn(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Floating hearts
              ..._hearts.map((h) {
                return _HeartBurst(key: ValueKey(h.id), startX: h.x);
              }),

              // Composer
              Positioned(
                left: 12,
                right: 12,
                bottom: bottom + 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white54),
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                        child: TextField(
                          controller: _commentController,
                          style: GoogleFonts.vazirmatn(
                              color: Colors.white, fontSize: 13),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'پیام به لایو...',
                            hintStyle: GoogleFonts.vazirmatn(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => _sendComment(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _addHeart(
                        Offset(MediaQuery.sizeOf(context).width - 40,
                            MediaQuery.sizeOf(context).height - 80),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.35),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: const Icon(Icons.favorite_rounded,
                            color: Color(0xFFFF3040), size: 22),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendComment,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF3040), Color(0xFFE1306C)],
                          ),
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.pulse, required this.viewers});

  final Animation<double> pulse;
  final String viewers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.04).animate(pulse),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3040), Color(0xFFE1306C)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'LIVE',
                style: GoogleFonts.vazirmatn(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          const Icon(Icons.remove_red_eye_outlined,
              color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            viewers,
            style: GoogleFonts.vazirmatn(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _LiveComment {
  final String user;
  final String text;
  final bool isMine;
  const _LiveComment(
      {required this.user, required this.text, this.isMine = false});
}

class _FloatingHeart {
  final int id;
  final double x;
  const _FloatingHeart({required this.id, required this.x});
}

class _HeartBurst extends StatefulWidget {
  final double startX;
  const _HeartBurst({super.key, required this.startX});

  @override
  State<_HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<_HeartBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeOut.transform(_c.value);
        return Positioned(
          left: widget.startX - 18 + math.sin(_c.value * 8) * 12,
          bottom: 90 + t * (h * 0.35),
          child: Opacity(
            opacity: (1 - _c.value).clamp(0, 1),
            child: Transform.scale(
              scale: 0.8 + t * 0.6,
              child: const Icon(Icons.favorite_rounded,
                  color: Color(0xFFFF3040), size: 30),
            ),
          ),
        );
      },
    );
  }
}
