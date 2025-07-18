import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

class Mole extends SpriteAnimationComponent with TapCallbacks {
  final VoidCallback? onWhack;

  Mole({
    Vector2? size,
    Vector2? position,
    this.onWhack,
  }) : super(
          anchor: Anchor.center,
          size: size ?? Vector2(50, 50),
          position: position ?? Vector2.zero(),
        );

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation whackAnimation;

  bool canWhack = false;
  bool isVisible = false;

  double whackElapsed = 0.0;
  final double whackDuration = 0.2 * 5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final frame0 = await Sprite.load('/mole_0.png');
    final frame1 = await Sprite.load('/mole_1.png');
    final frame2 = await Sprite.load('/mole_2.png');
    final frame3 = await Sprite.load('/mole_3.png');
    final frame4 = await Sprite.load('/mole_4.png');

    idleAnimation = SpriteAnimation.spriteList([frame0], stepTime: 1.0);
    whackAnimation =
        SpriteAnimation.spriteList([frame0, frame1, frame2, frame3, frame4], stepTime: 0.2);

    animation = idleAnimation;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (canWhack) {
      animation = whackAnimation;
      whackElapsed = 0.0;
      canWhack = false;
      onWhack?.call(); // callback to notify game
      print('Whacked!');
    }
  }

  void popUp() {
    if (isVisible) return;
    isVisible = true;
    canWhack = true;

    add(
      MoveByEffect(
        Vector2(0, -40),
        EffectController(duration: 0.2),
        onComplete: () {
          Future.delayed(const Duration(milliseconds: 500), () {
            hide();
          });
        },
      ),
    );
  }

  void hide() {
    if (!isVisible) return;
    canWhack = false;

    add(
      MoveByEffect(
        Vector2(0, 40),
        EffectController(duration: 0.2),
        onComplete: () {
          isVisible = false;
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (animation == whackAnimation) {
      whackElapsed += dt;
      if (whackElapsed >= whackDuration) {
        animation = idleAnimation;
        whackElapsed = 0.0;
      }
    }
  }
}
