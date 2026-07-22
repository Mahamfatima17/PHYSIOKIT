import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage/storage_helper.dart';
import 'core/theme/theme.dart';
import 'providers/learning_provider.dart';
import 'providers/theme_provider.dart';
import 'views/screens/splash_screen.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Catch Flutter widget tree rendering / layout errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint("Captured Flutter Error: ${details.exception}");
    };

    // 2. Catch platform/native asynchronous task failures globally (prevents 'stopped working' dialog)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint("Captured Asynchronous Task Error: $error");
      return true; // Return true to mark exception as handled and suppress crash dialog
    };

    await StorageHelper.init();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LearningProvider()),
        ],
        child: const PhysioKitApp(),
      ),
    );
  }, (error, stack) {
    debugPrint("Captured Unhandled Thread/Zone Error: $error");
  });
}

class PhysioKitApp extends StatelessWidget {
  const PhysioKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'PhysioKit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
