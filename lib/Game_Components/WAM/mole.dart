import 'package:flame/components.dart';
// import 'dart:ui';
import 'package:flame/events.dart';

class Mole extends SpriteAnimationComponent with TapCallbacks {
  Mole({
    Vector2? size,
    Vector2? position,
  }) : super(
         anchor: Anchor.center, // This determines around what a sprite will be drawn
         size: size ?? Vector2(50, 50),
         position: position ?? Vector2.zero(),
       );

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation whackAnimation;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final frame0 = await Sprite.load('/mole_0.png');
    final frame1 = await Sprite.load('/mole_1.png');
    final frame2 = await Sprite.load('/mole_2.png');
    final frame3 = await Sprite.load('/mole_3.png');
    final frame4 = await Sprite.load('/mole_4.png');
    
    // Idle animation - just shows the mole normally
    idleAnimation = SpriteAnimation.spriteList(
      [frame0],
      stepTime: 1.0,
      loop: true,
    );
    
    // Whack animation - plays through all frames when tapped
    whackAnimation = SpriteAnimation.spriteList(
      [frame0, frame1, frame2, frame3, frame4],
      stepTime: 0.2,
      loop: false,
    );
    
    // Start with idle animation
    animation = idleAnimation;
  }

  // Handles Bonking
  @override
  void onTapDown(TapDownEvent event) {
  super.onTapDown(event);

  if (animation != whackAnimation) {
    animation = whackAnimation;
    animationTicker?.reset();
    print('Whacked!');
  }
}

  @override
  void update(double dt) {
    super.update(dt);
    
    if (animation == whackAnimation && animationTicker?.done == true) {
    animation = idleAnimation;
    animationTicker?.reset(); // Reset to make it start looping again
  }
  }
}