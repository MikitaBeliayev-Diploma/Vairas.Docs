# Communication documentation coverage

This matrix maps documentation to service-contract review needs. The expert-specific Database and Microservices requirements are in the [repository overview](../../README.md). Documentation coverage does not establish a grade or completed implementation.

| Review area | Material | Limitation |
|---|---|---|
| Endpoints, parameters, formats, authentication and errors | [HTTP reference](../reference/README.md), [security](../guides/security.md), [errors](../guides/errors-and-reliability.md) | Provider status is stated per operation |
| Machine-readable contracts | [OpenAPI](../Api/), [AsyncAPI](<../Async Api/>), [review scope](validation-results.md) | Schema-valid contracts do not prove running services |
| Requests, responses, status codes, models and edge examples | Canonical operation examples and reference model tables | Runtime behavior needs implementation evidence |
| Onboarding and integration | [Getting Started](../guides/getting-started.md), [profile](../guides/profile-integration.md), [booking](../guides/booking-integration.md) | Profile workflows require external providers; booking is proposed |
| Architecture and inter-service communication | [Interaction diagrams](../diagrams/integration-flows.md), [architecture](<../../Microservices architecture/README.md>) | Deployment and broker topology remain design requirements |
| Naming, versions and maintenance | [Versioning](../guides/versioning.md), [changelog](../CHANGELOG.md), [BA coverage](business-coverage.md) | Update provider/consumer views and reference together |
| Reliability and security | [Reliability](../guides/errors-and-reliability.md), [security](../guides/security.md), [acceptance requirements](acceptance-scenarios.md) | Concurrency, recovery, authorization and tracing need runtime evidence |

## Submission checklist

- Keep readable Markdown, canonical contracts and synthetic examples in the documentation repository.
- Keep executable validation/test tooling and dependency caches with implementation tooling outside this repository.
- Store secrets outside Git; review current text, binary files and history before publication.
- Explain interface ownership, documentation strategy and remaining limitations in the written report.
- Demonstrate the required running services, gateway, database isolation, health and correlated logs separately from these artifacts.
