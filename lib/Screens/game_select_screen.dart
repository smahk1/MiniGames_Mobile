// screens/mini_game_select_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_mini_games/Game_Components/Baloon_Popper/baloon_game.dart';
import 'package:project_mini_games/Game_Components/Baloon_Popper/game_screen.dart';
import 'package:project_mini_games/Game_Components/WAM/whack_a_mole.dart';
import 'package:project_mini_games/Game_Components/WAM/game_screen.dart';
import 'package:project_mini_games/Screens/camera_test.dart';

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
                    builder: (_) => WamGameScreen(game: freshGame),
                  ),
                );
              }
            },
          ),
          ListTile(
            title: Text("Baloon Popper"),
            onTap: ()  {
              if (context.mounted) {
                // Create a completely fresh game instance every time
                final freshGame = BaloonGame();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BaloonGameScreen(game: freshGame),
                  ),
                );
              }
            },
          ),
          ListTile(
            title: Text("Emotion Detection"),
            subtitle: Text("Real-time emotion recognition"),
            leading: Icon(Icons.mood),
            onTap: () {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmotionDetectionPage(),
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