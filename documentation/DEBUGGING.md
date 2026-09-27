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
├── artifact.<name>.YYYYMMDD-HHMMSS/  ← compiled artifact
└── mlir_snapshots/                   ← MLIR snapshots
    ├── 00.ONNXMLIRImporter.mlir
    ├── 01.AetherToLinalg.mlir
    └── ...
```

The copy runs in a `finally` block wrapping the entire workflow — artifacts
are always copied whether the run succeeds or fails.

---

## Inspecting intermediate MLIR IR

`aw-compile` can dump a numbered MLIR snapshot after every pass. Enable it by adding
`debug_mode` and `debug_directory_path` to `compile_configuration.json`:

```json
{
    "debug_mode":           true,
    "debug_directory_path": "/debug",
    "import_path":          "add.onnx",
    "export_path":          "artifact/",
    "target": {
        "architecture":     "x86_64",
        "device":           "CPU"
    }
}
```

Snapshots are written to `<debug_directory_path>/mlir_snapshots/`:

```
mlir_snapshots/
├── 00.ONNXMLIRImporter.mlir   ← initial IR from the importer
├── 01.AetherToLinalg.mlir     ← after AetherToLinalg
└── ...
```

The initial snapshot (`00`) is named after the importer's `get_name()`. Each
subsequent snapshot is named after the pass that just ran, zero-padded to two digits.
When a pass fails, its snapshot is written as `NN.<Pass>.failed.mlir` and the
pipeline stops there. `aw-compile` empties `mlir_snapshots/` before the first
snapshot, so the directory only holds the snapshots of the last compilation.

`debug_mode: true` requires a non-empty `debug_directory_path`: `aw-compile`
rejects the configuration otherwise. If `mlir_snapshots/` cannot be emptied or
created, `aw-compile` prints an error, disables the snapshots and keeps compiling.

### Via Docker

Run a workflow with `AETHERWEAVE_DEBUG_DIRECTORY_PATH` set, exactly as in
[Inspecting intermediate workflow artifacts](#via-docker): the workflow enables
`debug_mode` and passes the same directory to `aw-compile`, so the snapshots land
in `debug/mlir_snapshots/`.

---

## Running a single pass with aw-opt

`aw-opt` is a standalone MLIR pass runner. It reads a `.mlir` file (such as
one of the snapshots above), applies one or more passes, and prints the result.
It ships in the `aetherweave` image under `./bin/` (it is not on the `PATH`):

```bash
# Apply only the AetherToLinalg pass and print the output
docker run --rm -v $(pwd)/debug:/debug aetherweave \
  ./bin/aw-opt --aether-to-linalg /debug/mlir_snapshots/00.ONNXMLIRImporter.mlir

# Print IR before and after every pass (verbose)
docker run --rm -v $(pwd)/debug:/debug aetherweave \
  ./bin/aw-opt --aether-to-linalg --mlir-print-ir-before-all --mlir-print-ir-after-all \
  /debug/mlir_snapshots/00.ONNXMLIRImporter.mlir
```

Each snapshot records what produced it as module attributes: `debug.origin`
holds the importer or pass name, and from snapshot `01` on, `debug.argument`
holds the pass's `aw-opt` flag (for example `aether-to-linalg`). To replay a
step, run `aw-opt` with the `debug.argument` of snapshot `NN` on snapshot `NN-1`.
The flag is recorded without its options: snapshot `02` records
`one-shot-bufferize`, while the pipeline runs it with
`bufferize-function-boundaries`.

`aw-opt` registers all dialects, bufferization interfaces, passes and pipelines
used in the CPU pipeline, so any snapshot from that pipeline can be fed directly
to it. For example, snapshot `01` replays the bufferization and deallocation
steps with `--one-shot-bufferize=bufferize-function-boundaries
--buffer-deallocation-pipeline`.
