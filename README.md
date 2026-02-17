# tpl-builder

## Overview

`tpl-builder` produces **canonical, ZIP-based project templates**.

It is a **builder only**:

-   Builds template artifacts
-   Tests templates cross-platform
-   Packages ZIPs
-   Publishes release artifacts

It does **not**:

-   Instantiate projects
-   Register templates with an IDE
-   Run user code

Templates are treated as **data**, not code.

------------------------------------------------------------------------

## Core Principles

### 1. ZIP-first

ZIP files are the canonical artifact.

Everything under:

    out/<arch>/<config>/templates/

is publishable.

No generated artifacts are committed to Git.

------------------------------------------------------------------------

### 2. Canonical Template Identity (Tool-Agnostic)

Template IDs follow this grammar:

    <lang>.<kind>[.<specialization>][.<platform>]

Examples:

-   `cpp.console`
-   `cpp.library`
-   `cpp.module`
-   `cpp.gui.qt`
-   `cpp.gui.win32`

Rules:

-   No IDE leakage
-   No packaging leakage
-   Platform only when inherently required
-   Framework encoded as specialization

------------------------------------------------------------------------

### 3. Payload is 1:1 Deployed Layout

Each template lives under:

    src/templates/<id>/project/

Everything inside `project/` is deployed verbatim (minus token
substitution).

Templates are **never built** by this repository.

They are zipped exactly as authored.

------------------------------------------------------------------------

## Repository Structure

    tpl-builder/
    ├─ build.bat
    ├─ build.sh
    ├─ README.md
    ├─ src/
    │  └─ templates/
    │     ├─ cpp.console/
    │     │  └─ project/
    │     ├─ cpp.library/
    │     │  └─ project/
    │     ├─ cpp.module/
    │     │  └─ project/
    │     ├─ cpp.gui.qt/
    │     │  └─ project/
    │     └─ cpp.gui.win32/
    │        └─ project/
    ├─ tests/
    ├─ build/        # disposable
    └─ out/          # publishable artifacts only

------------------------------------------------------------------------

## out/ Layout (Subset Model)

    out/
      templates/
        <id>.zip
        ...
        vs/
          <id>.project.zip
          <id>.item.zip

-   `out/templates/` → full tpl-deployable universe
-   `out/templates/vs/` → subset that also happens to be Visual
    Studio-registerable

Visual Studio artifacts are variants, not separate templates.

------------------------------------------------------------------------

## Build System

### Single Entry Point

Windows:

    build.bat build <arch> <config>
    build.bat test  <arch> <config>

Linux:

    ./build.sh build <arch> <config>
    ./build.sh test  <arch> <config>

CI uses the exact same commands.

------------------------------------------------------------------------

### Determinism Rules

-   Tests consume ZIPs --- they do not build templates
-   All artifacts land under `out/`
-   `build/` and `out/` are ignored by Git
-   Versioning comes from Git tags
-   Release artifacts are published via GitHub Releases

------------------------------------------------------------------------

## CI/CD Model

CI validates:

-   Linux build
-   Windows build
-   Cross-platform tests
-   Deterministic ZIP generation

Release is triggered by tag:

    git tag v0.1.0
    git push origin v0.1.0

Tag name becomes release version.

------------------------------------------------------------------------

## Extensibility Model (v2-Ready)

Projects ship with predefined extension points:

    cmake/subdirectories.generated.cmake
    cmake/targets.generated.cmake
    cmake/sources.generated.cmake
    cmake/link.generated.cmake

Future item deployment will:

-   Drop into `items/<name>/`
-   Append only to `cmake/*.generated.cmake`
-   Never edit user-authored files

No patching. No heuristic merging. Deterministic growth only.

------------------------------------------------------------------------

## Conceptual Invariants

-   ZIP is the artifact
-   Registry is indirection
-   Deploy is deterministic and offline-first
-   IDEs are adapters, not authorities
-   Arch is expressed at configure time
-   Specialization is encoded in ID; tooling is never encoded

------------------------------------------------------------------------

## Status

v1 template system is structurally complete:

-   Cross-platform console/library/module
-   Linux GTK and Qt GUI
-   Windows Win32 GUI
-   Deterministic CI/CD
-   Clean artifact model
-   Future-proof extensibility design

------------------------------------------------------------------------

This repository exists to do **one thing well**:

Turn canonical template payloads into immutable, publishable ZIP
artifacts.
