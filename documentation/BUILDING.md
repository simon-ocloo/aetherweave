# Building AetherWeave

Everything runs inside Docker.

---

## Getting started

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/simon-ocloo/aetherweave
cd aetherweave

# Build all images (compiler → executor → final assembly)
docker buildx bake

# Run the mock workflow
docker run --rm aetherweave

# Run a named workflow
docker run --rm aetherweave ./aw-run workflow --name <name>
```

Each submodule has its own `Dockerfile`. `docker-bake.hcl` at the root orchestrates the three builds in the correct order.
