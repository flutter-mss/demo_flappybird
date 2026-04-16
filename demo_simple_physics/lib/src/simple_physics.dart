import 'package:flutter/widgets.dart';
import 'package:demo_flappy_physics_def/demo_flappy_physics_def.dart';

class SimplePhysics extends FlappyPhysicsDefinition {
  @override
  double get gravity => 9.8;

  @override
  double get jumpVelocity => -4.5;

  @override
  void update(double dt) {
    // Physics tick — used by the game loop
  }

  @override
  bool checkCollision(Rect a, Rect b) {
    return a.overlaps(b);
  }

  @override
  Widget buildUI(BuildContext context) {
    // Module UI — physics has no visible UI
    return const SizedBox.shrink();
  }
}
