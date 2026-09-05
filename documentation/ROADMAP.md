# Roadmap

## Objectives

AetherWeave is built around two independent learning objectives.

**Objective 1 — Master MLIR/LLVM** through a real ML compiler: define a custom
dialect, write optimization and lowering passes, generate hardware-specific code
for any target device.

**Objective 2 — Implement training and inference from scratch** — forward pass,
activations, loss, backpropagation, gradient descent, weight updates. Every step
of the neural network math, owned by the executor, without delegating to any
external framework.

---

## Milestones

| # | Goal | Status |
|---|---|---|
| 1 | `aether.add` end-to-end on CPU — single-node ONNX to verified output | 🔄 in progress |
| 2 | `aether.matmul` + `aether.add` → Dense layer | |
| 3 | Activations: ReLU, Sigmoid, Softmax | |
| 4 | Elementwise fusion — first optimization pass | |
| 5 | Matmul + bias + activation fusion | |
| 6 | Benchmarking infrastructure | |
| 7 | Loss + backward + weight update → first training loop | |
| 8 | MNIST on a dense network — first full training from scratch | |
| 9 | Convolution, BatchNorm, Pooling | |
| 10 | Skip connections (branching graphs) | |
| 11 | ResNet50 — first large CV model end-to-end | |
| 12 | Quantization: INT8 / FP16 inference | |
| 13 | GPU backend: CUDA | |
| 14 | Attention, LayerNorm → Transformer block | |
| 15 | LLM inference (on CUDA) | |
| 16 | GPU backend: ROCm | |

---

## Milestone 1 — `aether.add` end-to-end

Goal: validate the full pipeline with the simplest possible op.
Input: a single-node ONNX Add model. Output: verified numerical result.

| Step | Description | Status |
|---|---|---|
| 1 | Workflow `add` — end-to-end test script: export model, compile, execute, verify | ✅ |
| 2 | `aether.add` dialect — op definition and build wiring | ✅ |
| 3 | ONNX importer — read model, emit `aether.add` IR | |
| 4 | Lowering pass — `aether.add` to low-level IR | |
| 5 | Full compilation pipeline — dialect to native code | |
| 6 | AOT compilation — produce artifact (`kernels.so` + `metadata.json`) | |
| 7 | Executor — load artifact, run kernel, write output | |
| 8 | End-to-end — `docker run aetherweave aw-run workflow --name add` | |
