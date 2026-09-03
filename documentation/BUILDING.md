# Building AetherWeave

Everything runs inside Docker.

---

## Build the images

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/simon-ocloo/aetherweave
cd aetherweave

# Build all images (compiler → executor → final assembly)
docker buildx bake
```

Each submodule has its own `Dockerfile`. `docker-bake.hcl` at the root orchestrates the three builds in the correct order:

| Image | Content |
|---|---|
| `aetherweave-compiler` | Toolchain: clang-20, CMake, LLVM / MLIR 20, protobuf 3.25 and ONNX 1.22 built from source |
| `aetherweave-executor` | Toolchain: Rust |
| `aetherweave` | Runtime only: Python, PyTorch (CPU), and the binaries copied from the two toolchain images |

Once the images are built, see [RUNNING.md](RUNNING.md) to run a workflow.
