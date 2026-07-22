import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/storage/storage_helper.dart';
import '../../core/theme/colors.dart';
import 'main_layout.dart';
import 'onboarding_screen.dart';
import '../widgets/skeleton_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // Force transparent status bar with light icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Navigate to next screen after 3 seconds
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
      body: Container(
        // Dynamic vibrant Pink & Purple gradient to WOW the user on start
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryPink, AppColors.primaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Pulse Skeleton Logo
                const SkeletonLogo(
                  size: 115,
                  color: Colors.white,
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

                // App Title
                const Text(
                  'PhysioKit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0.0, delay: 400.ms),

                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'Clinical Pocket Reference',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms),

                const SizedBox(height: 60),

                // Custom styled circular loading indicator
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withAlpha(180)),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
