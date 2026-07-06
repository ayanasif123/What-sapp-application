import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid/chatcontrol.dart';
import 'package:grid/chattitle.dart';
import 'package:grid/profilepage.dart';
import 'package:grid/userfile.dart';
import 'package:grid/whatsapplog.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDark = false;
  final ChatController _chatController = ChatController.instance;

  @override
  void initState() {
    super.initState();
    // Rebuild whenever chats/messages change anywhere in the app
    // (new message sent, auto-reply received, unread count changed, etc.)
    _chatController.addListener(_onChatsChanged);
  }

  @override
  void dispose() {
    _chatController.removeListener(_onChatsChanged);
    super.dispose();
  }

  void _onChatsChanged() {
    if (mounted) setState(() {});
  }

  List get chats => _chatController.chats;

  Color get appBarColor    => _isDark ? const Color(0xFF1F2C34) : const Color(0xFF075E54);
  Color get scaffoldBg     => _isDark ? const Color(0xFF121B22) : Colors.white;
  Color get archivedBg     => _isDark ? const Color(0xFF1F2C34) : Colors.white;
  Color get archivedBorder => _isDark ? const Color(0xFF2A3942) : const Color(0xFFE0E0E0);
  Color get archivedIconBg => _isDark ? const Color(0xFF2A3942) : const Color(0xFFEEEEEE);
  Color get archivedText   => _isDark ? Colors.white : const Color(0xFF111111);
  Color get dividerColor   => _isDark ? const Color(0xFF2A3942) : const Color(0xFFE0E0E0);
  Color get emptyIconColor => _isDark ? const Color(0xFF3A4A54) : const Color(0xFFE0E0E0);
  Color get emptyTextColor => _isDark ? const Color(0xFF8696A0) : Colors.grey;
  Color get sheetBg        => _isDark ? const Color(0xFF1F2C34) : Colors.white;

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage(isDark: _isDark)),
    );
  }

  // ── Logout ─────────────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: sheetBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Log out karna hai?",
            style: TextStyle(color: archivedText, fontWeight: FontWeight.w600, fontSize: 17)),
        content: Text(
          "Aap ka account is device se log out ho jayega.",
          style: TextStyle(
            color: _isDark ? const Color(0xFF8696A0) : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: _isDark ? const Color(0xFF8696A0) : Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Log out"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Log()),
      (route) => false,
    );
  }

  // ── Drawer ─────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: sheetBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<UserProfile>(
              valueListenable: UserProfileController.instance,
              builder: (context, profile, _) {
                return Container(
                  width: double.infinity,
                  color: appBarColor,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: profile.imageBytes != null
                            ? MemoryImage(profile.imageBytes!)
                            : null,
                        child: profile.imageBytes == null
                            ? const Icon(Icons.person, color: Colors.white, size: 34)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.phone,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(
                    icon: Icons.person_outline,
                    label: "Profile",
                    onTap: () {
                      Navigator.pop(context);
                      _openProfile();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.group_add_outlined,
                    label: "New group",
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    icon: Icons.campaign_outlined,
                    label: "New broadcast",
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    icon: Icons.star_border,
                    label: "Starred messages",
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    icon: Icons.devices_outlined,
                    label: "Linked devices",
                    onTap: () => Navigator.pop(context),
                  ),
                  Divider(color: dividerColor, height: 1),
                  _drawerItem(
                    icon: Icons.settings_outlined,
                    label: "Settings",
                    onTap: () {
                      Navigator.pop(context);
                      _openProfile();
                    },
                  ),
                  _drawerItem(
                    icon: _isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    label: _isDark ? "Light mode" : "Dark mode",
                    onTap: () {
                      setState(() => _isDark = !_isDark);
                      Navigator.pop(context);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.help_outline,
                    label: "Help",
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(color: dividerColor, height: 1),
            _drawerItem(
              icon: Icons.logout,
              label: "Log out",
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                _confirmLogout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (_isDark ? const Color(0xFF00A884) : const Color(0xFF075E54)),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? archivedText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  // ── Long Press Bottom Sheet ──────────────────────────────
  void _showMessageOptions(int index) {
    final chat = chats[index];

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF3A4A54) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _isDark
                          ? const Color(0xFF2A3942)
                          : const Color(0xFF075E54).withOpacity(0.15),
                      child: Icon(
                        chat.isGroup ? Icons.group : Icons.person,
                        color: _isDark ? const Color(0xFF00A884) : const Color(0xFF075E54),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: archivedText,
                          ),
                        ),
                        Text(
                          chat.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: _isDark ? const Color(0xFF8696A0) : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Divider(color: dividerColor, height: 1),

              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: _isDark ? const Color(0xFF00A884) : const Color(0xFF075E54),
                ),
                title: Text("Message Edit Karo",
                    style: TextStyle(color: archivedText, fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(index);
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.copy_outlined,
                  color: _isDark ? const Color(0xFF00A884) : const Color(0xFF075E54),
                ),
                title: Text("Message Copy Karo",
                    style: TextStyle(color: archivedText, fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessage(index);
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text("Chat Delete Karo",
                    style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(index);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Edit Dialog ──────────────────────────────────────────
  void _showEditDialog(int index) {
    final controller = TextEditingController(text: chats[index].message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: sheetBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Message Edit Karo",
            style: TextStyle(color: archivedText, fontWeight: FontWeight.w600, fontSize: 17)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: archivedText),
          decoration: InputDecoration(
            hintText: "Naya message likho...",
            hintStyle: TextStyle(
              color: _isDark ? const Color(0xFF8696A0) : Colors.grey,
            ),
            filled: true,
            fillColor: _isDark ? const Color(0xFF2A3942) : const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          cursorColor: const Color(0xFF00A884),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: _isDark ? const Color(0xFF8696A0) : Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A884),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newMsg = controller.text.trim();
              if (newMsg.isNotEmpty) {
                _chatController.editMessageText(index, newMsg);
                Navigator.pop(context);
                _showSnackBar("✏️ Message edit ho gaya!");
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ── Copy ─────────────────────────────────────────────────
  void _copyMessage(int index) {
    Clipboard.setData(ClipboardData(text: chats[index].message));
    _showSnackBar("📋 Message copy ho gaya!");
  }

  // ── Delete Confirmation ───────────────────────────────────
  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: sheetBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Chat Delete Karo?",
            style: TextStyle(color: archivedText, fontWeight: FontWeight.w600, fontSize: 17)),
        content: Text(
          "${chats[index].name} ki chat permanently delete ho jayegi.",
          style: TextStyle(
            color: _isDark ? const Color(0xFF8696A0) : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: _isDark ? const Color(0xFF8696A0) : Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final name = chats[index].name;
              _chatController.deleteChat(index);
              Navigator.pop(context);
              _showSnackBar("🗑️ $name ki chat delete ho gayi!");
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ── SnackBar ──────────────────────────────────────────────
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: _isDark ? const Color(0xFF1F2C34) : const Color(0xFF075E54),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        drawer: _buildDrawer(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF25D366),
          elevation: 4,
          onPressed: () {},
          child: const Icon(Icons.message_rounded, color: Colors.white, size: 24),
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          title: const Text(
            "WhatsApp",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              tooltip: _isDark ? 'Light mode' : 'Dark mode',
              icon: Icon(
                _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _isDark = !_isDark),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: _isDark ? const Color(0xFF1F2C34) : Colors.white,
              onSelected: (value) {
                if (value == 'settings') _openProfile();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'new_group',
                  child: Text('New group', style: TextStyle(color: archivedText)),
                ),
                PopupMenuItem(
                  value: 'new_broadcast',
                  child: Text('New broadcast', style: TextStyle(color: archivedText)),
                ),
                PopupMenuItem(
                  value: 'starred',
                  child: Text('Starred messages', style: TextStyle(color: archivedText)),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined,
                          size: 18,
                          color: _isDark ? const Color(0xFF00A884) : const Color(0xFF075E54)),
                      const SizedBox(width: 8),
                      Text('Settings', style: TextStyle(color: archivedText)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
              tabs: const [
                Tab(text: "CHATS"),
                Tab(text: "STATUS"),
                Tab(text: "CALLS"),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // ── CHATS TAB ──────────────────────────────────
            Column(
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: archivedBg,
                      border: Border(bottom: BorderSide(color: archivedBorder)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: archivedIconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.archive_outlined,
                            color: _isDark ? const Color(0xFF00A884) : const Color(0xFF075E54),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          "Archived",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: archivedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: chats.isEmpty
                      ? Center(
                          child: Text(
                            "No chats yet",
                            style: TextStyle(color: emptyTextColor, fontSize: 15),
                          ),
                        )
                      : ListView.separated(
                          itemCount: chats.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, indent: 82, color: dividerColor),
                          itemBuilder: (context, index) {
                            return ChatTile(
                              chatIndex: index,
                              chat: chats[index],
                              isDark: _isDark,
                              onLongPress: () => _showMessageOptions(index),
                            );
                          },
                        ),
                ),
              ],
            ),

            // ── STATUS TAB ─────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle_outlined, size: 64, color: emptyIconColor),
                  const SizedBox(height: 16),
                  Text("No status updates",
                      style: TextStyle(fontSize: 16, color: emptyTextColor)),
                ],
              ),
            ),

            // ── CALLS TAB ──────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call_outlined, size: 64, color: emptyIconColor),
                  const SizedBox(height: 16),
                  Text("No recent calls",
                      style: TextStyle(fontSize: 16, color: emptyTextColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}