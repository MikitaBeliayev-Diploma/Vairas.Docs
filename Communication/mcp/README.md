# MCP contracts

The [tool catalogue](tools.json) is a proposed `tools/list` result with JSON Schema input/output definitions, examples, implementation status and REST mappings. It contains the five architecture-baseline tools plus three proposed BA extensions: personal lessons, rescheduling preview and approved rescheduling. No MCP runtime is implemented by this package.

All results are objects suitable for structured tool output. The REST adapter wraps list responses where the tool output needs an object. Preview tools call availability, then create an expiring server-side preview in the Chat/adapter layer; the mapped availability endpoint itself does not allocate previews or grant human approval. The adapter resolves target lesson resources from authorized current state before querying a reschedule preview.

Write tools pass only canonical business arguments downstream. `operationId` maps to `Idempotency-Key`; preview/confirmation metadata must be independently validated by the server and conveyed through an implemented, verified delegation mechanism. The public Scheduling request schema does not accept arbitrary extra approval fields. Do not enable private tools before user identity delegation, exact approval validation and business API parity are implemented and tested.

An MCP protocol/transport authentication failure is handled at that layer. A tool-level business failure returns `isError: true` with a non-sensitive error code, correlation ID and recovery guidance in content; it does not satisfy the success `outputSchema`. Normal structured output must validate against the advertised outputSchema. Invalid arguments are rejected before executing a business action. Required error categories: unauthenticated/forbidden, invalid arguments, stale or missing confirmation, conflict, dependency unavailable and reconciliation pending. Hints in `annotations` never authorize an operation.

Booking success can be an immediate committed lesson or a pending SchedulingOperation. The tool output normalizes either result into an operation view; for a committed lesson use the submitted operationId, status Committed and returned lessonId. On a timeout the adapter queries the same operation identity. Rescheduling pending output is separately represented in its output schema. Approval allocation must precede final fingerprinting; do not reuse the profile-only confirmation contract for a Scheduling command.

See the [booking tutorial](../guides/booking-integration.md), [security guide](../guides/security.md) and [acceptance scenarios](../audit/acceptance-scenarios.md).

The [MCP architecture](<../../Microservices architecture/assets/diagrams/10-ai-agent-mcp-architecture.md>) and [tool sequence](<../../Microservices architecture/assets/diagrams/11-ai-agent-tool-sequence.md>) describe the intended interaction and authorization requirements. Backend HTTP contracts are in [Api](../Api/); asynchronous event contracts are in [Async Api](<../Async Api/>).

[Communication contracts](../README.md)
