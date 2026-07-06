import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:grid/chatcontrol.dart';

class ChatScreen extends StatefulWidget {
  final int chatIndex;
  final String name;
  final bool isGroup;
  final bool isDark;

  const ChatScreen({
    super.key,
    required this.chatIndex,
    required this.name,
    required this.isGroup,
    this.isDark = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ChatController _chatController = ChatController.instance;

  bool _showSend = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatController.markAsRead(widget.chatIndex);
    });
    _chatController.addListener(_onControllerUpdate);
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _showSend) {
        setState(() => _showSend = hasText);
      }
    });

    // Jab keyboard khule to emoji picker apne aap band ho jaye
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() => _showEmojiPicker = false);
      }
    });
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {});
    _chatController.markAsRead(widget.chatIndex);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final text = _controller.text;
    final selection = _controller.selection;
    final cursorPos = selection.start < 0 ? text.length : selection.start;

    final newText = text.replaceRange(cursorPos, cursorPos, emoji.emoji);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: cursorPos + emoji.emoji.length,
    );
  }

  void _onBackspace() {
    _controller
      ..text = _controller.text.characters.isEmpty
          ? ''
          : (_controller.text.characters.skipLast(1).toString())
      ..selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  void dispose() {
    _chatController.removeListener(_onControllerUpdate);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Colors ──
  Color get scaffoldBg   => widget.isDark ? const Color(0xFF0B141A) : const Color(0xFFECE5DD);
  Color get appBarColor  => widget.isDark ? const Color(0xFF1F2C34) : const Color(0xFF075E54);
  Color get myBubble     => widget.isDark ? const Color(0xFF005C4B) : const Color(0xFFDCF8C6);
  Color get theirBubble  => widget.isDark ? const Color(0xFF1F2C34) : Colors.white;
  Color get myText       => widget.isDark ? Colors.white : const Color(0xFF111111);
  Color get theirText    => widget.isDark ? Colors.white : const Color(0xFF111111);
  Color get timeColor    => widget.isDark ? const Color(0xFF8696A0) : Colors.grey;
  Color get inputBg      => widget.isDark ? const Color(0xFF1F2C34) : Colors.white;
  Color get inputText    => widget.isDark ? Colors.white : Colors.black;
  Color get senderColor  => const Color(0xFF25D366);

  void _sendMessage() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _chatController.sendMessage(widget.chatIndex, text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chatController.chats[widget.chatIndex];
    final messages = chat.messages;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.isGroup
                  ? const Color(0xFF075E54)
                  : const Color(0xFF1ABC9C),
              radius: 20,
              child: Icon(
                widget.isGroup ? Icons.group : Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.isGroup ? "Ali, Hassan, Nexgen..." : "Online",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages List ─────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_showEmojiPicker) setState(() => _showEmojiPicker = false);
              },
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        "Say hi 👋",
                        style: TextStyle(color: timeColor, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMine = msg.isSentByMe;

                        return Align(
                          alignment:
                              isMine ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMine ? myBubble : theirBubble,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: Radius.circular(isMine ? 12 : 0),
                                bottomRight: Radius.circular(isMine ? 0 : 12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.isGroup && !isMine)
                                  Text(
                                    msg.sender,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: senderColor,
                                    ),
                                  ),
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: isMine ? myText : theirText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      msg.time,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: timeColor,
                                      ),
                                    ),
                                    if (isMine) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.done_all,
                                        size: 14,
                                        color: msg.isSeen
                                            ? const Color(0xFF34B7F1)
                                            : timeColor,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // ── Input Bar ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: widget.isDark
                ? const Color(0xFF0B141A)
                : const Color(0xFFECE5DD),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 6),
                        // 👇 Emoji toggle button
                        IconButton(
                          icon: Icon(
                            _showEmojiPicker
                                ? Icons.keyboard_alt_outlined
                                : Icons.emoji_emotions_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleEmojiPicker,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: TextStyle(color: inputText),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            onTap: () {
                              if (_showEmojiPicker) {
                                setState(() => _showEmojiPicker = false);
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: "Message",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file,
                              color: Colors.grey),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt_outlined,
                              color: Colors.grey),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send / Mic button
                GestureDetector(
                  onTap: _showSend ? _sendMessage : () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _showSend ? Icons.send : Icons.mic,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Emoji Picker Panel ─────────────────────────────
          Offstage(
            offstage: !_showEmojiPicker,
            child: SizedBox(
              height: 280,
              child: EmojiPicker(
                onEmojiSelected: _onEmojiSelected,
                onBackspacePressed: _onBackspace,
                config: Config(
                  height: 280,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    columns: 8,
                    emojiSizeMax: 28,
                    backgroundColor: widget.isDark
                        ? const Color(0xFF1F2C34)
                        : Colors.white,
                  ),
                  skinToneConfig: const SkinToneConfig(),
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: widget.isDark
                        ? const Color(0xFF1F2C34)
                        : Colors.white,
                    indicatorColor: const Color(0xFF25D366),
                    iconColorSelected: const Color(0xFF25D366),
                    iconColor: widget.isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                  bottomActionBarConfig: BottomActionBarConfig(
                    backgroundColor: widget.isDark
                        ? const Color(0xFF1F2C34)
                        : Colors.white,
                    buttonColor: widget.isDark
                        ? const Color(0xFF1F2C34)
                        : Colors.white,
                    buttonIconColor: const Color(0xFF25D366),
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: widget.isDark
                        ? const Color(0xFF1F2C34)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}