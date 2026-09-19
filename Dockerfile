FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
        llvm-20-runtime \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages \
        --extra-index-url https://download.pytorch.org/whl/cpu \
        numpy==2.5.3 \
        onnx==1.23.0 \
        torch==2.14.0+cpu

WORKDIR /workspace
COPY ./library/ ./library/
COPY ./aw-run ./aw-run
COPY --from=compiler-stage /workspace/bin/ ./bin/
COPY --from=executor-stage /workspace/bin/ ./bin/

CMD ["./aw-run", "workflow", "--name", "mock"]
