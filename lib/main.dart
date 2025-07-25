import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Screens/home_page.dart';
import 'Screens/game_select_screen.dart';  // We'll make this later


void main() async {
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(MiniGames());
}

class MiniGames extends StatelessWidget {
  const MiniGames({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flame Game',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/game_select': (context) => MiniGameSelectScreen(),
  });
  }
}
