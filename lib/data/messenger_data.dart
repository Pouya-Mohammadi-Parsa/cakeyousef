import '../models/models.dart';
import '../theme/app_colors.dart';

/// Messenger conversations — empty until chat API is wired.
class MessengerData {
  static List<ChatConversation> get allChats => const [];

  static ChatConversation get support => ChatConversation(
        id: 'support',
        title: 'پشتیبانی',
        subtitle: '',
        lastMessage: '',
        time: '',
        unread: 0,
        kind: ChatKind.support,
        pinned: true,
        verified: true,
        online: false,
        avatarAsset: 'assets/images/logo.png',
        avatarGradient: const [AppColors.gold300, AppColors.gold600],
        messages: const [],
      );
}
