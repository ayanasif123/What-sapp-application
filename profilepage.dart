import 'package:flutter/material.dart';
import 'package:grid/userfile.dart';
import 'package:image_picker/image_picker.dart';


class ProfilePage extends StatefulWidget {
  final bool isDark;

  const ProfilePage({super.key, this.isDark = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool _isDark;

  // Shared controller — updating this automatically updates the Drawer too.
  final UserProfileController _profileController = UserProfileController.instance;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  // ── Theme helpers ────────────────────────────────────────
  Color get appBarColor   => _isDark ? const Color(0xFF1F2C34) : const Color(0xFF075E54);
  Color get scaffoldBg    => _isDark ? const Color(0xFF121B22) : const Color(0xFFF0F0F0);
  Color get cardBg        => _isDark ? const Color(0xFF1F2C34) : Colors.white;
  Color get primaryText   => _isDark ? Colors.white           : const Color(0xFF111111);
  Color get secondaryText => _isDark ? const Color(0xFF8696A0): Colors.grey;
  Color get dividerColor  => _isDark ? const Color(0xFF2A3942): const Color(0xFFE0E0E0);
  Color get accentGreen   => _isDark ? const Color(0xFF00A884): const Color(0xFF075E54);
  Color get avatarRingBg  => _isDark ? const Color(0xFF2A3942): const Color(0xFFD9D9D9);

  // ── Image picking ─────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (picked == null) {
        // User ne cancel kar diya, ya permission nahi mili
        debugPrint("Image pick cancelled ya permission denied");
        return;
      }

      final bytes = await picked.readAsBytes(); // web + mobile safe
      debugPrint("Image picked: ${picked.path}, size: ${bytes.length} bytes");

      _profileController.update(imageBytes: bytes); // 👈 drawer khud update ho jayega
    } catch (e) {
      debugPrint("Image pick error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image select nahi ho payi: $e")),
      );
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF3A4A54) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: accentGreen),
                title: Text("Camera se photo lo",
                    style: TextStyle(color: primaryText, fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: accentGreen),
                title: Text("Gallery se choose karo",
                    style: TextStyle(color: primaryText, fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileController.value.imageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text("Photo remove karo",
                      style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                  onTap: () {
                    Navigator.pop(context);
                    _profileController.update(clearImage: true);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Edit dialog ──────────────────────────────────────────
  void _showEditDialog(String title, String current, ValueChanged<String> onSave) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        title: Text(title, style: TextStyle(color: accentGreen, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          style: TextStyle(color: primaryText),
          cursorColor: accentGreen,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentGreen)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentGreen, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: secondaryText)),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
            },
            child: Text("SAVE", style: TextStyle(color: accentGreen, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Section card widget ──────────────────────────────────
  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          top:    BorderSide(color: dividerColor),
          bottom: BorderSide(color: dividerColor),
        ),
      ),
      child: Column(children: children),
    );
  }

  // ── Info row ─────────────────────────────────────────────
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onEdit,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: secondaryText, size: 22),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(fontSize: 12, color: accentGreen, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(value,
                          style: TextStyle(fontSize: 16, color: primaryText)),
                    ],
                  ),
                ),
                if (onEdit != null)
                  Icon(Icons.edit, color: secondaryText, size: 18),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 62, color: dividerColor),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 👇 Poori body ko listenable bana diya taake profile change hote hi UI refresh ho
      body: ValueListenableBuilder<UserProfile>(
        valueListenable: _profileController,
        builder: (context, profile, _) {
          return ListView(
            children: [
              // ── Avatar section ─────────────────────────────
              Container(
                color: cardBg,
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Avatar circle
                        Container(
                          width: 120,
                          height: 120,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: avatarRingBg,
                          ),
                          child: profile.imageBytes != null
                              ? Image.memory(
                                  profile.imageBytes!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                )
                              : Icon(
                                  Icons.person,
                                  size: 72,
                                  color: _isDark
                                      ? const Color(0xFF3A4A54)
                                      : const Color(0xFFBBBBBB),
                                ),
                        ),
                        // Camera button
                        InkWell(
                          onTap: _showImagePickerSheet,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accentGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBg, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Name under avatar
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.phone,
                      style: TextStyle(fontSize: 13, color: secondaryText),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Name & About section ────────────────────────
              _sectionCard(
                children: [
                  _infoRow(
                    icon: Icons.person_outline,
                    label: "Name",
                    value: profile.name,
                    onEdit: () => _showEditDialog(
                      "Enter your name",
                      profile.name,
                      (v) {
                        if (v.isNotEmpty) _profileController.update(name: v);
                      },
                    ),
                  ),
                  _infoRow(
                    icon: Icons.info_outline,
                    label: "About",
                    value: profile.about,
                    showDivider: false,
                    onEdit: () => _showEditDialog(
                      "About",
                      profile.about,
                      (v) {
                        if (v.isNotEmpty) _profileController.update(about: v);
                      },
                    ),
                  ),
                ],
              ),

              // ── Phone section ────────────────────────────────
              _sectionCard(
                children: [
                  _infoRow(
                    icon: Icons.phone_outlined,
                    label: "Phone",
                    value: profile.phone,
                    showDivider: false,
                    // Phone number is not editable (WhatsApp behaviour)
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}