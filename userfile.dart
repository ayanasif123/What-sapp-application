import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Simple immutable data holder for the user's profile info.
class UserProfile {
  final String name;
  final String about;
  final String phone;
  final Uint8List? imageBytes; // works on web + mobile + desktop

  const UserProfile({
    this.name = "Your Name",
    this.about = "Hey there! I am using WhatsApp.",
    this.phone = "+92 334 421 9027",
    this.imageBytes,
  });

  UserProfile copyWith({
    String? name,
    String? about,
    String? phone,
    Uint8List? imageBytes,
    bool clearImage = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      about: about ?? this.about,
      phone: phone ?? this.phone,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
    );
  }
}

/// App-wide singleton that holds the current [UserProfile] and notifies
/// every listener (Drawer, ProfilePage, ChatScreen header, etc.) whenever
/// it changes — no need to pass data manually between screens.
class UserProfileController extends ValueNotifier<UserProfile> {
  UserProfileController._() : super(const UserProfile());

  static final UserProfileController instance = UserProfileController._();

  void update({
    String? name,
    String? about,
    String? phone,
    Uint8List? imageBytes,
    bool clearImage = false,
  }) {
    value = value.copyWith(
      name: name,
      about: about,
      phone: phone,
      imageBytes: imageBytes,
      clearImage: clearImage,
    );
  }

  /// Reset back to defaults — call this on logout if you want a clean slate.
  void reset() {
    value = const UserProfile();
  }
}