import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/learning_provider.dart';
import 'test_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  final int initialTabIndex;
  const BookmarksScreen({super.key, this.initialTabIndex = 0});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved & History'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryPink,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primaryPink,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Favorites', icon: Icon(Icons.bookmark)),
            Tab(text: 'Recent History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesTab(context, theme, isDark),
          _buildHistoryTab(context, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<LearningProvider>(
      builder: (context, provider, child) {
        final favorites = provider.getBookmarkedTests();

        if (favorites.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks saved yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon in any test details to save.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final test = favorites[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                elevation: 0,
                child: ListTile(
                  title: Text(
                    test.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    test.purpose,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      provider.toggleBookmark(test.id);
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TestDetailScreen(test: test),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<LearningProvider>(
      builder: (context, provider, child) {
        final history = provider.recentHistory;

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_outlined,
                  size: 64,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recently viewed tests.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: TextButton.icon(
                  onPressed: () {
                    provider.clearHistory();
                  },
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.error),
                  label: const Text('Clear History', style: TextStyle(color: AppColors.error)),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final test = history[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      elevation: 0,
                      child: ListTile(
                        leading: const Icon(Icons.history, color: AppColors.primaryPink),
                        title: Text(
                          test.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          test.purpose,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TestDetailScreen(test: test),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
