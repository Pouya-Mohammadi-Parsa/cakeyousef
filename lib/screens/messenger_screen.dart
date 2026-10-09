import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/messenger_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/chat_avatar.dart';
import 'chat_screen.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ChatConversation> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return MessengerData.allChats;
    return MessengerData.allChats
        .where(
          (c) =>
              c.title.contains(q) ||
              c.subtitle.contains(q) ||
              c.lastMessage.contains(q),
        )
        .toList();
  }

  void _openChat(ChatConversation chat) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChatScreen(conversation: chat),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.06, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filtered;
    final support = chats.where((c) => c.kind == ChatKind.support).toList();
    final channels = chats.where((c) => c.kind == ChatKind.channel).toList();

    return Column(
      children: [
        _MessengerHeader(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              if (support.isNotEmpty) ...[
                _SectionLabel(
                  title: 'پشتیبانی',
                  icon: Icons.support_agent_rounded,
                  count: support.length,
                ),
                const SizedBox(height: 8),
                ...support.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ChatTile(chat: c, onTap: () => _openChat(c)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (channels.isNotEmpty) ...[
                _SectionLabel(
                  title: 'کانال‌های کیک یوسف',
                  icon: Icons.campaign_rounded,
                  count: channels.length,
                ),
                const SizedBox(height: 8),
                ...channels.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ChatTile(chat: c, onTap: () => _openChat(c)),
                  ),
                ),
              ],
              if (chats.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: AppColors.warm300),
                      const SizedBox(height: 12),
                      Text(
                        'نتیجه‌ای پیدا نشد',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessengerHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _MessengerHeader({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.goldGlow,
                ),
                child: const Icon(Icons.forum_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'پیام‌رسان',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark900,
                      ),
                    ),
                    Text(
                      'پشتیبانی و کانال‌های کیک یوسف',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warm400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Icon(Icons.edit_square, size: 18, color: AppColors.dark700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.warm400, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark800,
                    ),
                    decoration: InputDecoration(
                      hintText: 'جستجو در گفتگوها و کانال‌ها...',
                      hintStyle: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        color: AppColors.warm400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;

  const _SectionLabel({
    required this.title,
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gold600),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.vazirmatn(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.dark800,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.gold50,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.vazirmatn(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.gold700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatConversation chat;
  final VoidCallback onTap;

  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
            border: chat.pinned
                ? Border.all(color: AppColors.gold300.withValues(alpha: 0.7))
                : null,
          ),
          child: Row(
            children: [
              ChatAvatar(conversation: chat),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (chat.pinned) ...[
                          Icon(Icons.push_pin_rounded, size: 14, color: AppColors.gold500),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            chat.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark900,
                            ),
                          ),
                        ),
                        if (chat.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF3B82F6)),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          chat.time,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: chat.unread > 0 ? AppColors.gold600 : AppColors.warm400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.vazirmatn(
                              fontSize: 12,
                              fontWeight: chat.unread > 0 ? FontWeight.w700 : FontWeight.w500,
                              color: chat.unread > 0 ? AppColors.dark700 : AppColors.warm400,
                            ),
                          ),
                        ),
                        if (chat.unread > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${chat.unread}',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (chat.kind == ChatKind.channel) ...[
                      const SizedBox(height: 6),
                      Text(
                        chat.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold600,
                        ),
                      ),
                    ],
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
