import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage/storage_helper.dart';
import '../../core/theme/colors.dart';
import '../../providers/theme_provider.dart';

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
    if (_nameController.text.isNotEmpty) {
      StorageHelper.userName = _nameController.text;
    }
    if (_uniController.text.isNotEmpty) {
      StorageHelper.userUniversity = _uniController.text;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile details updated successfully!'),
        backgroundColor: AppColors.primaryPurple,
      ),
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
          Text('Edit Profile', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    icon: Icon(Icons.person_outline, color: AppColors.primaryPurple),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _uniController,
                  decoration: const InputDecoration(
                    labelText: 'University / Institution',
                    icon: Icon(Icons.school_outlined, color: AppColors.primaryPurple),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
          Text('Display & Style', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                  title: const Text('Pastel Dark Mode'),
                  subtitle: const Text('Easy on eyes for night study'),
                  activeColor: AppColors.primaryPurple,
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryPurple),
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
                        activeColor: AppColors.primaryPurple,
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
                  title: const Text('App Language'),
                  subtitle: Text(_language == 'en' ? 'English (Urdu setting locked until Phase 3)' : 'Urdu'),
                  trailing: DropdownButton<String>(
                    value: _language,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ur', child: Text('Urdu (Locked)')),
                    ],
                    onChanged: (val) {
                      if (val == 'ur') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Urdu language translation will be unlocked in Phase 3.'),
                            backgroundColor: AppColors.primaryPurple,
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

          // Section 3: About App & References
          Text('About PhysioKit', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                  style: theme.textTheme.bodyMedium,
                ),
                const Divider(height: 24),
                const Text(
                  'Reference Material',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on: "The Physiotherapist\'s Pocket Book - Essential Facts at Your Fingertips" (2nd Edition) by Karen Kenyon and Jonathan Kenyon.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                Text(
                  'Disclaimer: Designed for educational support. Always verify diagnosis using comprehensive clinical indicators.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: AppColors.error),
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
