# Agent Observability with OpenTelemetry

A vendor-neutral local observability lab for AI coding agents.

This repository shows how to collect useful engineering signals from an AI coding session and make them available in Grafana through OpenTelemetry, the OpenTelemetry Collector, and Prometheus.

The example uses OpenCode because it is easy to extend locally and the OpenTelemetry adapter is available as a public package. The backend is not tied to OpenCode. The same Collector and Prometheus setup can receive telemetry from Codex, Claude Code, Cursor, or another agent whenever the tool provides a native exporter, plugin, hook, or a small adapter that speaks OTLP.

## What this repository includes

- OpenTelemetry Collector with OTLP gRPC and HTTP receivers
- Prometheus as a local metrics backend
- Grafana with a provisioned dashboard
- A documented OpenCode adapter configuration
- Security and privacy guidance for agent telemetry
- Queries that help answer engineering questions instead of measuring activity for its own sake

## Architecture

```text
AI coding tool
     |
     | native exporter, plugin, hook, or adapter
     v
OpenTelemetry Protocol (OTLP)
     |
     v
OpenTelemetry Collector
     |
     v
Prometheus <---- Grafana
```

The Collector is the transport and processing layer. Prometheus stores metrics. Grafana visualizes them. They have different responsibilities, even though all three run locally in this example.

## Requirements

- Docker Desktop with Compose v2
- OpenCode 1.17 or later for the example adapter
- An AI provider configured in the selected coding tool

OpenTelemetry itself is an open source project and this local stack uses free and open source components. A managed observability service can replace Prometheus and Grafana later, but it is not required for this lab.

## Start the stack

```bash
docker compose up -d
```

Open the following services:

- Grafana: http://localhost:3001
- Prometheus: http://localhost:9090
- Collector health check: http://localhost:13133

Grafana credentials for this local example are `admin` and `admin`. Change them before exposing Grafana outside your machine.

The dashboard has a `Session` variable. Select one `session_id` to inspect a single local run, or keep `All` to see the aggregate view.

## Connect OpenCode

The OpenCode application does not provide this telemetry backend by itself. The example uses the community package `@devtheops/opencode-plugin-otel` as an instrumentation adapter.

Add the plugin to `~/.config/opencode/opencode.json` while preserving your existing plugins:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "@devtheops/opencode-plugin-otel"
  ]
}
```

Enable only the local telemetry path in the shell where OpenCode will run:

```bash
source examples/opencode-environment.sh
opencode
```

The script exports:

```bash
export OPENCODE_ENABLE_TELEMETRY=1
export OPENCODE_OTLP_ENDPOINT=http://localhost:4317
export OPENCODE_OTLP_PROTOCOL=grpc
export OPENCODE_OTLP_METRICS_INTERVAL=5000
export OPENCODE_DISABLE_LOGS=1
export OPENCODE_DISABLE_TRACES=all
```

Use `source`, not `./examples/opencode-environment.sh`, because the variables must remain available in the same shell that starts OpenCode. If OpenCode is already open, close it and start it again from that terminal.

The last two variables keep this first example focused on metrics and prevent prompt or trace payloads from entering the local stack. The adapter has options for logs and traces, but they should be enabled only after reviewing the data policy for the destination.

Run OpenCode normally, complete a small task, and wait for the export interval. The dashboard should then show session, message, token, tool, duration, and error signals when the adapter emits them.

## Metrics to explore

The adapter uses OpenTelemetry metric names such as:

- `opencode.session.count`
- `opencode.message.count`
- `opencode.token.usage`
- `opencode.tool.duration`
- `opencode.session.duration`
- `opencode.retry.count`

Prometheus exposes these names with underscores and counter suffixes. The dashboard includes panels for the most useful signals, but the exact set depends on the adapter version and the events produced by the tool.

Useful questions include:

- How many sessions finish successfully?
- Where does time go: model calls or tools?
- Are retries or tool errors increasing?
- Are token and cost trends changing after a workflow change?
- Does a new skill reduce repeated exploration or increase it?

The goal is not to rank developers or agents by raw activity. The goal is to understand the quality, cost, latency, and safety of an engineering workflow.

## Privacy and security defaults

Agent telemetry can contain source code, prompts, file paths, tool arguments, secrets, and customer data. Treat it as sensitive operational data.

This repository recommends:

- Do not capture full prompts by default.
- Do not export tool arguments or tool results unless they are explicitly sanitized.
- Do not use session IDs, prompt text, file paths, or commit messages as Prometheus labels in shared or production environments.
- Keep telemetry endpoints on a private network.
- Use the least-privileged credentials possible for managed destinations.
- Set retention and access policies before collecting data from a team.
- Review adapter upgrades because telemetry fields can change over time.

The local configuration disables logs and traces to make the first run safer. This local dashboard keeps `session_id` so a developer can filter one test session while debugging. That is convenient for a laptop lab, but it creates high-cardinality time series and should not be copied blindly to a shared production Prometheus. In production, remove the label and route sanitized traces or logs to a backend designed for session-level drill-down.

## Other AI coding tools

The backend does not require OpenCode. For another tool, keep the Collector, Prometheus, and Grafana configuration and replace only the instrumentation layer:

1. Find a native OTLP exporter, plugin, hook, or integration.
2. Map its events to stable concepts such as session, model request, tool call, approval, error, and outcome.
3. Keep sensitive payloads out of metrics and high-cardinality labels.
4. Point the exporter to the same OTLP Collector endpoint.
5. Update dashboard queries only when the metric names differ.

If a tool has no exporter or extension point, it may still be possible to instrument the surrounding workflow, but that will provide less detail than direct session instrumentation.

## Stop the stack

```bash
docker compose down
```

## License

MIT
