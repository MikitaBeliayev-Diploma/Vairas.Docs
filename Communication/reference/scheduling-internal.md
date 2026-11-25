# Vairas Scheduling Internal Coordination API

Implemented HTTP contract; generated from the current ASP.NET Core application. Missing providers fail closed. See the Scheduling implementation contract amendments for version differences.

| Method | Path | Behavior |
|---|---|---|
| POST | `/internal/v1/vehicle-blocks` | Acquire an immediate durable vehicle booking block. |
| GET | `/internal/v1/vehicle-blocks/by-operation/{operationId}` | Resolve a lost vehicle block acknowledgement. |
| POST | `/internal/v1/vehicle-blocks/{blockId}/release` | Release one precisely identified block using a distinct command identity. |
| POST | `/internal/v1/school-eligibility-operations` | Freeze eligibility and protect roster additions before School changes become effective. |
| GET | `/internal/v1/school-eligibility-operations/{operationId}` | Resolve School coordination by its exact immutable operation identity. |
| POST | `/internal/v1/school-eligibility-operations/{operationId}/{decision}` | Finalize only after verifying the authoritative School decision. |
| GET | `/internal/v1/schools/{schoolId}/lesson-impacts` | Return only the owning school's future allocations for preparing an exact change. |
