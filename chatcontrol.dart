import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grid/chatmodel.dart';

/// Central single-source-of-truth for all chats + messages.
/// HomeScreen and ChatScreen both listen to this so that sending
/// a message actually updates the chat list (last message, time,
/// unread count) in real time — just like real WhatsApp.
class ChatController extends ChangeNotifier {
  ChatController._internal() {
    _seedDummyData();
  }

  static final ChatController instance = ChatController._internal();

  final List<ChatModel> chats = [];

  final Random _rand = Random();

  final List<String> _autoReplies = [
    "Haan bhai bilkul",
    "Ok samajh gaya",
    "Theek hai, thodi dair mein batata hoon",
    "👍",
    "Acha chalo",
    "Kal milte hain phir",
    "Sahi hai!",
    "Are wah 😄",
  ];

  void _seedDummyData() {
    chats.addAll([
      ChatModel(
        name: "Nexgen_Boys",
        message: "Hey! How are you all?",
        time: "10:30 PM",
        unread: 1,
        isGroup: true,
        isSentByMe: false,
        messages: [
          MessageModel(text: "Assalamualaikum guys!", isSentByMe: false, sender: "Sir", time: "9:00 PM"),
          MessageModel(text: "Walaikum Assalam sir!", isSentByMe: true, sender: "Me", time: "9:01 PM", isSeen: true),
          MessageModel(text: "Hey! How are you all?", isSentByMe: false, sender: "Sir", time: "10:30 PM"),
        ],
      ),
      ChatModel(
        name: "Ali Ahmed",
        message: "Assalamualaikum",
        time: "9:20 PM",
        unread: 1,
        isSentByMe: false,
        messages: [
          MessageModel(text: "Assalamualaikum", isSentByMe: false, sender: "Ali Ahmed", time: "9:20 PM"),
        ],
      ),
      ChatModel(
        name: "Design Team",
        message: "You Like Status",
        time: "8:10 PM",
        unread: 5,
        isGroup: true,
        isSentByMe: false,
        messages: [
          MessageModel(text: "You Like Status", isSentByMe: false, sender: "Team", time: "8:10 PM"),
        ],
      ),
      ChatModel(
        name: "Sara Khan",
        message: "Ok done 👍",
        time: "Yesterday",
        isSentByMe: true,
        messages: [
          MessageModel(text: "Ok done 👍", isSentByMe: true, sender: "Me", time: "Yesterday", isSeen: true),
        ],
      ),
      ChatModel(
        name: "Flutter Devs",
        message: "Meeting at 6 PM",
        time: "Yesterday",
        isGroup: true,
        isSentByMe: false,
        messages: [
          MessageModel(text: "Meeting at 6 PM", isSentByMe: false, sender: "Admin", time: "Yesterday"),
        ],
      ),
      ChatModel(
        name: "Hassan",
        message: "Send me file",
        time: "Mon",
        isSentByMe: true,
        messages: [
          MessageModel(text: "Send me file", isSentByMe: true, sender: "Me", time: "Mon", isSeen: true),
        ],
      ),
      ChatModel(
        name: "Friend",
        message: "Send me message",
        time: "Tues",
        isSentByMe: false,
        messages: [
          MessageModel(text: "Send me message", isSentByMe: false, sender: "Friend", time: "Tues"),
        ],
      ),
      ChatModel(
        name: "Home",
        message: "like your status",
        time: "Tues",
        isSentByMe: false,
        messages: [
          MessageModel(text: "like your status", isSentByMe: false, sender: "Home", time: "Tues"),
        ],
      ),
      ChatModel(
        name: "Bhai",
        message: "Send me file",
        time: "Wed",
        isSentByMe: true,
        messages: [
          MessageModel(text: "Send me file", isSentByMe: true, sender: "Me", time: "Wed", isSeen: true),
        ],
      ),
      ChatModel(
        name: "Abeeq",
        message: "send a video",
        time: "Wed",
        isSentByMe: false,
        messages: [
          MessageModel(text: "send a video", isSentByMe: false, sender: "Abeeq", time: "Wed"),
        ],
      ),
      ChatModel(
        name: "Ahmed",
        message: "OK",
        time: "Thur",
        isSentByMe: true,
        messages: [
          MessageModel(text: "OK", isSentByMe: true, sender: "Me", time: "Thur", isSeen: true),
        ],
      ),
      ChatModel(
        name: "Sir",
        message: "Ok",
        time: "Fri",
        isSentByMe: false,
        messages: [
          MessageModel(text: "Ok", isSentByMe: false, sender: "Sir", time: "Fri"),
        ],
      ),
    ]);
  }

  String _nowTime() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  /// Marks chat as read (called when user opens the chat)
  void markAsRead(int index) {
    if (chats[index].unread > 0) {
      chats[index].unread = 0;
      notifyListeners();
    }
  }

  /// Send a message from "me" inside a specific chat.
  /// Updates: message list inside the chat, last message + time on
  /// home screen, and triggers a simulated auto-reply + "seen" tick,
  /// exactly like a real messaging app.
  void sendMessage(int index, String text) {
    if (text.trim().isEmpty) return;
    final chat = chats[index];
    final time = _nowTime();

    final msg = MessageModel(
      text: text.trim(),
      isSentByMe: true,
      sender: "Me",
      time: time,
      isSeen: false,
    );

    chat.messages.add(msg);
    chat.message = text.trim();
    chat.time = time;
    chat.isSentByMe = true;
    notifyListeners();

    // Simulate "seen" tick after a short delay
    Timer(const Duration(milliseconds: 900), () {
      msg.isSeen = true;
      notifyListeners();
    });

    // Simulate the other side typing + replying (real-app feel)
    Timer(Duration(milliseconds: 1400 + _rand.nextInt(1200)), () {
      _receiveAutoReply(index);
    });
  }

  void _receiveAutoReply(int index) {
    if (index >= chats.length) return;
    final chat = chats[index];
    final reply = _autoReplies[_rand.nextInt(_autoReplies.length)];
    final time = _nowTime();

    final replyMsg = MessageModel(
      text: reply,
      isSentByMe: false,
      sender: chat.isGroup ? "Ali" : chat.name,
      time: time,
    );

    chat.messages.add(replyMsg);
    chat.message = reply;
    chat.time = time;
    chat.isSentByMe = false;

    // If the user isn't currently viewing this chat, bump unread count.
    // ChatScreen calls markAsRead() on open/foreground, so unread only
    // sticks when the chat isn't open.
    chat.unread += 1;

    notifyListeners();
  }

  void editMessageText(int index, String newText) {
    chats[index].message = newText;
    notifyListeners();
  }

  void deleteChat(int index) {
    chats.removeAt(index);
    notifyListeners();
  }
}