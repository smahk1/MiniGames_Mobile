import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project_mini_games/Game_Components/WAM/mole.dart';

class WhackAMole extends FlameGame{
  // Define mole positions as relative percentages of screen dimensions
  // Format: [x percentage (0.0-1.0), y percentage (0.0-1.0)]
  final List<List<double>> moleRelativePositions = [
    [0.15, 0.4],   // Left side, upper middle
    [0.35, 0.44],  // Left-center, slightly lower
    [0.55, 0.41],  // Right-center, middle
    [0.75, 0.43],  // Right side, slightly lower
    [0.25, 0.6],   // Left-center, lower
    [0.65, 0.62],  // Right-center, lower
  ];

  // This will store the actual calculated positions
  late List<Vector2> molePositions;
  
  // Decides how many moles to animate at once
  int animateNum = 2;

  final Random rng = Random();
  final double initialTime = 30.0;

  List<Mole> moles = [];
  late Timer spawnTimer;
  late Timer gameTimer;

  late TextComponent scoreText;
  late TextComponent timerText;

  int score = 0;
  double timeLeft = 0.0;
  bool gameOver = false;

  @override 
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Games dimensions
    const double gameWidth = 540;
    const double gameHeight = 960;
    
    // Scale calculation to fit the game within the screen
    double scaleX = size.x / gameWidth;
    double scaleY = size.y / gameHeight;
    
    // Using smaller scale to fit the game
    double scale = scaleX < scaleY ? scaleX : scaleY;
    
    // Reset camera zoom to avoid accumulation
    camera.viewfinder.zoom = scale;
    
    // Center the game on screen
    camera.viewfinder.position = Vector2.zero();

    // Recalculate mole positions based on new screen size
    _calculateMolePositions();
    
    // Update existing mole positions if they exist
    if (moles.isNotEmpty) {
      for (int i = 0; i < moles.length && i < molePositions.length; i++) {
        moles[i].position = molePositions[i];
      }
    }
  }

  void _calculateMolePositions() {
    // Calculate actual positions based on current screen size
    molePositions = moleRelativePositions.map((relativePos) {
      double x = size.x * relativePos[0];
      double y = size.y * relativePos[1];
      return Vector2(x, y);
    }).toList();
  }

  @override
  Future<void> onLoad() async {
    // Calculate initial mole positions
    _calculateMolePositions();

    final bg = SpriteComponent()
      ..sprite = await loadSprite('background2.jpg')
      ..size = size
      ..anchor = Anchor.topLeft
      ..priority = -1;
    add(bg);

    timeLeft = initialTime;

    // Score & Timer UI
    scoreText = TextComponent(
      text: 'Score: 0',
      anchor: Anchor.topLeft,
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
    add(scoreText);

    timerText = TextComponent(
      text: 'Time: ${initialTime.toInt()}',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
    add(timerText);

    // Spawn moles using calculated positions
    moles = molePositions.map((pos) {
      final mole = Mole(
        position: pos,
        whackFrameRange: [4, 6], 
        size: Vector2.all(80),
        onWhack: () {
          if (!gameOver) {
            score++;
            scoreText.text = 'Score: $score';
          }
        },
      );
      add(mole);
      return mole;
    }).toList();

    spawnTimer = Timer(0.2, onTick: () {
      if (gameOver) return;

      final activeMoles = moles.where((m) => m.isVisible).toList();

      if (activeMoles.length < animateNum) {
        final inactiveMoles = moles.where((m) => !m.isVisible && !m.isCoolingDown).toList();
        inactiveMoles.shuffle();
        final count = (animateNum - activeMoles.length).clamp(0, inactiveMoles.length);
        
        for (int i = 0; i < count; i++) {
          inactiveMoles[i].show();
        }
      }
    }, repeat: true);

    gameTimer = Timer(initialTime, onTick: endGame);

    // Start both timers
    spawnTimer.start();
    gameTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Updating timers
    if (!gameOver) {
      spawnTimer.update(dt);
      gameTimer.update(dt);

      timeLeft -= dt;
      if (timeLeft < 0) timeLeft = 0;

      timerText.text = 'Time: ${timeLeft.toInt()}';
    }
  }

  void endGame() {
    gameOver = true;
    pauseGame();
    timerText.text = 'Time: 0';
    
    // Show game over overlay
    overlays.add('GameOverOverlay');
    // print('Game Over. Score: $score');
  }

  void pauseGame() {
    pauseEngine();
    spawnTimer.stop();
    gameTimer.stop();
  }

  void resumeGame() {
    resumeEngine();
    if (!gameOver) {
      spawnTimer.start();
      gameTimer.start();
    }
  }

  void resetGame() {
    // Remove game over overlay if it's showing
    overlays.remove('GameOverOverlay');
    
    score = 0;
    timeLeft = initialTime;
    gameOver = false;

    scoreText.text = 'Score: 0';
    timerText.text = 'Time: ${initialTime.toInt()}';

    // Reset all moles to their initial state
    for (final mole in moles) {
      mole.resetMole();
    }

    resumeEngine();
    spawnTimer..stop()..start();
    gameTimer..stop()..start();
    
    // print('Game restarted!');
  }
}