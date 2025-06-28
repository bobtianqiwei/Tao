import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/game_screen.dart';
import 'providers/game_provider.dart';

void main() {
  runApp(const WuxingGameApp());
}

class WuxingGameApp extends StatelessWidget {
  const WuxingGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return MaterialApp(
            title: '道',
            theme: _buildTheme(gameProvider.isDarkMode),
            home: const GameScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(bool isDarkMode) {
    return ThemeData(
      primarySwatch: Colors.grey,
      fontFamily: 'OPPOSans',
      useMaterial3: false,
      scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontWeight: FontWeight.w300),
        bodyMedium: TextStyle(fontWeight: FontWeight.w300),
        bodySmall: TextStyle(fontWeight: FontWeight.w300),
        titleLarge: TextStyle(fontWeight: FontWeight.w300),
        titleMedium: TextStyle(fontWeight: FontWeight.w300),
        titleSmall: TextStyle(fontWeight: FontWeight.w300),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    );
  }
} 