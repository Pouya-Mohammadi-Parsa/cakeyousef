import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/chat_avatar.dart';

class ChatScreen extends StatefulWidget {
  final ChatConversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final List<ChatMessage> _messages;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  bool get _isChannel => widget.conversation.kind == ChatKind.channel;
  bool get _canReply => widget.conversation.kind == ChatKind.support;

  @override
  void initState() {
    super.initState();
    _messages = List<ChatMessage>.from(widget.conversation.messages);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final url = widget.conversation.externalUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'امکان باز کردن لینک وجود ندارد',
            style: GoogleFonts.vazirmatn(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          time: 'اکنون',
          isMine: true,
        ),
      );
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });

    // Auto support reply
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'auto-${DateTime.now().millisecondsSinceEpoch}',
            text:
                'پیامتون دریافت شد ✅\nکارشناس پشتیبانی به‌زودی پاسخ می‌ده. ممنون از صبوریتون.',
            time: 'اکنون',
          ),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    color: AppColors.dark800,
                  ),
                  ChatAvatar(conversation: c, size: 42),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                c.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark900,
                                ),
                              ),
                            ),
                            if (c.verified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Color(0xFF3B82F6),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.online
                              ? 'آنلاین'
                              : (_isChannel ? 'کانال رسمی' : c.subtitle),
                          style: GoogleFonts.vazirmatn(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.online
                                ? const Color(0xFF16A34A)
                                : AppColors.warm400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (c.externalUrl != null)
                    IconButton(
                      onPressed: _openExternal,
                      tooltip: 'باز کردن کانال',
                      icon: const Icon(Icons.open_in_new_rounded, size: 20),
                      color: AppColors.gold600,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (c.externalUrl != null)
            Material(
              color: AppColors.gold50,
              child: InkWell(
                onTap: _openExternal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 18, color: AppColors.gold600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'مشاهده در ${c.title.contains('ایتا') ? 'ایتا' : c.title.contains('روبیکا') ? 'روبیکا' : 'مرورگر'}',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_left_rounded, color: AppColors.gold600),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.isSystem) {
                  return _SystemChip(text: msg.text);
                }
                return _Bubble(message: msg);
              },
            ),
          ),
          if (_canReply) _Composer(controller: _controller, onSend: _send, focus: _focus),
          if (!_canReply)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              color: Colors.white,
              child: Text(
                'فقط مشاهده — این یک کانال است',
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warm400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SystemChip extends StatelessWidget {
  final String text;
  const _SystemChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warm200.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.dark700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    return Align(
      alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          gradient: mine ? AppColors.goldGradient : null,
          color: mine ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 6 : 18),
            bottomRight: Radius.circular(mine ? 18 : 6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: GoogleFonts.vazirmatn(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.65,
                color: mine ? Colors.white : AppColors.dark900,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: mine
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.warm400,
                  ),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final FocusNode focus;

  const _Composer({
    required this.controller,
    required this.onSend,
    required this.focus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.attach_file_rounded, color: AppColors.warm400, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: controller,
                focusNode: focus,
                textAlign: TextAlign.right,
                minLines: 1,
                maxLines: 4,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark800,
                ),
                decoration: InputDecoration(
                  hintText: 'پیام خود را بنویسید...',
                  hintStyle: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    color: AppColors.warm400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.goldGlow,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
