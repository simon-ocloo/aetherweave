# Running AetherWeave

Everything runs inside the `aetherweave` image (see [BUILDING.md](BUILDING.md)).

---

## Workflows

A workflow is a named end-to-end scenario driven by `aw-run`: it prepares the model and its inputs, calls the AetherWeave tools and verifies the result. Workflows are defined in `library/workflow/`.

```bash
# Run the default workflow (mock)
docker run --rm aetherweave

# Run a named workflow
docker run --rm aetherweave ./aw-run workflow --name <name>
```

---

## Configuration files

Each binary takes a single JSON configuration file as its only argument. Workflows generate them; they can also be written by hand to run a tool directly.

`aw-compile compile_configuration.json`:

```json
{
    "debug_mode":           true | false,
    "debug_directory_path": "<path>" | null,
    "import_path":          "<path>",
    "export_path":          "<path>",
    "target": {
        "device":           "<device>",
        "architecture":     "<architecture>"
    }
}
```

`aw-execute execute_configuration.json`:

```json
{
    "debug_mode":           true | false,
    "debug_directory_path": "<path>" | null,
    "import_path":          "<path>",
    "mode":                 "inference" | "training",
    "inputs":               ["<path>", ...],
    "outputs":              ["<path>", ...]
}
```

- `debug_mode: true` requires a non-empty `debug_directory_path` (see [DEBUGGING.md](DEBUGGING.md)).
