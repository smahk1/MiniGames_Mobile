import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:project_mini_games/Game_Components/WAM/whack_a_mole.dart';
import 'package:flame_audio/flame_audio.dart';

class Mole extends SpriteAnimationComponent with HasGameReference<WhackAMole>, TapCallbacks {
  final VoidCallback? onWhack;
  
  Mole({
    required this.whackFrameRange,
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
  final double cooldownDuration = 1.5;
  bool isCoolingDown = false;
  
  // Animation timer - tracks current animation progress
  double animationTimer = 0;
  final double popUpDuration = 0.9; // 6 frames * 0.15 stepTime
  final double whackDuration = 0.9; // 9 frames * 0.1 stepTime
  
  late final SpriteAnimation popUpAnimation;
  late final SpriteAnimation whackAnimation;
  late final SpriteAnimation idleAnimation;
  
  bool isVisible = false;
  bool canWhack = false;
  bool wasWhacked = false;
  final List<int> whackFrameRange;

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
    ]);
    
    idleAnimation = SpriteAnimation.spriteList([molePopUp[0]], stepTime: 1);
    popUpAnimation = SpriteAnimation.spriteList(molePopUp, stepTime: 0.15, loop: false);
    whackAnimation = SpriteAnimation.spriteList(whackFrames, stepTime: 0.1, loop: false);
    
    animation = idleAnimation;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!canWhack || wasWhacked) return;
    
    final currentFrame = animationTicker?.currentIndex ?? -1;
    if (currentFrame >= whackFrameRange[0] && currentFrame <= whackFrameRange[1]) {
      // Mark as whacked and disable further interactions
      wasWhacked = true;
      canWhack = false;
      
      // Reset timer for whack animation
      animationTimer = 0;
      
      // Play whack animation and sound effect
      FlameAudio.play('hit_sound_effect.mp3');
      animation = whackAnimation;
      animationTicker?.reset();
      
      // Call the whack callback
      onWhack?.call();
      
      // print("Mole whacked! Starting whack animation");
    }
  }

  // Starts the pop-up animation
  void show() {
    if (isVisible || isCoolingDown) return;
    
    // print("Showing mole at position: $position");
    
    // Reset all states
    wasWhacked = false;
    isVisible = true;
    canWhack = true;
    animationTimer = 0;
    
    animation = popUpAnimation;
    animationTicker?.reset();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Handle cooldown timer
    if (isCoolingDown) {
      cooldownTimer += dt;
      if (cooldownTimer >= cooldownDuration) {
        cooldownTimer = 0;
        isCoolingDown = false;
        //  print("Mole cooldown finished at position: $position");
      }
    }
    
    // Handle active animations
    if (isVisible || wasWhacked) {
      animationTimer += dt;
      
      // Handle pop-up animation completion (mole wasn't hit)
      if (!wasWhacked && animation == popUpAnimation && animationTimer >= popUpDuration) {
        // print("Pop-up animation completed, resetting to idle");
        _resetToIdle();
        return;
      }
      
      // Handle whack animation completion
      if (wasWhacked && animation == whackAnimation && animationTimer >= whackDuration) {
        // print("Whack animation completed, resetting to idle");
        _resetToIdle();
        return;
      }
    }
  }
  
  // Helper method to reset mole to idle state
  void _resetToIdle() {
    animation = idleAnimation;
    animationTicker?.reset();
    isVisible = false;
    canWhack = false;
    wasWhacked = false;
    isCoolingDown = true;
    cooldownTimer = 0;
    animationTimer = 0;
  }

  
  // Public method to reset mole (used by game reset)
  void resetMole() {
    animation = idleAnimation;
    animationTicker?.reset();
    isVisible = false;
    canWhack = false;
    wasWhacked = false;
    isCoolingDown = false;
    cooldownTimer = 0;
    animationTimer = 0;
  }
}