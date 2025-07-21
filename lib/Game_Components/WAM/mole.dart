import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:project_mini_games/Games/whack_a_mole.dart';

class Mole extends SpriteAnimationComponent with HasGameReference<WhackAMole>, TapCallbacks {
  final VoidCallback? onWhack;

  Mole({
    required this.whackFrameRange, // Range of frames for hit detection.
    Vector2? position,
    Vector2? size,
    this.onWhack,
  }) : super(
          position: position ?? Vector2.zero(),
          size: size ?? Vector2.all(50),
          anchor: Anchor.center,
        );
  // Animation cooldown
  double cooldownTimer = 0;
  final double cooldownDuration = 1.5; // Customize as needed
  bool isCoolingDown = false;      

  late final SpriteAnimation popUpAnimation;
  late final SpriteAnimation whackAnimation;
  late final SpriteAnimation idleAnimation;

  bool isVisible = false;
  bool canWhack = false;
  final List<int> whackFrameRange;

  double whackTimer = 0.0;
  final double whackDuration = 1.0;

  @override
Future<void> onLoad() async {
  final molePopUp = await Future.wait([
    Sprite.load('mole_001.png'),
    Sprite.load('mole_002.png'),
    Sprite.load('mole_003.png'),
    Sprite.load('mole_004.png'),
    Sprite.load('mole_005.png'),
    Sprite.load('mole_006.png'),
  ]);

  final whackFrames = await Future.wait([
    Sprite.load('whacked1.png'),
    Sprite.load('whacked2.png'),
    Sprite.load('whacked3.png'),
    Sprite.load('whacked4.png'),
    Sprite.load('whacked5.png'),
    Sprite.load('whacked6.png'),
    Sprite.load('whacked7.png'),
    Sprite.load('whacked8.png'),
    Sprite.load('whacked9.png'),
    // Sprite.load('whacked.10png'),
    // Sprite.load('whacked.11png'),
    // Sprite.load('whacked.12png'),
    // Sprite.load('whacked.13png'),
  ]);

  idleAnimation = SpriteAnimation.spriteList([molePopUp[0]], stepTime: 1);
  whackAnimation = SpriteAnimation.spriteList(whackFrames, stepTime: 0.1);
  popUpAnimation = SpriteAnimation.spriteList(molePopUp, stepTime: 0.15);

  animation = idleAnimation;
}

@override
void onTapDown (TapDownEvent event) {
  super.onTapDown(event);

  if (!canWhack) return;

  final currentFrame = animationTicker?.currentIndex ?? -1;
  if (currentFrame >= whackFrameRange[0] &&
    currentFrame <= whackFrameRange[1]) {
    // Disable further whacks and hide mole
    canWhack = false;
    isVisible = false;
    // Play whack animation
    animation = whackAnimation;
    animationTicker?.reset(); // Reset whack animation to start from frame 0
    whackTimer = 0;

    onWhack?.call(); // If we recieved a function called onWhack, call it. (Check constructor)
  }
}
  
  // Starts the pop-up animation
  void show() {
  if (isVisible) return;
  animation = popUpAnimation;
  animationTicker?.reset();
  isVisible = true;
  canWhack = true;
}

  @override
  void update(double dt) {
    super.update(dt);

  if (isCoolingDown) {
    cooldownTimer += dt;
    if (cooldownTimer >= cooldownDuration) {
      cooldownTimer = 0;
      isCoolingDown = false;
    }
  }  
  // If the mole was whacked, manage the whack animation duration
  if (animation == whackAnimation) {
    whackTimer += dt;
    if (whackTimer >= whackDuration) {
      animation = idleAnimation;
      whackTimer = 0;
    }
  }

  // If pop-up animation finished and wasn't hit, return to idle
  if (animation == popUpAnimation &&
      (animationTicker?.done() ?? false) &&
      canWhack) {
    animation = idleAnimation;
    isVisible = false;
    canWhack = false;
    isCoolingDown = true;
  }
}
}