import 'package:flutter/material.dart';
import 'home_page.dart';
import 'game_page.dart';  // We'll make this later
import 'MiniGame1.dart'; // For the first mini-game test 2


void main() {
  runApp(MiniGames());
}

class MiniGames extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flame Game',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/game': (context) => GamePage(),
        '/MG1': (context) => GamePage(), // Placeholder for now
      },
    );
  }
}
