# Debugging

## Inspecting intermediate workflow artifacts

By default, workflows write their files to a `TemporaryDirectory` that is
automatically deleted at the end of the run. To preserve these files
(ONNX model, inputs, outputs, JSON configs, compiled artifact), set the
`AETHERWEAVE_DEBUG_DIRECTORY` environment variable to a destination path.

### Via Docker

```bash
mkdir -p debug
docker run --rm -v $(pwd)/debug:/debug -e AETHERWEAVE_DEBUG_DIRECTORY=/debug aetherweave ./aw-run workflow --name <name>
```

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
