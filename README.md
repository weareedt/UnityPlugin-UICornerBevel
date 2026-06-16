# UI Corner Bevel

Rounds the hard corners of a uGUI `Image` or `RawImage` using a signed distance field
(SDF) shader. No extra GameObjects, RenderTextures, or mesh modifications — add the
component, set a radius, done.

## Installation

### Option A — Git URL
**Window → Package Manager → +  → Add package from git URL…** and paste:
```
https://github.com/weareedt/UnityPlugin-UICornerBevel.git
```
Pin a version with `#1.0.0` once you tag releases.

### Option B — local path
1. Copy the `com.edt.uicornerbevel` folder somewhere on disk.
2. In Unity: **Window → Package Manager → +  → Add package from disk…**
3. Select `com.edt.uicornerbevel/package.json`.

### Option C — manifest entry
Add to your project's `Packages/manifest.json`:
```json
"com.edt.uicornerbevel": "https://github.com/weareedt/UnityPlugin-UICornerBevel.git#1.0.0"
```

## Usage
1. Select a UI GameObject that has a `RawImage` or `Image`.
2. **Add Component → UI/Effects → UI Corner Bevel**.
3. Set **Corner Radius** (in pixels).

| Field | Description |
|---|---|
| **Corner Radius** | Curve radius in pixels. `0` = square corners. Clamped to half the shorter side. |
| **Edge Softness** | Anti-aliasing width at the edge in pixels (default `1.5`). |

The effect tracks RectTransform resizes automatically and works with both full-texture
`RawImage` and atlased `Image` sprites.

## WebGL / build note
The component finds the shader at runtime via `Shader.Find("UI/CornerBevel")`. Because
nothing references the shader from a serialized material in this package, add it to the
**always-included** list so it survives a build:

**Project Settings → Graphics → Always Included Shaders → add `UI/CornerBevel`.**

## Optional integration
If the GameObject also has a soft-shadow/glow component that exposes a public
`RequestRebuild()` method (such as `UISoftShadowRT`), this component will call it via
`SendMessage` whenever the bevel changes, so the shadow's corners stay matched. There is
no hard dependency — it no-ops harmlessly when no such component is present.

## Requirements
- Unity 2021.3 or newer
- com.unity.ugui (uGUI) — included in Unity by default

## License
MIT — see `LICENSE.md`.
