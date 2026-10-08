import 'package:flutter/material.dart';

import '../models/models.dart';

class ChatAvatar extends StatelessWidget {
  final ChatConversation conversation;
  final double size;

  const ChatAvatar({
    super.key,
    required this.conversation,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: conversation.avatarGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: conversation.avatarGradient.last.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: conversation.avatarAsset != null
                ? Padding(
                    padding: EdgeInsets.all(size * 0.12),
                    child: Image.asset(
                      conversation.avatarAsset!,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(
                    conversation.avatarIcon ?? Icons.person_rounded,
                    color: Colors.white,
                    size: size * 0.46,
                  ),
          ),
          if (conversation.online)
            Positioned(
              bottom: 1,
              left: 1,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          if (conversation.kind == ChatKind.channel && !conversation.online)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  size: size * 0.18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
