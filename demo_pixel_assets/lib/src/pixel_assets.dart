import 'package:flutter/material.dart';
import 'package:mss_core/mss_core.dart';
import 'package:demo_flappy_assets_def/demo_flappy_assets_def.dart';

class PixelAssets extends FlappyAssetsDefinition {
  @override
  Widget buildBird(BuildContext context) {
    return CustomPaint(painter: _BirdPainter());
  }

  @override
  Widget buildPipe(BuildContext context) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        border: Border.all(color: const Color(0xFF1B5E20), width: 3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget buildBackground(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
          stops: [0.7, 1.0],
        ),
      ),
    );
  }
}

class _BirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = const Color(0xFFFFD700);
    final eye = Paint()..color = Colors.black;
    final beak = Paint()..color = const Color(0xFFFF6600);

    // Body
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.4, body);
    // Eye
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.35),
      size.width * 0.08,
      eye,
    );
    // Beak
    final beakPath = Path()
      ..moveTo(size.width * 0.75, size.height * 0.45)
      ..lineTo(size.width * 0.95, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.55)
      ..close();
    canvas.drawPath(beakPath, beak);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

ExtensionFactory<PixelAssets> factory() => ExtensionFactory(
      name: 'Pixel Assets',
      create: () => PixelAssets(),
    );
