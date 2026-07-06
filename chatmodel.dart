class MessageModel {
  final String text;
  final bool isSentByMe;
  final String sender;
  final String time;
  bool isSeen;

  MessageModel({
    required this.text,
    required this.isSentByMe,
    required this.sender,
    required this.time,
    this.isSeen = false,
  });
}

class ChatModel {
  final String name;
  String message;
  String time;
  int unread;
  final bool isGroup;
  bool isSentByMe;
  final List<MessageModel> messages;

  ChatModel({
    required this.name,
    required this.message,
    required this.time,
    this.unread = 0,
    this.isGroup = false,
    this.isSentByMe = false,
    List<MessageModel>? messages,
  }) : messages = messages ?? [];

  ChatModel copyWith({
    String? name,
    String? message,
    String? time,
    int? unread,
    bool? isGroup,
    bool? isSentByMe,
    List<MessageModel>? messages,
  }) {
    return ChatModel(
      name: name ?? this.name,
      message: message ?? this.message,
      time: time ?? this.time,
      unread: unread ?? this.unread,
      isGroup: isGroup ?? this.isGroup,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      messages: messages ?? this.messages,
    );
  }
}