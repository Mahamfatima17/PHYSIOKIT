import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/learning_provider.dart';
import '../../models/special_test.dart';

class TestDetailScreen extends StatefulWidget {
  final SpecialTest test;

  const TestDetailScreen({super.key, required this.test});

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Mark as studied/viewed on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().viewTest(widget.test.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  BoxDecoration _glassDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.glassBgDark : AppColors.glassBgLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        width: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final test = widget.test;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Guide'),
        actions: [
          Consumer<LearningProvider>(
            builder: (context, provider, child) {
              final isBookmarked = provider.isBookmarked(test.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.primaryPink,
                ),
                onPressed: () {
                  provider.toggleBookmark(test.id);
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Glows for visual depth under glass elements
          Positioned(
            right: -60,
            top: 20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPink.withOpacity(isDark ? 0.08 : 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(isDark ? 0.15 : 0.06),
                    blurRadius: 80,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: 40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple.withOpacity(isDark ? 0.08 : 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(isDark ? 0.15 : 0.06),
                    blurRadius: 90,
                  )
                ],
              ),
            ),
          ),

          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card (Glassmorphic)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.glassBgDark : AppColors.glassBgLight,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildBadge(test.category, AppColors.primaryPurple),
                        const SizedBox(width: 8),
                        _buildBadge(test.region, AppColors.primaryPink),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      test.name,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      test.purpose,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryPink,
                unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                indicatorColor: AppColors.primaryPink,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Procedure', icon: Icon(Icons.accessibility)),
                  Tab(text: 'Outcome', icon: Icon(Icons.flourescent_outlined)),
                  Tab(text: 'Evidence', icon: Icon(Icons.menu_book)),
                ],
              ),
              
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProcedureTab(theme, isDark),
                    _buildOutcomeTab(theme, isDark),
                    _buildEvidenceTab(theme, isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Positions section
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: constraints.maxWidth > 400 ? cardWidth : constraints.maxWidth,
                  child: _buildInfoCard(
                    title: 'Patient Position',
                    content: widget.test.patientPosition,
                    icon: Icons.person_outline,
                    theme: theme,
                    isDark: isDark,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth > 400 ? cardWidth : constraints.maxWidth,
                  child: _buildInfoCard(
                    title: 'Therapist Position',
                    content: widget.test.therapistPosition,
                    icon: Icons.personal_injury_outlined,
                    theme: theme,
                    isDark: isDark,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        
        // Procedure Steps
        Text(
          'Step-by-Step Procedure',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.test.procedure.split('. ').map((step) {
              if (step.trim().isEmpty) return const SizedBox.shrink();
              final cleanStep = step.endsWith('.') ? step : '$step.';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.play_circle_outline, size: 18, color: AppColors.primaryPink),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cleanStep,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOutcomeTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Positive Sign
        Text(
          'Positive Sign',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassBgDark : AppColors.softPeach.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.glassBorderDark : AppColors.softPeach.withOpacity(0.75),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.primaryPink, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.test.positiveSign,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Clinical Notes / Interpretation
        Text(
          'Clinical Significance',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.test.clinicalNotes.isNotEmpty 
                          ? widget.test.clinicalNotes 
                          : 'This test isolates and stress-tests specific joint components to check for pathology.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.test.interpretation.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.analytics_outlined, color: AppColors.primaryPink, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Interpretation: ${widget.test.interpretation}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Statistical Evidence Card
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: constraints.maxWidth > 400 ? cardWidth : constraints.maxWidth,
                  child: _buildInfoCard(
                    title: 'Sensitivity',
                    content: widget.test.sensitivity,
                    icon: Icons.check_circle_outline,
                    theme: theme,
                    isDark: isDark,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth > 400 ? cardWidth : constraints.maxWidth,
                  child: _buildInfoCard(
                    title: 'Specificity',
                    content: widget.test.specificity,
                    icon: Icons.verified_outlined,
                    theme: theme,
                    isDark: isDark,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        
        // Textbook Reference
        Text(
          'Reference Source',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(isDark),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.menu_book, color: AppColors.primaryPurple, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'The Physiotherapist\'s Pocket Book',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Authors: Karen Kenyon & Jonathan Kenyon\nPublisher: Churchill Livingstone / Elsevier\nDetails: ${widget.test.reference}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryPurple),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content.isNotEmpty ? content : 'N/A',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPink,
            ),
          ),
        ],
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
