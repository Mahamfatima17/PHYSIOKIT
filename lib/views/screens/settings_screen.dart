import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage/storage_helper.dart';
import '../../core/theme/colors.dart';
import '../../providers/theme_provider.dart';
import 'anatomy_3d_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _textSize = StorageHelper.textSize;
  String _language = StorageHelper.language;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _uniController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = StorageHelper.userName;
    _uniController.text = StorageHelper.userUniversity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uniController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final String name = _nameController.text.trim();
    final String university = _uniController.text.trim();

    if (name.isEmpty || university.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and University fields cannot be empty!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await StorageHelper.saveProfile(name, university);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile details updated successfully!'),
          backgroundColor: AppColors.primaryPink,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear App Cache & Reset?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'This action will clear all local settings, bookmarks, clinical history logs, and free up cache memory. The app will revert to its default state. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                await StorageHelper.clearAllCache();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('App cache and user preferences cleared successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  setState(() {
                    _textSize = StorageHelper.textSize;
                    _language = StorageHelper.language;
                    _nameController.text = StorageHelper.userName;
                    _uniController.text = StorageHelper.userUniversity;
                  });
                }
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Section 1: Profile Customization
          Text(
            'Edit Profile',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  cursorColor: AppColors.primaryPink,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: AppColors.primaryPurple),
                    icon: Icon(Icons.person_outline, color: AppColors.primaryPink),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryPink),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _uniController,
                  cursorColor: AppColors.primaryPink,
                  decoration: const InputDecoration(
                    labelText: 'University / Institution',
                    labelStyle: TextStyle(color: AppColors.primaryPurple),
                    icon: Icon(Icons.school_outlined, color: AppColors.primaryPink),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryPink),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Save Profile Updates'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section 2: Display & Accessibility
          Text(
            'Display & Style',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                // Dark Mode Switch
                SwitchListTile(
                  value: themeProvider.isDarkMode,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                  title: const Text('Pastel Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Easy on eyes for night study'),
                  activeThumbColor: AppColors.primaryPink,
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryPink),
                ),
                const Divider(height: 1),
                
                // Text Size Adjust Slider
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.format_size, color: AppColors.primaryPurple),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Text Font Size',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Adjust textbook reading size: ${_textSize.toStringAsFixed(0)}sp',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _textSize,
                        min: 12.0,
                        max: 20.0,
                        divisions: 4,
                        activeColor: AppColors.primaryPink,
                        inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        onChanged: (val) {
                          setState(() {
                            _textSize = val;
                          });
                          StorageHelper.textSize = val;
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Language Dropdown
                ListTile(
                  leading: const Icon(Icons.translate, color: AppColors.primaryPurple),
                  title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_language == 'en' ? 'English (Urdu setting locked until Phase 3)' : 'Urdu'),
                  trailing: DropdownButton<String>(
                    value: _language,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ur', child: Text('Urdu (Locked)')),
                    ],
                    onChanged: (val) {
                      if (val == 'ur') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Urdu language translation will be unlocked in Phase 3.'),
                            backgroundColor: AppColors.primaryPink,
                          ),
                        );
                        return;
                      }
                      if (val != null) {
                        setState(() {
                          _language = val;
                        });
                        StorageHelper.language = val;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section 3: App Maintenance / Cache Clearing
          Text(
            'Maintenance & Optimization',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.primaryPink),
                  title: const Text('Clear App Cache & Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  subtitle: const Text('Clears memory cache, viewed history logs, and resets preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.redAccent),
                  onTap: () => _confirmClearCache(context),
                ),
                ListTile(
                  leading: const Icon(Icons.threed_rotation, color: AppColors.primaryPink),
                  title: const Text('Anatomy 3D Viewer', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Anatomy3DScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section 4: About App & References
          Text(
            'About PhysioKit',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PhysioKit Mobile App v1.0',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'This clinical utility transforms textbook procedures into native, offline-accessible modules for students and clinicians.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
                const Divider(height: 24),
                const Text(
                  'Reference Material',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on: "The Physiotherapist\'s Pocket Book - Essential Facts at Your Fingertips" (2nd Edition) by Karen Kenyon and Jonathan Kenyon.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 12),
                Text(
                  'Disclaimer: Designed for educational support. Always verify diagnosis using comprehensive clinical indicators.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: AppColors.error, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
