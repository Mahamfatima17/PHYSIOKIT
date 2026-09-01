import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/learning_provider.dart';
import '../widgets/interactive_body_map.dart';
import 'test_detail_screen.dart';
import 'test_library_screen.dart';
import 'main_layout.dart';
import '../../models/special_test.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper method for authentic Frosted Glass containers
  BoxDecoration _glassDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.glassBgDark : AppColors.glassBgLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryPurple.withValues(alpha: isDark ? 0.05 : 0.02),
          blurRadius: 15,
          spreadRadius: 1,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND GLOW EFFECTS (Creates visual depth behind glass layers)
          Positioned(
            left: -100,
            top: 50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPink.withValues(alpha: isDark ? 0.12 : 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: isDark ? 0.2 : 0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: 300,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple.withValues(alpha: isDark ? 0.12 : 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: isDark ? 0.2 : 0.1),
                    blurRadius: 110,
                    spreadRadius: 20,
                  )
                ],
              ),
            ),
          ),

          // 2. MAIN SCROLL VIEW
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header & Greeting
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  
                  // Mock Search Bar (Glassmorphic)
                  _buildSearchBar(context, theme, isDark),
                  const SizedBox(height: 24),
                  
                  // Continue Learning progress card (Glassmorphic)
                  _buildProgressCard(context, theme, isDark),
                  const SizedBox(height: 28),
                  
                  // Interactive Body Map Heading
                  Text(
                    'Interactive Body Map',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap a joint hotspot to view associated special tests.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  
                  // Interactive Body Map Widget
                  const InteractiveBodyMap(),
                  const SizedBox(height: 32),
                  
                  // Major Categories List
                  Text(
                    'Anatomical Categories',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoriesGrid(context, theme, isDark),
                  const SizedBox(height: 32),
                  
                  // Recent / Popular Tests
                  _buildRecentTestsSection(context, theme, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Future Therapist',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryPink,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.4),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.2), width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.person, color: AppColors.primaryPink, size: 26),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
        if (mainLayoutState != null) {
          mainLayoutState.setTab(3);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _glassDecoration(isDark),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.primaryPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search by test, condition, or joint...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<LearningProvider>(
      builder: (context, provider, child) {
        final progress = provider.learningProgressPercentage;
        final completed = provider.completedTestsCount;
        final total = provider.totalTestsCount;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _glassDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Learning Progress',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'You completed $completed of $total topics from the textbook.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress / 100.0,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, ThemeData theme, bool isDark) {
    final categories = [
      _CategoryItem(name: 'Upper Limb', icon: Icons.gesture, color: AppColors.primaryLight.withValues(alpha: 0.55), count: '34 Tests'),
      _CategoryItem(name: 'Lower Limb', icon: Icons.directions_walk, color: AppColors.softPeach.withValues(alpha: 0.55), count: '34 Tests'),
      _CategoryItem(name: 'Spine', icon: Icons.accessibility_new, color: const Color(0xFFECFDF5).withValues(alpha: 0.55), count: '9 Tests'),
      _CategoryItem(name: 'Neurology', icon: Icons.psychology, color: AppColors.skyBlue.withValues(alpha: 0.55), count: '19 Tests'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.35,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TestLibraryScreen(anatomicalRegion: cat.name),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassBgDark : cat.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(cat.icon, color: AppColors.primaryPurple, size: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat.count,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTestsSection(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<LearningProvider>(
      builder: (context, provider, child) {
        final recent = provider.recentHistory;
        if (recent.isEmpty) {
          final popular = provider.allTests.where((t) =>
            t.name.contains('Lachman') || 
            t.name.contains('Spurling') || 
            t.name.contains('McMurray')
          ).toList();

          if (popular.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Special Tests',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 135,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: popular.length,
                  itemBuilder: (context, index) {
                    final test = popular[index];
                    return _buildTestCard(context, test, theme, isDark);
                  },
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recently Studied',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 135,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recent.length,
                itemBuilder: (context, index) {
                  final test = recent[index];
                  return _buildTestCard(context, test, theme, isDark);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestCard(BuildContext context, SpecialTest test, ThemeData theme, bool isDark) {
    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        decoration: _glassDecoration(isDark),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TestDetailScreen(test: test),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  test.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    test.purpose,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        test.region,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryPink),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final String count;

  _CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
  });
}
