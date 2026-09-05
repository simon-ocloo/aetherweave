FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/workspace:/workspace/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir --break-system-packages \
    --extra-index-url https://download.pytorch.org/whl/cpu \
    torch numpy onnx

RUN pip3 install --no-cache-dir --break-system-packages \
    --extra-index-url https://download.pytorch.org/whl/cpu \
    torch numpy onnx

WORKDIR /workspace

COPY --from=compiler-stage /workspace/bin/ ./bin/
COPY --from=executor-stage /workspace/bin/ ./bin/
COPY ./library/ ./library/
COPY ./aw-run ./aw-run

CMD ["aw-run", "workflow", "--name", "mock"]
