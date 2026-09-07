FROM ubuntu:26.04 AS compiler-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
       clang-20 llvm-20-dev libmlir-20-dev mlir-20-tools \
       cmake ninja-build git libzstd-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# protobuf 3.25 — provides ProtobufConfig.cmake (CONFIG mode) required by ONNXConfig.cmake.
# Ubuntu 26.04 ships protobuf 3.21 which only has FindProtobuf.cmake (MODULE mode).
RUN git clone --depth 1 --branch v3.25.3 --recurse-submodules --shallow-submodules \
      https://github.com/protocolbuffers/protobuf.git /tmp/protobuf \
    && cmake -S /tmp/protobuf -B /tmp/protobuf/build -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_C_COMPILER=clang-20 \
       -DCMAKE_CXX_COMPILER=clang++-20 \
       -Dprotobuf_BUILD_TESTS=OFF \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build /tmp/protobuf/build -j$(nproc) \
    && cmake --install /tmp/protobuf/build \
    && rm -rf /tmp/protobuf

# libonnx 1.22.0 — C++ parsing library + ONNXConfig.cmake for find_package(ONNX).
RUN git clone --depth 1 --branch v1.22.0 \
      https://github.com/onnx/onnx.git /tmp/onnx \
    && cmake -S /tmp/onnx -B /tmp/onnx/build -G Ninja \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_C_COMPILER=clang-20 \
       -DCMAKE_CXX_COMPILER=clang++-20 \
       -DONNX_BUILD_TESTS=OFF \
       -DONNX_BUILD_BENCHMARKS=OFF \
       -DONNX_BUILD_PYTHON=OFF \
       -DONNX_ML=1 \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build /tmp/onnx/build -j$(nproc) \
    && cmake --install /tmp/onnx/build \
    && find /tmp/onnx/build -name "*.pb.h" -exec cp {} /usr/local/include/onnx/ \; \
    && rm -rf /tmp/onnx

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
    && apt-get install -y python3 python3-pip llvm-20-runtime \
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
