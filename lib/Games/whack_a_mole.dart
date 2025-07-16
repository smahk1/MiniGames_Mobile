import 'package:flame/game.dart';
import 'package:project_mini_games/Game_Components/WAM/mole.dart';

class WhackAMole extends FlameGame {
  @override
  Future<void> onLoad() async {
    final mole = Mole(
      position: Vector2(200, 200),
      size: Vector2(64, 64),
    );
    add(mole);
  }
}