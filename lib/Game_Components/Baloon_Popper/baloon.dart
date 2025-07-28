import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:project_mini_games/Game_Components/Baloon_Popper/baloon_game.dart';
// import 'package:flame/game.dart';

class Baloon extends SpriteAnimationComponent with HasGameReference<BaloonGame>, TapCallbacks {
  final VoidCallback? onShot;
  Baloon({
    Vector2? position,
    Vector2? size,
    this.onShot,
  }): super(
          position: position ?? Vector2.zero(),
          size: size ?? Vector2.all(50),
          anchor: Anchor.center,
        );

  // Animation variables
  late final SpriteAnimation idleAnimation;

  // Position var 
  final defaultPos = Vector2(0, 0);

   @override
  Future<void> onLoad() async {
    final idleSprites = await Future.wait([
      Sprite.load('idle_baloon1.png'),
      Sprite.load('idle_baloon2.png'),
      Sprite.load('idle_baloon3.png'),
    ]);

    idleAnimation = SpriteAnimation.spriteList(idleSprites, stepTime: 1);
    animation = idleAnimation;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event); 
      // Play whack animation and sound effect
      FlameAudio.play('hit_sound_effect.mp3');
      print("Mole whacked! Starting whack animation");
      /// Once the baloon is shot we can start the pop animation and with that we can also reset the positon of the baloon to be out of sight.
      /// This way we only need to spawn or create the object once. Asstionally everytime a baloon object is spawned we do that same so that we dont ahve 
      /// create another one of it again.
      onShot?.call();
    }

  // For spawn logic
  void show() {
    // Make the baloon bisible by incressing its y pos.
  }
  // Simple method that resets the baloon to its original position
  //void _resetPos() {
  //  // Reseting the positon to defaultPos.
  //  position = defaultPos;
  //}


  }
  
