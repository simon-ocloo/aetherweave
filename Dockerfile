FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
        python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY ./library/ ./library/
COPY ./aw-run ./aw-run
COPY --from=compiler-stage /workspace/bin/ ./bin/
COPY --from=executor-stage /workspace/bin/ ./bin/

CMD ["./aw-run", "workflow", "--name", "mock"]
