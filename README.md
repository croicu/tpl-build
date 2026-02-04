# tpl-build

## Overview

This repository builds **project templates** with a **ZIP‑first** workflow.

The core idea is simple:

- Templates are **plain files**.
- What you see in the template folder is **exactly what gets deployed** when you click *New Project* in Visual Studio (minus token substitution).
- Packaging is a **pure transformation step** (zip + install), not a build of user code.

Visual Studio is treated as a **deployment UX**, not the identity of the system.

---

## Core Principles

### 1. Canonical payload = deployed layout (1:1)

Each template lives under:

```
src/templates/<language>/<flavor>/project/
```

The contents of `project/` are deployed verbatim when the template is instantiated.

- `project/CMakeLists.txt` is **payload**, not build logic
- No template `CMakeLists.txt` is ever executed by this repo
- Templates are treated as **data**

---

### 2. ZIP is the primary artifact

- The main deliverable is a **Visual Studio template ZIP** (`.vstemplate`‑based)
- ZIPs are built on **Windows, Linux, and CI**
- Installation is done by copying ZIPs into the Visual Studio Templates folder
- ZIP build has **no dependency on Visual Studio**


## Repository Structure

```
tpl-build/
├─ build.bat
├─ build.sh
├─ README.md
├─ src/
│  └─ templates/
│     ├─ CMakeLists.txt
│     └─ cpp/
│        ├─ CMakeLists.txt        # centralized packaging logic
│        ├─ console/
│        │  └─ project/           # template payload (1:1 deployed)
│        ├─ win32/
│        │  └─ project/
│        ├─ library/
│        │  └─ project/
│        └─ module/
│           └─ project/
├─ build/                         # disposable
└─ out/                           # installed artifacts (contract)
```

Only the **non‑`project/`** `CMakeLists.txt` files participate in building this repo.

---

## Build System

### CMake (ZIP pipeline)

- The project is **language‑less**:

```cmake
project(tpl_build LANGUAGES NONE)
```

- CMake is used only to:
  - zip template folders
  - install ZIPs into `out/`
- Zipping is done with the built‑in, cross‑platform command:

```sh
cmake -E tar cf <template>.zip --format=zip .
```

- ZIPs are created in the **build tree**
- `cmake --install` moves them to `out/.../templates/...`

No PowerShell. No external zip tools.

---

### build.bat (Windows)

Single authoritative entry point.

Behavior:

- `build`, `build build`
  - always builds ZIP templates
  - installs ZIPs to `out/`
- `build test`
  - runs the test suite (requires net10)

---

### build.sh (Linux / macOS)

- ZIP‑only build
- Always works

No probing, no branching.

---

## Multi‑template ZIP rule

- A ZIP corresponds to **one** template entry in Visual Studio
- Multiple `.vstemplate` files are allowed **only** for a single `ProjectGroup`
  (multi‑project solution template)
- ZIPs cannot act as “template bundles”

---

## Generator compatibility

Duplication inside template payloads is expected.

A future `tpl‑generator` will:

- generate `src/templates/**/project/**` trees
- overwrite payload freely

This repo’s contract stays stable:

> **“Zip whatever is under `project/`.”**

No refactors required when the generator arrives.

---

## Summary

- ZIP‑first
- Cross‑platform for core artifacts
- Deterministic, quiet builds
- Clear separation between:
  - payload
  - packaging
  - installation

This repo exists to do **one thing well**:  
turn canonical template payloads into distributable Visual Studio templates.
