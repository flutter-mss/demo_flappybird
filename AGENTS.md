# demo_flappybird

Multi-package MSS plugin bundle — a playable Flappy-Bird-style game with
swappable physics and asset-pack modules. Five packages in one repo; each
registered independently on the MSS server via `git_subpath`.

## Layout

| Subpath | Role | Kind |
|---|---|---|
| `demo_my_flappybird/` | App shell + game loop | Plugin (app) |
| `demo_flappy_physics_def/` | Physics module interface | Interface (module) |
| `demo_simple_physics/` | Baseline physics | Plugin (module) |
| `demo_flappy_assets_def/` | Visual assets module interface | Interface (module) |
| `demo_pixel_assets/` | Pixel-art sprite pack | Plugin (module) |

Alternative physics lives in a separate repo:
[demo_alternative_physics](https://github.com/flutter-mss/demo_alternative_physics).

## Rules that aren't obvious from one file

- **The full game loop is in `demo_my_flappybird`** — pipes, collision,
  scoring, tilt, game-over overlay. The physics module only supplies the
  gravity / jump velocity / collision tolerance curves.
- **`FlappyAssetsDefinition` is a module, not an extension** (refactored
  from an earlier extension shape — see `9838dff`). Asset-pack
  implementations ship their own `assets/` declared in `pubspec.yaml`;
  `asset()` resolves via the combiner-injected `assetPrefix`.
- **Two demo repos implement `FlappyPhysicsDefinition`**: this one
  (`demo_simple_physics`) and `demo_alternative_physics`. The latter
  relies on the combiner collapsing the cross-repo
  `path: ../demo_flappybird/demo_flappy_physics_def` dep via
  `dependency_overrides` — don't change that path convention.
- **No extensions** in this bundle — everything is app + module. Keep it
  that way unless there's a concrete case; it's the simplest multi-package
  reference.

## Dev loop

```bash
cd demo_my_flappybird && flutter pub get && flutter analyze
```

End-to-end: assemble via the MSS client against the public registry or a
local server.
