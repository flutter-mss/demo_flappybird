# demo_flappybird

Demo MSS plugin bundle for a Flappy-Bird-style game. Contains multiple
packages (app, module, extension, and their interface definitions) in
a single repository. Each package is registered independently on the
MSS server via `git_subpath`.

## Layout

| Subpath | Role | Kind |
|---|---|---|
| `demo_my_flappybird/` | App implementation | Plugin (app) |
| `demo_flappy_physics_def/` | Physics module interface | Interface (module) |
| `demo_simple_physics/` | Classic-feel physics | Plugin (module) |
| `demo_flappy_assets_def/` | Visual assets module interface | Interface (module) |
| `demo_pixel_assets/` | Pixel-art bird sprites | Plugin (module) |

## Dependency graph

```
demo_my_flappybird ─┬─▶ demo_flappy_physics_def ◀── demo_simple_physics
                    └─▶ demo_flappy_assets_def  ◀── demo_pixel_assets
```

For an alternative physics implementation, see
[`demo_alternative_physics`](https://github.com/flutter-mss/demo_alternative_physics).

All packages also depend on `mss_core` (rewritten by the MSS combiner at assembly time).

## Try it

Download the signed MSS client from
[flutter-mss/mss_releases](https://github.com/flutter-mss/mss_releases/releases/latest),
browse the store, and pick `demo_my_flappybird` plus a physics module
(`demo_simple_physics` or the alternative) and `demo_pixel_assets`.

## License

MIT — see [LICENSE](LICENSE).
