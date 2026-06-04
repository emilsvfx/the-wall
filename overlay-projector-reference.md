# Overlay Projector — Three.js Box Gizmo

Planar overlay projector for Three.js. A draggable 3D box (TransformControls) projects an
overlay texture onto an existing PBR mesh — like Blender's empty + box-mapping. The mesh's
own UVs are never touched; projection comes entirely from the box transform.

## Core idea

For each fragment, transform its **world position** by the box's **inverse matrix** into
box-local space:

- `local.xy` → overlay UV (box spans `-1..1` → remapped to `0..1`)
- `local.z`  → projection depth, clipped to `|z| < 1` (the box volume)

Injected via `material.onBeforeCompile` so it runs **after** the PBR maps are sampled
(`diffuseColor` already holds albedo). All existing roughness / normal / metal maps and
scene lighting stay intact — the overlay only blends into the diffuse term.

## Shared uniforms

One uniform block drives every patched material, so a single box can overlay across many
sub-meshes at once.

| Uniform        | Type        | Purpose                                   |
|----------------|-------------|-------------------------------------------|
| `uOverlay`     | sampler2D   | Overlay texture                           |
| `uHasOverlay`  | int         | 0/1 guard before any texture is loaded    |
| `uProjInv`     | mat4        | `box.matrixWorld` inverted (world→local)  |
| `uBlend`       | int         | 0 alpha · 1 multiply · 2 screen · 3 overlay |
| `uOpacity`     | float       | Overlay strength 0..1                     |
| `uCull`        | int         | Backface cull via normal·projector-dir    |
| `uPersp`       | float       | 0 = ortho (Blender empty) → 1 = spotlight cone |

## Key functions

- **`patchMaterial(material)`** — adds `vWorldPos` / `vWorldNrm` varyings in the vertex
  shader, injects projection + blend logic at `#include <map_fragment>` in the fragment
  shader. Call once per material (traverse a GLTF and call on each `child.material`).
- **`updateProjector()`** — `uProjInv = boxGroup.matrixWorld.invert()`. Called on every
  TransformControls `change` event.

## Blend math (per fragment, inside box volume)

```glsl
alpha   : mix(base, ov.rgb, a)
multiply: mix(base, base * ov.rgb, a)
screen  : mix(base, 1.0 - (1.0-base)*(1.0-ov.rgb), a)
overlay : hard/soft split on step(0.5, base)
```
`a = ov.a * uOpacity`. Blends into `diffuseColor.rgb` before lighting — correct for
grunge / dirt / decals. For an unlit glowing decal, inject at `emissive` instead.

## Backface cull

```glsl
facing = dot(normalize(vWorldNrm), normalize(mat3(uProjInv) * vec3(0,0,1)));
if (uCull == 1 && facing > 0.0) inside = false;
```
Stops the overlay bleeding through onto faces pointing away from the projector.

## Controls

| Input            | Action                                    |
|------------------|-------------------------------------------|
| W / E / R        | Gizmo mode: translate / rotate / scale    |
| X / Y / Z        | Toggle axis handles                       |
| + / -            | Gizmo screen size                         |
| Drag empty space | OrbitControls (disabled while dragging gizmo) |
| Drop image       | Load overlay (PNG+alpha best for decals)  |
| Frame Mesh       | Snap box to mesh bbox via `Box3`          |

## Wiring up a real asset

```js
gltf.scene.traverse(o => { if (o.isMesh) patchMaterial(o.material); });
```
Delete the demo `wall` Box. Shared uniforms mean the one box drives all patched meshes.

## Gotchas

- `dragging-changed` must toggle `orbit.enabled` or orbit fights the gizmo.
- `r0.160` TransformControls: add `tc.getHelper()` to the scene (not `tc` directly).
- Overlay texture uses `ClampToEdgeWrapping` so it doesn't tile outside the box.
- Projection is in **world space** — if the mesh moves, re-call `updateProjector()`.
