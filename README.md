# AetherWeave

*Aether* is the abstract substance — a neural network expressed as pure, hardware-agnostic operations in the `aether` dialect. *Weave* is the process of making it physical — lowering those operations pass by pass through the compiler, then driving their execution on a device through the executor.

The weave is complete only when operations run on metal. The `aether` never touches the runtime.

---

## Overview

AetherWeave is an AOT ML compiler and executor built from scratch. It takes an ONNX model as input, compiles it to native kernels, and executes those kernels for training or inference — without delegating to any external ML framework.

The compiler produces self-contained artifacts (compiled kernels + metadata). The executor loads them via `dlopen` and drives the training loop or inference entirely from scratch, with no knowledge of MLIR or the dialect.

The architecture reflects the philosophy directly: the `aether` dialect knows nothing about hardware, so adding a new target — CPU, CUDA, ROCm, NPU, FPGA, ... — means adding new lowering passes at the bottom of the pipeline, with no refactoring anywhere else. Likewise, at every level of the pipeline, a hand-written implementation takes priority over a generated one.

---

## Repositories

| Repo | Language | Role |
|---|---|---|
| [`aetherweave-compiler`](https://github.com/simon-ocloo/aetherweave-compiler) | C++ | ONNX import, `aether` dialect, optimization and lowering passes, artifact export |
| [`aetherweave-executor`](https://github.com/simon-ocloo/aetherweave-executor) | Rust | artifact import, kernel dispatcher, training and inference loop |
| [`aetherweave`](https://github.com/simon-ocloo/aetherweave) | Python | docker, `aw-run`, documentation, artifact schema |

---

## Tools

| Tool | Repo | Description |
|---|---|---|
| `aw-compile` | compiler | Compiles an ONNX model into training and inference artifacts |
| `aw-execute` | executor | Executes a compiled artifact (`--mode inference` or `--mode training`) |
| `aw-opt` | compiler | Standalone MLIR pass runner for debugging passes in isolation |
| `aw-run` | orchestration | Unified CLI. Entry point for all top-level operations |
