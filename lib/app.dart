/// Echo Memory - App Configuration
/// Main app widget with theme and routing
library;

import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';

class EchoMemoryApp extends StatelessWidget {
  const EchoMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo Memory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
