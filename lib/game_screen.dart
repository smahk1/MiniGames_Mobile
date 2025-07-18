import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_mini_games/Game_Components/UI/menu_overlay.dart';
import 'package:project_mini_games/Games/whack_a_mole.dart';

class GameScreen extends StatelessWidget {
  final FlameGame game;

  const GameScreen({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final wamGame = game as WhackAMole;

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: wamGame,
            overlayBuilderMap: {
              'MenuOverlay': (context, gameInstance) {
                final wamGameInstance = gameInstance as WhackAMole;
                return MenuOverlay(
                  onResume: () {
                    wamGameInstance.resumeGame();
                    wamGameInstance.overlays.remove('MenuOverlay');
                  },
                  onRestart: () {
                    wamGameInstance.resetGame();
                    wamGameInstance.overlays.remove('MenuOverlay');
                  },
                  onGoHome: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                );
              },
            },
          ),

          // Pause Button (Top-right)
          Positioned(
            top: 30,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.white, size: 30),
              onPressed: () {
                wamGame.pauseGame();
                wamGame.overlays.add('MenuOverlay');
              },
            ),
          ),
        ],
      ),
    );
  }
}
