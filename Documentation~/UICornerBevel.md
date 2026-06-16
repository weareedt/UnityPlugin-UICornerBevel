# UICornerBevel

Rounds the hard corners of a UI `RawImage` or `Image` using a signed distance field (SDF) shader. No extra GameObjects or RenderTextures needed.

## Files
- `Runtime/UICornerBevel.cs` (namespace `EDT.UI`)
- `Shaders/UICornerBevel.shader` (shader name `UI/CornerBevel`)

## Setup
1. Select a UI GameObject with a `RawImage` or `Image`
2. **Add Component → UI/Effects/UI Corner Bevel**
3. Set **Corner Radius** (pixels)

## Inspector Fields
| Field | Description |
|---|---|
| Corner Radius | Curve radius in pixels. 0 = square corners. |
| Edge Softness | Anti-aliasing width at the edge (default 1.5px). |

## WebGL
Add `UI/CornerBevel` to **Project Settings → Graphics → Always Included Shaders**.

## Works With
- Any companion shadow/glow component exposing a public `RequestRebuild()` (e.g. `UISoftShadowRT`) — called via `SendMessage` so the package has no hard dependency on it.
- `UIAnimationPlayer` — Fade works correctly; CanvasGroup alpha is baked into vertex colour which the shader respects.
