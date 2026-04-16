import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mss_core/mss_core.dart';
import 'package:demo_flappybird_def/demo_flappybird_def.dart';
import 'package:demo_flappy_physics_def/demo_flappy_physics_def.dart';
import 'package:demo_flappy_assets_def/demo_flappy_assets_def.dart';

class MyFlappyBird extends FlappyBirdDefinition {
  late List<ModuleInterface> _modules;
  FlappyPhysicsDefinition? physics;
  FlappyAssetsDefinition? assets;

  @override
  void setup(List<ModuleInterface> modules) {
    _modules = modules;
    physics = modules.whereType<FlappyPhysicsDefinition>().firstOrNull;
    // Assets will be set by the generated wiring via extension factories
  }

  @override
  Widget buildApp() {
    return MaterialApp(
      title: 'Flappy Bird',
      theme: ThemeData.dark(useMaterial3: true),
      home: _GameScreen(game: this),
    );
  }
}

class _GameScreen extends StatefulWidget {
  final MyFlappyBird game;
  const _GameScreen({required this.game});

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  double _birdY = 0.5;
  double _velocity = 0;
  bool _started = false;
  int _score = 0;
  Timer? _timer;

  void _jump() {
    if (!_started) {
      _started = true;
      _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        setState(() {
          final physics = widget.game.physics;
          if (physics != null) {
            _velocity += physics.gravity * 0.016;
            _birdY += _velocity * 0.016;
          } else {
            _velocity += 9.8 * 0.016;
            _birdY += _velocity * 0.016;
          }
          if (_birdY > 1 || _birdY < 0) {
            _reset();
          }
        });
      });
    }
    _velocity = widget.game.physics?.jumpVelocity ?? -4.0;
  }

  void _reset() {
    _timer?.cancel();
    _started = false;
    _birdY = 0.5;
    _velocity = 0;
    _score = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = widget.game.assets;
    return Scaffold(
      body: GestureDetector(
        onTap: _jump,
        child: Stack(
          children: [
            // Background
            if (assets != null)
              Positioned.fill(child: assets.buildBackground(context))
            else
              Container(color: const Color(0xFF87CEEB)),
            // Bird
            Align(
              alignment: Alignment(0, _birdY * 2 - 1),
              child: SizedBox(
                width: 40,
                height: 40,
                child: assets?.buildBird(context) ??
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
              ),
            ),
            // Score
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4)],
                  ),
                ),
              ),
            ),
            if (!_started)
              const Center(
                child: Text(
                  'TAP TO START',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
