import 'package:flutter/widgets.dart';
import 'package:mss_core/mss_core.dart';

/// Visual assets for a flappy bird game (bird, pipes, background).
///
/// Modeled as a [ModuleInterface] even though it doesn't render a UI
/// slot of its own: it participates in the app's `setup(modules)`
/// wiring, benefits from the combiner's per-plugin `assetPrefix`, and
/// host game loops pull rendering hooks from the instance.
abstract class FlappyAssetsDefinition extends ModuleInterface {
  Widget buildBird(BuildContext context);
  Widget buildPipe(BuildContext context);
  Widget buildBackground(BuildContext context);

  /// Assets plugins have no standalone UI; the game loop drives painting.
  @override
  Widget buildUI(BuildContext context) => const SizedBox.shrink();
}
