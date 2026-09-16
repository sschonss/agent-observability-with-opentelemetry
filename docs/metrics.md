# Metric Semantics

Metric names depend on the instrumentation adapter. The OpenCode example uses the `opencode.` prefix and the Collector adds the `agent_` namespace when exposing them to Prometheus. The local dashboard keeps `session_id` as a development-only filter. For shared or production metrics, remove it because it creates high-cardinality time series.

The dashboard is intentionally based on stable concepts:

- sessions started
- assistant messages completed
- token usage by type
- tool execution duration and success
- session duration
- retries and errors

Do not add raw prompt text, file paths, source code, session IDs, or arbitrary tool arguments as Prometheus labels. Those values create privacy risks and high-cardinality time series. Keep them in a controlled trace or log backend only when there is a justified use case.

Metrics should support a decision. For example, a rise in session duration may lead to an investigation of context discovery, tool latency, model choice, or an approval workflow. It should not be treated as a productivity score by itself.
