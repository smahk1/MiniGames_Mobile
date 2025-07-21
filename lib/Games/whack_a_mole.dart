import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project_mini_games/Game_Components/WAM/mole.dart';

class WhackAMole extends FlameGame {
  final List<Vector2> molePositions = [
    Vector2(100, 350),
    Vector2(220, 370),
    Vector2(340, 360),
    Vector2(460, 380),
    Vector2(580, 370),
    Vector2(700, 390),
  ];
  // Decides how many moles to animate at once
  int animateNum = 2; // For every increment of 1 in [animateNum] decrement the value of [count] in spawnTimer() by 1

  final Random rng = Random();
  final double initialTime = 30.0;

  late List<Mole> moles;
  late Timer spawnTimer;
  late Timer gameTimer;

  late TextComponent scoreText;
  late TextComponent timerText;

  int score = 0;
  double timeLeft = 0.0;
  bool gameOver = false;

  @override
  Future<void> onLoad() async {
    final bg = SpriteComponent()
      ..sprite = await loadSprite('background.png')
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

    // Spawn moles manually by mapping each mole to its position in predefined vector list.
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
    // This ensures that we dont try to display more moles than are available
    final count = animateNum.clamp(0, inactiveMoles.length);
    // For every increment of 1 in [animateNum] decrement the value of [count] by 1
    // God knows why this works, but it does.
     for (int i = 0; i < count-1; i++) {
      inactiveMoles[i].show();
    }
  }
}, repeat: true);

    gameTimer = Timer(initialTime, onTick: endGame); // Ends the game when time runs out. The first value defines the time limit for the time.

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

      timeLeft -= dt;   // Since time left is a double value it stores only the whole number values of dt in seconds.
      if (timeLeft < 0) timeLeft = 0;

      timerText.text = 'Time: ${timeLeft.toInt()}';
    }
  }
  // Triggers game over screen and haults the game.
  void endGame() {
    gameOver = true;
    spawnTimer.stop();
    gameTimer.stop();
    timerText.text = 'Time: 0';
    print('Game Over. Score: $score');
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
    score = 0;
    timeLeft = initialTime;
    gameOver = false;

    scoreText.text = 'Score: 0';
    timerText.text = 'Time: ${initialTime.toInt()}';

    resumeEngine();
    spawnTimer..stop()..start();
    gameTimer..stop()..start();
  }
}
