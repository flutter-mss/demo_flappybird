import 'package:flutter/widgets.dart';
import 'package:mss_core/mss_core.dart';

/// Visual assets for a flappy bird game (bird, pipes, background).
abstract class FlappyAssetsDefinition extends ExtensionInterface {
  Widget buildBird(BuildContext context);
  Widget buildPipe(BuildContext context);
  Widget buildBackground(BuildContext context);
}

typedef FlappyAssetsFactory = FlappyAssetsDefinition Function();
