import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/learning_provider.dart';
import '../../models/special_test.dart';
import 'test_detail_screen.dart';

class TestLibraryScreen extends StatelessWidget {
  final String? region;
  final String? anatomicalRegion;

  const TestLibraryScreen({super.key, this.region, this.anatomicalRegion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String title = region ?? anatomicalRegion ?? 'Special Tests';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Consumer<LearningProvider>(
        builder: (context, provider, child) {
          final List<SpecialTest> tests = region != null
              ? provider.getTestsByRegion(region!)
              : (anatomicalRegion != null
                  ? provider.getTestsByAnatomicalRegion(anatomicalRegion!)
                  : provider.allTests);

          if (tests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No special tests found in this section.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              final isBookmarked = provider.isBookmarked(test.id);
              final isStudied = provider.recentHistory.any((h) => h.id == test.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
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
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Status Indicator (dot)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isStudied ? AppColors.success : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  test.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  test.purpose,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildBadge(test.category, AppColors.primaryPurple),
                                    if (region == null) ...[
                                      const SizedBox(width: 8),
                                      _buildBadge(test.region, AppColors.info),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Bookmark Button
                          IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: AppColors.primaryPurple,
                            ),
                            onPressed: () {
                              provider.toggleBookmark(test.id);
                            },
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
