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
      child: MaterialApp(
        title: '五行2048',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'NotoSansSC',
          useMaterial3: true,
        ),
        home: const GameScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 