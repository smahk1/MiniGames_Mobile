import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_mini_games/Game_Components/UI/menu_overlay.dart';
import 'package:project_mini_games/Game_Components/WAM/whack_a_mole.dart';

class GameScreen extends StatefulWidget {
  final FlameGame game;

  const GameScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void dispose() {
    final wamGame = widget.game as WhackAMole;
    wamGame.pauseGame();
    wamGame.overlays.clear();
    wamGame.detach();
    print('Game instance properly disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wamGame = widget.game as WhackAMole;

    return PopScope<Object?>(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
      },
      child: Scaffold(
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
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                  );
                },
                'GameOverOverlay': (context, gameInstance) {
                  final wamGameInstance = gameInstance as WhackAMole;
                  return GameOverOverlay(
                    finalScore: wamGameInstance.score,
                    onRestart: () {
                      wamGameInstance.resetGame();
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
                  wamGame.pauseGame();
                  wamGame.overlays.add('MenuOverlay');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
