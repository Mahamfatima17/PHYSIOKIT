import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/learning_provider.dart';
import 'test_library_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<_RegionCategory> categories = [
      _RegionCategory(name: 'Cervical spine', displayName: 'Cervical Spine', icon: Icons.airline_seat_recline_normal, testsCount: 2),
      _RegionCategory(name: 'Shoulder', displayName: 'Shoulder Joint', icon: Icons.gesture, testsCount: 23),
      _RegionCategory(name: 'Elbow', displayName: 'Elbow Joint', icon: Icons.rotate_left, testsCount: 8),
      _RegionCategory(name: 'Wrist and hand', displayName: 'Wrist & Hand', icon: Icons.back_hand_outlined, testsCount: 11),
      _RegionCategory(name: 'Pelvis', displayName: 'Pelvis & SIJ', icon: Icons.airline_seat_flat_angled, testsCount: 7),
      _RegionCategory(name: 'Hip', displayName: 'Hip Joint', icon: Icons.directions_walk, testsCount: 9),
      _RegionCategory(name: 'Knee', displayName: 'Knee Joint', icon: Icons.accessibility, testsCount: 15),
      _RegionCategory(name: 'Ankle and foot', displayName: 'Ankle & Foot', icon: Icons.directions_run, testsCount: 3),
      _RegionCategory(name: 'Common vascular tests', displayName: 'Vascular Tests', icon: Icons.favorite_border, testsCount: 7),
      _RegionCategory(name: 'Neurology', displayName: 'Neurology Section', icon: Icons.psychology, testsCount: 19, isSpecialSection: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anatomical Regions'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          
          return Consumer<LearningProvider>(
            builder: (context, provider, child) {
              final double progress = cat.isSpecialSection
                  ? provider.getAnatomicalRegionProgress('neurology')
                  : provider.getRegionProgress(cat.name);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => cat.isSpecialSection
                              ? const TestLibraryScreen(anatomicalRegion: 'Neurology')
                              : TestLibraryScreen(region: cat.name),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Round Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat.icon, color: AppColors.primaryPurple),
                          ),
                          const SizedBox(width: 16),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.displayName,
                                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${cat.testsCount} Tests | ${progress.toStringAsFixed(0)}% Completed',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress / 100.0,
                                    minHeight: 4,
                                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primaryPurple,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RegionCategory {
  final String name;
  final String displayName;
  final IconData icon;
  final int testsCount;
  final bool isSpecialSection;

  _RegionCategory({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.testsCount,
    this.isSpecialSection = false,
  });
}
