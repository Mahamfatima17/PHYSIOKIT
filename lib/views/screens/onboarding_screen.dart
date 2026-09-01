import 'package:flutter/material.dart';
import '../../core/storage/storage_helper.dart';
import '../../core/theme/colors.dart';
import 'main_layout.dart';
import '../widgets/skeleton_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Pocket Medical Library',
      description: 'Access 100+ special tests, neurological tests, and reference charts offline from your pocket textbook.',
      icon: Icons.auto_stories_outlined,
      color: AppColors.primaryLight,
    ),
    OnboardingPageData(
      title: 'Anatomical Navigation',
      description: 'Navigate tests by tapping regions on the body map. Fast, intuitive, and designed for bedside assessments.',
      icon: Icons.accessibility_new_outlined,
      color: AppColors.softPeach,
    ),
    OnboardingPageData(
      title: 'Track Your Learning',
      description: 'Save bookmarks, check history, and monitor your progress across different anatomical categories.',
      icon: Icons.insights_outlined,
      color: AppColors.mintGreen,
    ),
  ];

  void _onFinish() async {
    await StorageHelper.settingsBox.put('onboarded', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: _onFinish,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.primaryPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circle Icon Container styled beautifully in Pink/Purple
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: isDark ? page.color.withValues(alpha: 0.08) : page.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryPink.withValues(alpha: 0.2),
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: index == 0
                                ? const SkeletonLogo(size: 110)
                                : Icon(
                                    page.icon,
                                    size: 80,
                                    color: AppColors.primaryPink,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Title
                        Text(
                          page.title,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom bar with indicators and action button
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: _currentPage == index ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryPink
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  // Next / Get Started Button
                  FloatingActionButton.extended(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _onFinish();
                      }
                    },
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    label: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                    icon: Icon(_currentPage == _pages.length - 1 ? Icons.done : Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
