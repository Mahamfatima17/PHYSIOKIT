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
                  color: AppColors.primaryPurple,
                ),
                onPressed: () {
                  provider.toggleBookmark(test.id);
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.primaryLight.withOpacity(0.4),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                    _buildBadge(test.region, AppColors.info),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  test.name,
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  test.purpose,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryPurple,
            unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            indicatorColor: AppColors.primaryPurple,
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
                // Tab 1: Procedure
                _buildProcedureTab(theme, isDark),
                // Tab 2: Outcome & Notes
                _buildOutcomeTab(theme, isDark),
                // Tab 3: Evidence & Stats
                _buildEvidenceTab(theme, isDark),
              ],
            ),
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
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: 'Patient Position',
                content: widget.test.patientPosition,
                icon: Icons.person_outline,
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                title: 'Therapist Position',
                content: widget.test.therapistPosition,
                icon: Icons.personal_injury_outlined,
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Procedure Steps
        Text('Step-by-Step Procedure', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
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
                    const Icon(Icons.play_circle_outline, size: 18, color: AppColors.primaryPurple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cleanStep,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
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
        Text('Positive Sign', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.softPeach.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.softPeach.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.test.positiveSign,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Clinical Notes / Interpretation
        Text('Clinical Significance', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.test.clinicalNotes.isNotEmpty 
                          ? widget.test.clinicalNotes 
                          : 'This test isolates and stress-tests specific joint components to check for pathology.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (widget.test.interpretation.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.analytics_outlined, color: AppColors.primaryPurple, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Interpretation: ${widget.test.interpretation}',
                        style: theme.textTheme.bodyMedium,
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
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: 'Sensitivity',
                content: widget.test.sensitivity,
                icon: Icons.check_circle_outline,
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                title: 'Specificity',
                content: widget.test.specificity,
                icon: Icons.verified_outlined,
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Textbook Reference
        Text('Reference Source', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
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
                      style: theme.textTheme.bodyMedium,
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
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
                  fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w500,
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
