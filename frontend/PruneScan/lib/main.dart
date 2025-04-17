// main.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les caméras disponibles
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Erreur d\'initialisation des caméras: ${e.description}');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const PruneScanApp(),
    ),
  );
}

class PruneScanApp extends StatelessWidget {
  const PruneScanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'PruneScan',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}