FROM ubuntu:26.04 AS compiler-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y clang-20 llvm-20-dev libmlir-20-dev mlir-20-tools cmake ninja-build ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY ./aetherweave-compiler/ ./aetherweave-compiler/
RUN cd ./aetherweave-compiler \
    && cmake --preset=release \
    && cmake --build ./build -j$(nproc) \
    && cmake --install ./build --prefix /workspace/aetherweave-compiler

# ─────────────────────────────────────────────────────────────────────────────

FROM ubuntu:26.04 AS executor-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y curl ca-certificates gcc \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /workspace
COPY ./aetherweave-executor/ ./aetherweave-executor/
RUN cd ./aetherweave-executor \
    && cargo install --path ./tools/aw-execute --root /workspace/aetherweave-executor

# ─────────────────────────────────────────────────────────────────────────────

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages \
    --extra-index-url https://download.pytorch.org/whl/cpu \
    torch numpy onnx

WORKDIR /workspace

COPY --from=compiler-builder /workspace/aetherweave-compiler/bin/ ./bin/
COPY --from=executor-builder /workspace/aetherweave-executor/bin/ ./bin/

COPY ./library/ ./library/
COPY ./aw-run ./aw-run
RUN chmod +x ./aw-run

ENV PATH="/workspace/bin:/workspace:${PATH}"

CMD ["aw-run", "workflow", "--name", "mock"]
