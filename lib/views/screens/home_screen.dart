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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Greeting
              _buildHeader(theme),
              const SizedBox(height: 24),
              
              // Mock Search Bar (Tapping switches tab to Search)
              _buildSearchBar(context, theme, isDark),
              const SizedBox(height: 24),
              
              // Continue Learning progress card
              _buildProgressCard(context, theme, isDark),
              const SizedBox(height: 28),
              
              // Interactive Body Map Heading
              Text(
                'Interactive Body Map',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a joint hotspot to view associated special tests.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              // Interactive Body Map Widget
              const InteractiveBodyMap(),
              const SizedBox(height: 32),
              
              // Major Categories List
              Text(
                'Anatomical Categories',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildCategoriesGrid(context, theme, isDark),
              const SizedBox(height: 32),
              
              // Recent / Popular Tests
              _buildRecentTestsSection(context, theme, isDark),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
            Text(
              'Future Therapist',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.primaryPurple,
                fontSize: 28,
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
          ),
          child: const Center(
            child: Icon(Icons.person, color: AppColors.primaryPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Jump to Search tab in MainLayout (tab 3)
        final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
        if (mainLayoutState != null) {
          mainLayoutState.setTab(3);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.primaryPurple),
            const SizedBox(width: 12),
            Text(
              'Search by test, condition, or joint...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.darkSurface, AppColors.darkSurface]
                  : [AppColors.primaryLight, const Color(0xFFFBF9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.primaryPurple.withOpacity(0.1),
            ),
          ),
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
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'You completed $completed of $total topics from the textbook.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress / 100.0,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
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
      _CategoryItem(name: 'Upper Limb', icon: Icons.gesture, color: AppColors.primaryLight, count: '34 Tests'),
      _CategoryItem(name: 'Lower Limb', icon: Icons.directions_walk, color: AppColors.softPeach, count: '34 Tests'),
      _CategoryItem(name: 'Spine', icon: Icons.accessibility_new, color: AppColors.mintGreen, count: '9 Tests'),
      _CategoryItem(name: 'Neurology', icon: Icons.psychology, color: AppColors.skyBlue, count: '19 Tests'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : cat.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                    Text(
                      cat.count,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
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
          // If history is empty, show some popular default tests (e.g. Lachman, Spurling, McMurray)
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
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
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
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
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
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        color: isDark ? AppColors.darkSurface : Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TestDetailScreen(test: test),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  test.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  test.purpose,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        test.region,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryPurple),
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
