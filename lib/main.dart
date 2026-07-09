import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage/storage_helper.dart';
import 'core/theme/theme.dart';
import 'providers/learning_provider.dart';
import 'providers/theme_provider.dart';
import 'views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
