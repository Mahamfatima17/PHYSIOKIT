import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/colors.dart';

class Anatomy3DScreen extends StatelessWidget {
  const Anatomy3DScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('3D Anatomy Atlas')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryPurple.withValues(alpha: 0.12)
                      : AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.view_in_ar_outlined,
                  size: 56,
                  color: AppColors.primaryPurple,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              Text(
                '3D Anatomy Viewer',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              const SizedBox(height: 12),
              Text(
                'Interactive 3D anatomy models are coming in the next update. '
                'For now, use the Interactive Body Map on the Home screen to navigate by region.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'Coming in Phase 2',
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
