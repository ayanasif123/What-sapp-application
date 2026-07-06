import 'package:flutter/material.dart';
import 'package:grid/chatmodel.dart';
import 'package:grid/chatscreen.dart';


class ChatTile extends StatelessWidget {
  final int chatIndex; // 👈 index in ChatController.instance.chats
  final ChatModel chat;
  final bool isDark;
  final VoidCallback? onLongPress;

  const ChatTile({
    super.key,
    required this.chatIndex,
    required this.chat,
    this.isDark = false,
    this.onLongPress,
  });

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF1ABC9C),
      Color(0xFF2ECC71),
      Color(0xFF3498DB),
      Color(0xFF9B59B6),
      Color(0xFFE67E22),
      Color(0xFFE74C3C),
      Color(0xFF16A085),
      Color(0xFF2980B9),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  Color get tileBg      => isDark ? const Color(0xFF121B22) : Colors.white;
  Color get nameColor   => isDark ? Colors.white : const Color(0xFF111111);
  Color get msgColor    => isDark ? const Color(0xFF8696A0) : Colors.grey;
  Color get msgUnread   => isDark ? const Color(0xFFE9EDF0) : Colors.black87;
  Color get timeDefault => isDark ? const Color(0xFF8696A0) : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatIndex: chatIndex,
              name: chat.name,
              isGroup: chat.isGroup,
              isDark: isDark,
            ),
          ),
        );
      },
      onLongPress: onLongPress,
      splashColor: isDark ? const Color(0xFF2A3942) : Colors.grey.shade100,
      child: Container(
        color: tileBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Avatar ───────────────────────────────────────
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: chat.isGroup
                        ? const Color(0xFF075E54)
                        : _avatarColor(chat.name),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: chat.isGroup
                        ? const Icon(Icons.group, color: Colors.white, size: 26)
                        : Text(
                            _initials(chat.name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
                if (!chat.isGroup)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        shape: BoxShape.circle,
                        border: Border.all(color: tileBg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Name + Message ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: nameColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (chat.isSentByMe) ...[
                        const Icon(
                          Icons.done_all,
                          size: 16,
                          color: Color(0xFF34B7F1),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: chat.unread > 0 ? msgUnread : msgColor,
                            fontWeight: chat.unread > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── Time + Badge ──────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: chat.unread > 0
                        ? const Color(0xFF25D366)
                        : timeDefault,
                    fontWeight: chat.unread > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                if (chat.unread > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                    child: Center(
                      child: Text(
                        chat.unread > 99 ? '99+' : chat.unread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}