import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:project_mini_games/Game_Components/WAM/mole.dart';
import 'package:flutter/material.dart';

class WhackAMole extends FlameGame {
  late List<Mole> moles;
  late Timer spawnTimer;
  late Timer gameTimer;

  final Random random = Random();
  int score = 0;
  double timeLeft = 30.0;
  final double initialTime = 30.0;

  late TextComponent scoreText;
  late TextComponent timerText;

  bool gameOver = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Background
    final background = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..anchor = Anchor.topLeft
      ..priority = -1;
    add(background);

    await Future.delayed(Duration.zero);

    final screenWidth = size.x;
    final screenHeight = size.y;

    const gridCols = 3;
    const gridRows = 3;
    final moleSize = screenWidth / (gridCols * 6);

    final horizontalSpacing =
        (screenWidth - (gridCols * moleSize)) / (gridCols + 1);
    final verticalSpacing =
        (screenHeight - (gridRows * moleSize)) / (gridRows + 1);

    moles = List.generate(9, (i) {
      final col = i % gridCols;
      final row = i ~/ gridCols;

      final x = horizontalSpacing + col * (moleSize + horizontalSpacing);
      final y = verticalSpacing + row * (moleSize + verticalSpacing);

      final mole = Mole(
        position: Vector2(x + moleSize / 2, y + moleSize / 2),
        size: Vector2.all(moleSize),
        onWhack: () {
          if (!gameOver) {
            score++;
            scoreText.text = 'Score: $score';
          }
        },
      );

      add(mole);
      return mole;
    });

    // Score Text
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
      priority: 1,
    );
    add(scoreText);

    // Timer Text
    timerText = TextComponent(
      text: 'Time: ${initialTime.toInt()}',
      position: Vector2(size.x - 10, 10),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
      priority: 1,
    );
    add(timerText);

    // Mole Pop-up Timer
    spawnTimer = Timer(1.5, repeat: true, onTick: () {
      if (!gameOver) {
        final mole = moles[random.nextInt(moles.length)];
        mole.popUp();
      }
    });

    // Game Timer
    gameTimer = Timer(initialTime, onTick: () {
      endGame();
    });

    spawnTimer.start();
    gameTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);

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
    spawnTimer.stop();
    gameTimer.stop();
    timerText.text = 'Time: 0';
    print('Game Over! Final Score: $score');
  }

  // Public method to pause the game
  void pauseGame() {
    pauseEngine();
    spawnTimer.stop();
    gameTimer.stop();
  }

  // Public method to resume the game
  void resumeGame() {
    resumeEngine();
    if (!gameOver) {
      spawnTimer.start();
      gameTimer.start();
    }
  }

  // Public method to reset the game
  void resetGame() {
    score = 0;
    timeLeft = initialTime;
    gameOver = false;

    scoreText.text = 'Score: 0';
    timerText.text = 'Time: ${initialTime.toInt()}';

    spawnTimer.stop();
    gameTimer.stop();

    spawnTimer.start();
    gameTimer.start();

    resumeEngine(); // Also resumes the game loop
  }
}
