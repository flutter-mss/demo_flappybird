import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mss_core/mss_core.dart';
import 'package:demo_flappybird_def/demo_flappybird_def.dart';
import 'package:demo_flappy_physics_def/demo_flappy_physics_def.dart';
import 'package:demo_flappy_assets_def/demo_flappy_assets_def.dart';

// Physics plugins return unitless `gravity` / `jumpVelocity` — map them
// to pixel space with this scale so tuning stays meaningful.
const double _physicsScale = 50.0;

// World tuning (pixels / seconds).
const double _pipeWidth = 60.0;
const double _pipeGap = 160.0;
const double _pipeSpeed = 160.0;
const double _pipeSpawnEvery = 1.5;
const double _birdSize = 40.0;
const double _birdXFrac = 0.3;

class MyFlappyBird extends FlappyBirdDefinition {
  FlappyPhysicsDefinition? physics;
  FlappyAssetsDefinition? assets;

  @override
  void setup(List<ModuleInterface> modules) {
    physics = modules.whereType<FlappyPhysicsDefinition>().firstOrNull;
  }

  @override
  void setupExtensions(List<ExtensionInterface> extensions) {
    assets = extensions.whereType<FlappyAssetsDefinition>().firstOrNull;
  }

  @override
  Widget buildApp() {
    return MaterialApp(
      title: 'Flappy Bird',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: _GameScreen(game: this),
    );
  }
}

enum _GameState { menu, playing, gameover }

class _Pipe {
  double x;
  final double gapTop;
  bool scored = false;

  _Pipe({required this.x, required this.gapTop});
}

class _GameScreen extends StatefulWidget {
  final MyFlappyBird game;
  const _GameScreen({required this.game});

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen>
    with SingleTickerProviderStateMixin {
  _GameState _state = _GameState.menu;
  double _birdY = 0;
  double _velocity = 0;
  int _score = 0;
  int _best = 0;
  final List<_Pipe> _pipes = [];
  double _spawnTimer = 0;
  Size _size = Size.zero;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  double get _gravity =>
      (widget.game.physics?.gravity ?? 9.8) * _physicsScale;
  double get _jumpVelocity =>
      (widget.game.physics?.jumpVelocity ?? -4.5) * _physicsScale;

  double get _birdX => _size.width * _birdXFrac;

  void _handleTap() {
    if (_size == Size.zero) return;
    if (_state == _GameState.menu) {
      _begin();
      _flap();
    } else if (_state == _GameState.playing) {
      _flap();
    } else if (_state == _GameState.gameover) {
      _begin();
    }
  }

  void _begin() {
    setState(() {
      _state = _GameState.playing;
      _birdY = _size.height * 0.5;
      _velocity = 0;
      _score = 0;
      _pipes.clear();
      _spawnTimer = 0;
      _lastTick = Duration.zero;
    });
  }

  void _flap() {
    _velocity = _jumpVelocity;
  }

  void _die() {
    setState(() {
      _state = _GameState.gameover;
      if (_score > _best) _best = _score;
    });
  }

  void _tick(Duration now) {
    if (_state != _GameState.playing) return;
    double dt;
    if (_lastTick == Duration.zero) {
      dt = 1 / 60;
    } else {
      dt = (now - _lastTick).inMicroseconds / 1e6;
    }
    _lastTick = now;
    if (dt <= 0 || dt > 0.1) dt = 1 / 60; // clamp big pauses

    widget.game.physics?.update(dt);
    _velocity += _gravity * dt;
    _birdY += _velocity * dt;

    _spawnTimer += dt;
    if (_spawnTimer >= _pipeSpawnEvery) {
      _spawnTimer = 0;
      final maxTop = _size.height - _pipeGap - 60;
      final gapTop = 60 + _rng.nextDouble() * (maxTop - 60);
      _pipes.add(_Pipe(x: _size.width + _pipeWidth, gapTop: gapTop));
    }
    for (final p in _pipes) {
      p.x -= _pipeSpeed * dt;
      if (!p.scored && p.x + _pipeWidth < _birdX) {
        p.scored = true;
        _score++;
      }
    }
    _pipes.removeWhere((p) => p.x + _pipeWidth < 0);

    final bird = Rect.fromCenter(
      center: Offset(_birdX, _birdY),
      width: _birdSize,
      height: _birdSize,
    );
    final check = widget.game.physics?.checkCollision ?? _rectsOverlap;
    for (final p in _pipes) {
      final top = Rect.fromLTWH(p.x, 0, _pipeWidth, p.gapTop);
      final bot = Rect.fromLTWH(
        p.x,
        p.gapTop + _pipeGap,
        _pipeWidth,
        _size.height - (p.gapTop + _pipeGap),
      );
      if (check(bird, top) || check(bird, bot)) {
        _die();
        return;
      }
    }

    if (_birdY < 0 || _birdY > _size.height) {
      _die();
      return;
    }

    setState(() {});
  }

  static bool _rectsOverlap(Rect a, Rect b) => a.overlaps(b);

  @override
  Widget build(BuildContext context) {
    final assets = widget.game.assets;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _size = Size(constraints.maxWidth, constraints.maxHeight);
          if (_state == _GameState.menu && _birdY == 0) {
            _birdY = _size.height * 0.5;
          }
          final tilt = (_velocity / 600).clamp(-0.5, 1.0);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: assets?.buildBackground(context) ?? _bgFallback(),
                ),
                for (final p in _pipes) ..._pipeWidgets(p, assets, context),
                Positioned(
                  left: _birdX - _birdSize / 2,
                  top: _birdY - _birdSize / 2,
                  child: Transform.rotate(
                    angle: tilt,
                    child: SizedBox(
                      width: _birdSize,
                      height: _birdSize,
                      child: assets?.buildBird(context) ?? _birdFallback(),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 6, color: Colors.black)
                        ],
                      ),
                    ),
                  ),
                ),
                if (_state == _GameState.menu) _overlay('Tap to start'),
                if (_state == _GameState.gameover)
                  _overlay(
                    'Game over',
                    sub: 'Score: $_score   Best: $_best\nTap to play again',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _pipeWidgets(
    _Pipe p,
    FlappyAssetsDefinition? assets,
    BuildContext context,
  ) {
    final pipe = assets?.buildPipe(context) ?? _pipeFallback();
    return [
      Positioned(
        left: p.x,
        top: 0,
        width: _pipeWidth,
        height: p.gapTop,
        child: pipe,
      ),
      Positioned(
        left: p.x,
        top: p.gapTop + _pipeGap,
        width: _pipeWidth,
        bottom: 0,
        child: pipe,
      ),
    ];
  }

  Widget _bgFallback() => Container(color: const Color(0xFF87CEEB));

  Widget _birdFallback() => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFD700),
          shape: BoxShape.circle,
        ),
      );

  Widget _pipeFallback() => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          border: Border.all(color: const Color(0xFF1B5E20), width: 3),
        ),
      );

  Widget _overlay(String title, {String? sub}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 8),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
