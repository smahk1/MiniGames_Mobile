// screens/mini_game_select_screen.dart
import 'package:flutter/material.dart';
import 'package:project_mini_games/Games/whack_a_mole.dart';
import 'package:project_mini_games/game_screen.dart';


class MiniGameSelectScreen extends StatelessWidget {
  const MiniGameSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    title: Text('Select a Game'),
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context); // Go back to Home
      },
    ),
  ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Click Game"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(game: WhackAMole()),
                ),
              );
            },
          ),
          ListTile(
            title: Text("Another Game"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(game: WhackAMole()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
