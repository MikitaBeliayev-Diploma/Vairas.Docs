# Contract acceptance scenarios

These are documented implementation acceptance requirements. Executable checks belong with the backend/tooling outside this repository. This document does not claim runtime execution.

| Scenario | Expected result | Verification level |
|---|---|---|
| Every HTTP spec is parsed and examples checked | Valid OpenAPI 3.1; parameters resolve; all documented media have examples matching JSON Schema and format | Automated static |
| Required input omitted | Negative schema fixture is invalid; server should return documented 400 before side effects | Schema check executed; HTTP behavior requires runtime |
| UM routes and response enums | Exactly the 15 controller operations; response enum names match Program serializer and Domain declarations | Automated source check |
| Auth/School/Chat provider contract drifts from UM dependency view | Validator fails exact path-item comparison | Automated static |
| JWT absent, wrong issuer/audience, stale session | 401/403 or authoritative dependency failure; no profile access/mutation | Existing Backend scenarios inspected; runtime not executed here |
| Internal contact caller lacks permitted scope/client | Deny; no profile/contact leak | Runtime acceptance |
| Same profile command replayed / payload changed under key | Same recorded outcome / 409 IDEMPOTENCY_KEY_REUSED | Runtime acceptance |
| Stale profile or lesson revision | 409; original state retained; client refetches | Runtime acceptance |
| Cross-school enrollment/resource | Deny without foreign data; no new reservation | Runtime acceptance |
| Two schools reserve the same verified person concurrently | At most one conflicting reservation commits; generic unavailable outcome | Concurrency acceptance; G-02 |
| Group roster changes during proposal/lesson booking | Revalidate before change becomes effective; stale proposal cannot commit | Cross-service acceptance; G-03 |
| Scheduling acknowledgement lost | ReconciliationPending, protective reservation retained, same operation identity used for lookup/retry | Failure-injection acceptance |
| Source actual times missing or unverified | No practical/theory credit; never substitute scheduled duration | G-01 design amended; provider/runtime acceptance still required |
| One practical confirmation / wrong fact version / admin signing for participant | No credited minutes; wrong actor rejected | Runtime acceptance |
| Dual confirmation then dispute/correction | Remove prior credit once; new fact version requires fresh confirmations | Runtime acceptance |
| Failed mandatory prerequisite but assessor approves | Approval rejected; readiness differs from assessment result | Runtime acceptance |
| Journal missing fact/confirmation | Generated output visibly incomplete, not release-ready | Runtime acceptance |
| Internal completion report prepared | No claim of external Regitra transmission/acknowledgement | Contract/manual review |
| Event redelivered or older aggregate version arrives | One effect; older fact cannot restore obsolete projection/credit | Consumer runtime acceptance |
| Publisher/consumer event shape diverges | Structural validator fails | Automated static |
| Notification provider result unknown | DeliveryUnknown; no blind resend; reconcile first | Provider failure-injection acceptance |
| Optional MaintenanceScheduled consumed by current Notifications design | Disabled/rejected until G-04 resolved | Design gate |
| MCP lacks verifiable delegated end user | Private tool fails closed | Integration acceptance; G-06 |
| MCP preview arguments/actor/operation changed or approval expired | No write; new preview and human approval required | Runtime acceptance |
| Model supplies consent text | It does not create a backend confirmation | Security acceptance |
| Mutating MCP tool returns a pending operation | No success claim or duplicate retry; reconcile canonical API operation | Runtime acceptance |
| Markdown reference differs from YAML | Reconcile operation descriptions, schemas and examples before publication | Documentation review |
| Secret-like current text introduced | Remove credentials from documentation; review without exposing values | Security review |

## G-01 runtime acceptance

- Complete practical and theory lessons: actuals differ from plan, OLD state retained, revision advances and Outbox entry commits atomically.
- Missing/reversed/future actuals, wrong actor/tenant and stale expectedVersion reject without partial changes.
- Exact retry reuses the result; conflicting Idempotency-Key reuse rejects.
- Correct a completed interval: prior actuals survive in history, source revision changes, old Learning eligibility is blocked and new facts need fresh confirmations.
- Duplicate/late completion signals fetch current source and never double-credit; equal source revision with different fields fails closed.
- Legacy Completed without actuals returns sourceValid=false; no planned-time fallback. After verified recovery, validate the migration constraint.
