# Building AetherWeave

Everything runs inside Docker.

---

## Getting started

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/simon-ocloo/aetherweave
cd aetherweave

# Build the image
docker build -t aetherweave .

# Run the mock pipeline
docker run --rm aetherweave
```

The `mock` workflow verifies that all binaries are reachable and the pipeline plumbing works.
Real workflows (`mnist-dense`, `resnet50`, …) will be added as model support is implemented.

---

## What the Docker image contains

| Tool | Version | Role |
|---|---|---|
| Clang | 20.x | C++20 compiler |
| LLVM / MLIR | 20.x | Compiler infrastructure |
| LLD | 20.x | Linker |
| clang-format | 20.x | C++ formatter |
| libprotobuf | system | ONNX protobuf parsing |
| CMake | system | C++ build system |
| Ninja | system | Build backend |
| Rust (stable) | latest | Executor |
| Python 3 | system | Workflow runner |

All binaries (`aw-compile`, `aw-opt`, `aw-execute`, `aw-run`) are installed to `/workspace/bin/`.

---

## Build steps inside the image

### C++ tools — aw-compile, aw-opt

```bash
cd aetherweave-compiler
cmake --preset=release          # or: debug, relwithdebinfo
cmake --build build
cmake --install build --prefix /workspace
```

### Rust tools — aw-execute

```bash
cd aetherweave-executor
cargo install --path tools/aw-execute --root /workspace
```

---

## Dev shell

Open an interactive shell with the full environment:

```bash
docker run --rm -it aetherweave bash
```

Mount your local source to iterate without rebuilding the image:

```bash
docker run --rm -it -v $(pwd):/workspace aetherweave bash
```

---

## Running a workflow

```bash
docker run --rm aetherweave aw-run workflow --name mock
```
