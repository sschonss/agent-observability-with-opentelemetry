#!/usr/bin/env bash

# Keep this shell scoped to the current terminal session.
export OPENCODE_ENABLE_TELEMETRY=1
export OPENCODE_OTLP_ENDPOINT=http://localhost:4317
export OPENCODE_OTLP_PROTOCOL=grpc

# Start with metrics only. Enable logs or traces only after reviewing data policy.
export OPENCODE_DISABLE_LOGS=1
export OPENCODE_DISABLE_TRACES=all

echo "OpenCode telemetry environment configured for localhost:4317"
