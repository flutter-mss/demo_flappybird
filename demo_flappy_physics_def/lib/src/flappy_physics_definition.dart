import 'package:flutter/widgets.dart';
import 'package:mss_core/mss_core.dart';

/// Physics for a flappy bird game — gravity, jump, collision.
abstract class FlappyPhysicsDefinition extends ModuleInterface {
  double get gravity;
  double get jumpVelocity;

  void update(double dt);
  bool checkCollision(Rect a, Rect b);
}
