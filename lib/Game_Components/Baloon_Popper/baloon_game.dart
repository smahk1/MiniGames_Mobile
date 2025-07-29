
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_mini_games/Game_Components/Baloon_Popper/baloon.dart';

class BaloonGame extends FlameGame{

late Timer gameTimer;

// Variables.
int score = 0;
bool gameOver = false;

// UI Components
late TextComponent scoreText;
late TextComponent timerText;

final double initialTime = 30.0;
double timeLeft = 0.0;


/// Core game logic for Balloon Popper
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

  }

  @override
  Future<void> onLoad() async {
    timeLeft = initialTime;
    // Load the background
    final bg = SpriteComponent()
      ..sprite = await loadSprite('background.png')
      ..size = size
      ..anchor = Anchor.topLeft
      ..priority = -1;
    add(bg);

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

    // Loading the baloon
    final Baloon baloon = Baloon(position: Vector2(100, 100), 
  size: Vector2.all(50),
  onShot: () {
  if (!gameOver) {
    score++;
    scoreText.text = 'Score: $score';
  }
  }
  );
  add(baloon);

  gameTimer = Timer(initialTime, onTick: endGame); // Triggers game end.
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);
    if (!gameOver) {
      timeLeft -= dt;
      if (timeLeft < 0) timeLeft = 0;

      timerText.text = 'Time: ${timeLeft.toInt()}';
    }
  }
  void resetGame(){
    // Remove game over overlay if it's showing
    overlays.remove('GameOverOverlay');
    
    score = 0;
    timeLeft = initialTime;
    gameOver = false;

    scoreText.text = 'Score: 0';
    timerText.text = 'Time: ${initialTime.toInt()}';

    resumeEngine();
    // spawnTimer..stop()..start();
    gameTimer..stop()..start();
    
    // Reset the baloon positions
  }
  void pauseGame(){
    // Game pause logic
    pauseEngine();
    // spawnTimer.stop();
    gameTimer.stop();
  }
  void resumeGame(){
    // Game resume logic
    resumeEngine();
    if (!gameOver) {
      // spawnTimer.start();
      gameTimer.start();
    }
  }
  void endGame(){
    gameOver = true;
    pauseGame();
    timerText.text = 'Time: 0';
    
    // Show game over overlay
    overlays.add('GameOverOverlay');
    // print('Game Over. Score: $score');
  }
}