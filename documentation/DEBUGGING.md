# Debugging

## Inspecting intermediate workflow artifacts

By default, workflows write their files to a `TemporaryDirectory` that is
automatically deleted at the end of the run. To preserve these files
(ONNX model, inputs, outputs, JSON configs, compiled artifact), set the
`AETHERWEAVE_DEBUG_DIRECTORY_PATH` environment variable to a destination path.
An empty value is treated as unset.

### Via Docker

```bash
mkdir -p debug
docker run --rm -v $(pwd)/debug:/debug -e AETHERWEAVE_DEBUG_DIRECTORY_PATH=/debug aetherweave ./aw-run workflow --name <name>
```

Create `debug/` yourself before the run. When the mounted directory does not
exist, Docker creates it as root, and the final copy of the workflow restricts
it to its owner (mode 0700): you could no longer read it without `sudo`.

The files written inside `debug/` still belong to root, since the container
runs as root: you can read them, but removing them requires `sudo`
(`sudo rm -rf debug`).

Contents of `debug/` after the run:

```
debug/
├── <name>.onnx                       ← ONNX model
├── x.bin                             ← input x (f32 little-endian)
├── y.bin                             ← input y (f32 little-endian)
├── z.bin                             ← output z written by aw-execute
├── compile_configuration.json        ← config passed to aw-compile
├── execute_configuration.json        ← config passed to aw-execute
└── artifact.<name>.YYYYMMDD-HHMMSS/  ← compiled artifact
```

The copy runs in a `finally` block wrapping the entire workflow — artifacts
are always copied whether the run succeeds or fails.
