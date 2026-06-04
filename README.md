# The Wall — Overlay Projector

An interactive **3D wall viewer** built with [Three.js](https://threejs.org/). Project images and layered artwork onto a 3D wall model (`wall.glb`) with real-time lighting, soft shadows, HDRI environments, and image-based ambient occlusion — then export a high-resolution screenshot.

> **Live demo:** _deploy on Vercel and drop your URL here_ → `https://the-wall.vercel.app`

![Three.js](https://img.shields.io/badge/Three.js-r160-000?logo=three.js) ![No build step](https://img.shields.io/badge/build-none-brightgreen) ![Static site](https://img.shields.io/badge/deploy-static-blue)

---

## Features

- **Layered projection** — up to 4 image layers you can add, remove, and reorder on the wall
- **Load your own images** onto any layer, or use the built-in test pattern
- **HDRI environments** — load `.hdr` / `.exr` from a file or URL for realistic reflections and lighting
- **Sun control** — azimuth, elevation, intensity, and color, with auto-extraction from the loaded HDRI
- **Soft shadows** — adjustable strength and softness (VSM shadow mapping)
- **Post-processing** — GTAO ambient occlusion and SMAA anti-aliasing
- **Color grading** controls
- **Screenshot export** at 1×, 2×, or 4× resolution (or press **P**)
- **Transform gizmo** for positioning

## Run locally

A local server is required (browsers block loading `wall.glb` over `file://`).

**Windows (one click):**
```bat
run.bat
```

**Any OS (Python):**
```bash
python -m http.server 8000
# then open http://localhost:8000
```

That's it — there is **no build step**. `three` and `lil-gui` load from the unpkg CDN via an import map.

## Deploy

This is a pure static site, so it deploys with zero configuration on any static host:

1. Push this repo to GitHub (already done if you're reading this there)
2. On [vercel.com/new](https://vercel.com/new), **Import** this repo
3. Leave all settings at their defaults → **Deploy**

`vercel.json` adds a long-lived cache header for `wall.glb`. Every push to `main` auto-redeploys.

> Works the same on **GitHub Pages** and **Netlify**.

## Project structure

```
index.html    The entire app (Three.js scene, UI, post-processing)
wall.glb      The 3D wall model
vercel.json   Static deploy + caching config
run.bat       Local dev server launcher (Windows)
```

## Tech stack

- **Three.js r160** — WebGL rendering, GLTF loading, post-processing
- **lil-gui** — control panel
- **AgX tone mapping**, VSM soft shadows, GTAO, SMAA

## License

MIT — free to use and modify.
