// screens/mini_game_select_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_mini_games/Game_Components/WAM/whack_a_mole.dart';
import 'package:project_mini_games/Game_Components/WAM/game_screen.dart';

class MiniGameSelectScreen extends StatelessWidget {
  const MiniGameSelectScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Game'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            // Reset to portrait mode when going back
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            if (context.mounted) {
              Navigator.pop(context); // Go back to Home
            }
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Whack a Mole"),
            onTap: () {
              if (context.mounted) {
                // Create a completely fresh game instance every time
                final freshGame = WhackAMole();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(game: freshGame),
                  ),
                );
              }
            },
          ),
          ListTile(
            title: Text("Another Game"),
            onTap: ()  {
              if (context.mounted) {
                // Create a completely fresh game instance every time
                final freshGame = WhackAMole();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(game: freshGame),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}