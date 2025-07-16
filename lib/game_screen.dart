// This page will be used to crete the game screen after a game has been selected
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  final FlameGame game;
  const GameScreen({
  super.key,
  required this.game,
});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
    );
  }
}
