import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/storage/storage_helper.dart';
import '../../providers/learning_provider.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String name = StorageHelper.userName;
    final String university = StorageHelper.userUniversity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Consumer<LearningProvider>(
          builder: (context, provider, child) {
            final progress = provider.learningProgressPercentage;
            final completed = provider.completedTestsCount;
            final total = provider.totalTestsCount;
            
            // Generate list of achievements dynamically
            final List<BadgeData> badges = _generateBadges(provider);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Information Header Card
                _buildProfileHeader(theme, isDark, name, university),
                const SizedBox(height: 24),
                
                // Statistics Grid
                _buildStatsGrid(theme, isDark, completed, total, progress),
                const SizedBox(height: 28),
                
                // Achievements Badges Section
                Text(
                  'Unlocked Badges',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                badges.isEmpty
                    ? _buildEmptyBadgesCard(theme, isDark)
                    : _buildBadgesRow(badges, isDark),
                const SizedBox(height: 28),
                
                // Quick shortcuts
                Text(
                  'Quick Navigation',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildShortcuts(context, theme, isDark),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDark, String name, String university) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryPink.withOpacity(0.2), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.school, size: 36, color: AppColors.primaryPink),
            ),
          ),
          const SizedBox(width: 16),
          // User text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  university,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryPink.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'Doctor of Physical Therapy (DPT)',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, bool isDark, int completed, int total, double progress) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Completed',
            value: '$completed/$total',
            subtitle: 'Special tests studied',
            icon: Icons.check_circle_outline,
            color: AppColors.primaryPurple,
            isDark: isDark,
            theme: theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Percentage',
            value: '${progress.toStringAsFixed(0)}%',
            subtitle: 'Learning completed',
            icon: Icons.pie_chart_outline,
            color: AppColors.primaryPink,
            isDark: isDark,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  List<BadgeData> _generateBadges(LearningProvider provider) {
    final List<BadgeData> list = [];
    
    // Quick starter: completed at least 1 test
    if (provider.completedTestsCount >= 1) {
      list.add(BadgeData(
        title: 'Quick Starter',
        description: 'First test completed',
        icon: Icons.local_fire_department,
        color: Colors.orange,
      ));
    }
    
    // Knee Specialist: completed Knee tests
    final kneeProgress = provider.getRegionProgress('Knee');
    if (kneeProgress >= 100.0) {
      list.add(BadgeData(
        title: 'Knee Specialist',
        description: 'Completed Knee tests',
        icon: Icons.accessibility,
        color: Colors.pink,
      ));
    }

    // Spine Specialist: completed Cervical tests
    final cervicalProgress = provider.getRegionProgress('Cervical spine');
    if (cervicalProgress >= 100.0) {
      list.add(BadgeData(
        title: 'Spine Explorer',
        description: 'Completed Cervical tests',
        icon: Icons.airline_seat_recline_normal,
        color: Colors.purple,
      ));
    }

    // Neurology Expert: completed Neurology
    final neuroProgress = provider.getAnatomicalRegionProgress('Neurology');
    if (neuroProgress >= 100.0) {
      list.add(BadgeData(
        title: 'Neuro Expert',
        description: 'Completed Neurology tests',
        icon: Icons.psychology,
        color: Colors.deepPurple,
      ));
    }

    // Dedicated Learner: completed 15+ tests
    if (provider.completedTestsCount >= 15) {
      list.add(BadgeData(
        title: 'Dedicated DPT',
        description: 'Completed 15+ tests',
        icon: Icons.workspace_premium,
        color: Colors.amber,
      ));
    }

    return list;
  }

  Widget _buildEmptyBadgesCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.lock_outline, size: 36, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            const SizedBox(height: 12),
            Text(
              'No badges unlocked yet.',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete all tests in any region to unlock specialists badges.',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow(List<BadgeData> badges, bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(badge.icon, color: badge.color, size: 28),
                const SizedBox(height: 8),
                Text(
                  badge.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  badge.description,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShortcuts(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      children: [
        _buildListButton(
          title: 'My Bookmarks',
          subtitle: 'View saved special tests',
          icon: Icons.bookmark,
          color: AppColors.primaryPink,
          isDark: isDark,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BookmarksScreen()),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildListButton(
          title: 'History log',
          subtitle: 'Check recently viewed topics',
          icon: Icons.history,
          color: AppColors.primaryPurple,
          isDark: isDark,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BookmarksScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildListButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}

class BadgeData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  BadgeData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
