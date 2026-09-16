# Architecture Notes

## Responsibilities

### Instrumentation adapter

The adapter observes the coding tool lifecycle and translates events into OpenTelemetry signals. It is the only component that needs to understand a specific tool.

### OpenTelemetry Collector

The Collector receives OTLP, applies processing, and routes data to one or more backends. It prevents the coding tool from depending directly on a particular storage or visualization product.

### Prometheus

Prometheus stores the metrics exported by the Collector and provides the query language used by the dashboard.

### Grafana

Grafana displays the Prometheus queries and can later combine them with trace and log backends.

## Why the first version is metrics focused

Metrics answer aggregate questions safely and cheaply. Prompts, tool arguments, source files, and full trace payloads can contain sensitive data and require a stronger data governance decision.

The Collector accepts logs and traces in this example and sends them to a debug exporter so the pipeline can be inspected locally. The default OpenCode environment disables those signals. A production design should route them to dedicated backends with redaction, access control, and retention policies.
