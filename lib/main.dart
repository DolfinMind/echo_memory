/// Echo Memory - Main Entry Point
/// A premium memory game with beautiful visuals
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/services/haptic_service.dart';
import 'core/services/storage_service.dart';

void main() {
  runZonedGuarded(
    () async {
      // Binding initialization and runApp must happen in the same zone.
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (kDebugMode) {
          debugPrint('Flutter Error: ${details.exceptionAsString()}');
          debugPrint('Stack trace:\n${details.stack}');
        }
      };

      // Initialize storage with error handling
      try {
        final storage = StorageService();
        await storage.init();
        HapticService().toggleHaptics(await storage.getHapticEnabled());
      } catch (e) {
        debugPrint('Storage initialization failed: $e');
        // Continue anyway - storage will use defaults
      }

      // Keep every orientation available for phones, tablets, and foldables.
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // Transparent system bars let Flutter handle API 36 edge-to-edge safely.
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0D0D1A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      runApp(const EchoMemoryApp());
    },
    (error, stackTrace) {
      // Handle uncaught async errors
      if (kDebugMode) {
        debugPrint('Uncaught error: $error');
        debugPrint('Stack trace:\n$stackTrace');
      }
    },
  );
}
