import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/storage/storage_helper.dart';
import '../../core/theme/colors.dart';
import 'main_layout.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Wait for 3 seconds of splash animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Check onboarding status
    final bool onboarded = StorageHelper.settingsBox.get('onboarded', defaultValue: false);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => onboarded ? const MainLayout() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.light
                ? [AppColors.primaryLight, Colors.white]
                : [AppColors.darkBg, AppColors.darkSurface],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Pulse Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: 50,
                    color: AppColors.primaryPurple,
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1200.ms, curve: Curves.easeInOut)
                   .then()
                   .tint(color: AppColors.primaryPurple.withOpacity(0.8)),
                ),
              ),
              const SizedBox(height: 24),
              // App Name Text
              Text(
                'PhysioKit',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: AppColors.primaryPurple,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0.0),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Interactive Physiotherapy reference',
                style: theme.textTheme.bodyMedium,
              ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
