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
    Future.delayed(const Duration(seconds: 3), _navigateToNext);
  }

  void _navigateToNext() {
    if (!mounted) return;
    final bool onboarded =
        StorageHelper.settingsBox.get('onboarded', defaultValue: false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            onboarded ? const MainLayout() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(77), width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services_rounded,
                  size: 55,
                  color: Colors.white,
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 500.ms),
            const SizedBox(height: 28),
            const Text(
              'PhysioKit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0.0, delay: 400.ms),
            const SizedBox(height: 10),
            const Text(
              'Clinical Pocket Reference',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
            const SizedBox(height: 60),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white.withAlpha(180)),
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}
