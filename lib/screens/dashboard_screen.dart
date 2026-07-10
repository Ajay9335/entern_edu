import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../routes/app_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, String>? _user;
  bool _loading = true;
  int _selectedIndex = 0;

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPreferences();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('pref_notifications') ?? true;
      _darkModeEnabled = prefs.getBool('pref_dark_mode') ?? false;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_notifications', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_dark_mode', value);
    setState(() => _darkModeEnabled = value);
    // Note: actual theme switching needs a ThemeMode provider at MaterialApp level.
    // For now this just persists the preference.
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  Future<void> _openEditProfile() async {
    final nameController = TextEditingController(text: _user?['fullName'] ?? '');
    final mobileController = TextEditingController(text: _user?['mobile'] ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Mobile required';
                  if (v.trim().length != 10) return 'Enter valid 10-digit number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true && _user != null) {
      final error = await AuthService.instance.updateProfile(
        email: _user!['email']!,
        fullName: nameController.text.trim(),
        mobile: mobileController.text.trim(),
      );

      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
        _loadUser();
      }
    }
  }  
  Future<void> _openChangePassword() async {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscureCurrent = true;
  bool obscureNew = true;

  final changed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentController,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmController,
                    obscureText: obscureNew,
                    decoration: const InputDecoration(labelText: 'Confirm New Password'),
                    validator: (v) {
                      if (v != newController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(ctx, true);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    },
  );

  if (changed == true && _user != null) {
    final error = await AuthService.instance.changePassword(
      email: _user!['email']!,
      currentPassword: currentController.text,
      newPassword: newController.text,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    }
  }
}

  final List<_DashboardItem> _menuItems = const [
    _DashboardItem(icon: Icons.school_outlined, label: 'My Courses', color: Color(0xFF2F80ED)),
    _DashboardItem(icon: Icons.assignment_outlined, label: 'Tasks', color: Color(0xFFF59E0B)),
    _DashboardItem(icon: Icons.emoji_events_outlined, label: 'Certificates', color: Color(0xFF10B981)),
    _DashboardItem(icon: Icons.person_outline, label: 'My Profile', color: Color(0xFF9333EA)),
    _DashboardItem(icon: Icons.notifications_none, label: 'Notifications', color: Color(0xFFEF4444)),
    _DashboardItem(icon: Icons.settings_outlined, label: 'Settings', color: Color(0xFF64748B)),
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _user?['fullName'] ?? 'Intern';
    final email = _user?['email'] ?? '';
    final mobile = _user?['mobile'] ?? '';

    final pages = [
      _buildHomeTab(name, email),
      _buildProfileTab(name, email, mobile),
      _buildSettingsTab(),
    ];

    final titles = ['Dashboard', 'My Profile', 'Settings'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        foregroundColor: const Color(0xFF1F2A44),
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _handleLogout),
        ],
      ),
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // ---------------- HOME TAB ----------------
  Widget _buildHomeTab(String name, String email) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Welcome back,', style: TextStyle(fontSize: 15, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2A44))),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'I',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text('Quick Access', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1F2A44))),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) => _DashboardCard(item: _menuItems[index]),
        ),
      ],
    );
  }

  // ---------------- PROFILE TAB ----------------
  Widget _buildProfileTab(String name, String email, String mobile) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'I',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2A44))),
        ),
        const SizedBox(height: 28),
        _ProfileInfoTile(icon: Icons.email_outlined, label: 'Email', value: email),
        const SizedBox(height: 12),
        _ProfileInfoTile(icon: Icons.phone_outlined, label: 'Mobile Number', value: mobile.isEmpty ? '-' : mobile),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppTheme.primaryColor),
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- SETTINGS TAB ----------------
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Preferences', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        _SettingsSwitchTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Receive app notifications',
          value: _notificationsEnabled,
          onChanged: _setNotifications,
        ),
        _SettingsSwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          subtitle: 'Coming soon',
          value: _darkModeEnabled,
          onChanged: _setDarkMode,
        ),
        const SizedBox(height: 24),
        const Text('Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        _SettingsActionTile(
          icon: Icons.lock_outline,
          title: 'Change Password',
          onTap: _openChangePassword,
        ),
        _SettingsActionTile(
          icon: Icons.info_outline,
          title: 'About Intern Edu',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Intern Edu',
              applicationVersion: '1.0.0',
              children: const [Text('Intern Edu mobile app — internship task project.')],
            );
          },
        ),
        _SettingsActionTile(
          icon: Icons.logout,
          title: 'Logout',
          titleColor: Colors.red,
          onTap: _handleLogout,
        ),
      ],
    );
  }
}

// ---------------- SUPPORTING WIDGETS ----------------

class _DashboardItem {
  final IconData icon;
  final String label;
  final Color color;
  const _DashboardItem({required this.icon, required this.label, required this.color});
}

class _DashboardCard extends StatelessWidget {
  final _DashboardItem item;
  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.label} tapped')));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E9F2))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2A44))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2A44))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? AppTheme.primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: titleColor ?? const Color(0xFF1F2A44))),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}