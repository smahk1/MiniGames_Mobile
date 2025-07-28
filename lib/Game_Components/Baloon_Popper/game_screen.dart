import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_mini_games/Game_Components/Baloon_Popper/baloon_game.dart';
import 'package:project_mini_games/Game_Components/UI/menu_overlay.dart';

class BaloonGameScreen extends StatefulWidget {
  final FlameGame game;

  const BaloonGameScreen({super.key, required this.game});

  @override
  State<BaloonGameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<BaloonGameScreen> {
  // Function called to dispose/end the game instance
  //@override
  //void dispose() {
  //  final baloonGame = widget.game as BaloonGame;
  //  // Pause the game
  //  // Clear overlays
  //  // Detach the game nstance
  //}

  @override
  Widget build(BuildContext context) {
    final baloonGame = widget.game as BaloonGame;

    return PopScope<Object?>(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: baloonGame,
              overlayBuilderMap: {
                'MenuOverlay': (context, gameInstance) {
                  final baloonGameInstance = gameInstance as BaloonGame;
                  return MenuOverlay(
                    onResume: () {
                      baloonGameInstance.resumeGame();
                      baloonGameInstance.overlays.remove('MenuOverlay');
                    },
                    onRestart: () {
                      baloonGameInstance.resetGame();
                      baloonGameInstance.overlays.remove('MenuOverlay');
                    },
                    onGoHome: () {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                  );
                },
                'GameOverOverlay': (context, gameInstance) {
                  final baloonGameInstance = gameInstance as BaloonGame;
                  return GameOverOverlay(
                    finalScore: baloonGameInstance.score,
                    onRestart: () {
                      baloonGameInstance.resetGame();
                    },
                    onGoHome: () {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                  );
                },
              },
            ),
            Positioned(
              top: 30,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.pause, color: Colors.white, size: 30),
                onPressed: () {
                  baloonGame.pauseGame();
                  baloonGame.overlays.add('MenuOverlay');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}