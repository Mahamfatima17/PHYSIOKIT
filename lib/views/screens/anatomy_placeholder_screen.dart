import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/colors.dart';

class AnatomyPlaceholderScreen extends StatelessWidget {
  const AnatomyPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive 3D Anatomy'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D Teaser Animated Graphic Group
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glowing rings
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        width: 2.0,
                      ),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2.seconds),
                  
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(begin: const Offset(1.05, 1.05), end: const Offset(0.95, 0.95), duration: 2.seconds),

                  // Center circular container holding medical skeleton illustration icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.view_in_ar,
                        size: 56,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(begin: 0, end: 1, duration: 8.seconds),
                  
                  // Orbiting glowing indicator dots (joint simulation)
                  Positioned(
                    top: 20,
                    left: 40,
                    child: _buildGlowingNode(Colors.orange),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 40,
                    child: _buildGlowingNode(AppColors.success),
                  ),
                  Positioned(
                    bottom: 120,
                    left: 20,
                    child: _buildGlowingNode(AppColors.info),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              
              // Teaser Headlines
              Text(
                'Phase 2: 3D Body Systems',
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0.0),
              const SizedBox(height: 8),
              
              Text(
                'Interactive zoom, rotate, and selection of deep tissues, skeletal surfaces, and nerve pathways.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 32),
              
              // Glassmorphic Info Card showing upcoming features
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.layers_outlined, color: AppColors.primaryPurple, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Anatomy Models & Layers',
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(Icons.check_circle_outline, 'Full 3D Skeleton (Zoom, Pan, Rotate)'),
                    _buildFeatureRow(Icons.check_circle_outline, 'Muscle Attachments (Origin, Insertion, Action)'),
                    _buildFeatureRow(Icons.check_circle_outline, 'Ligament Integrity Maps (ACL, PCL, LCL, MCL)'),
                    _buildFeatureRow(Icons.check_circle_outline, 'Active Nerves & Dermatome/Myotome Overlays'),
                    const Divider(height: 24),
                    const Center(
                      child: Text(
                        'Unlock in Phase 2 Development',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.1, end: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowingNode(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: 1200.ms);
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
