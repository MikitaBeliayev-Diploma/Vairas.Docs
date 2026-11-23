# Vairas — Integration Event Catalog v0.1

**Status:** proposed; 2026-11-15. The event names are mapped to existing DDD domain events unless clearly marked NEW. The exact integration payloads, channel addresses, subscriber topology and transport have **not** been approved/implemented.

**Source of truth:** each service owns and emits its own committed facts. The specifications in `Communication/Async Api/` are the provider/consumer-specific AsyncAPI 3.0.0 views. Producer and consumer payloads and JSON envelope examples must remain consistent when a contract changes.

Implementation update: User Management now persists and publishes `UserDeactivated` through its outbox and Service Bus adapter. Its sender contract has automated coverage; broker provisioning, live delivery and School/Scheduling subscribers are not implemented by this change. Other rows retain their stated proposal status.

| Event | Publisher | Subscribers | Logical topic | Status |
|---|---|---|---|---|
| `StudentEnrollmentStarted` | School Management | Learning Tracking, Scheduling | `vairas.school.enrollment-started.v1` | Domain event named; payload proposed |
| `StudentEnrollmentCompleted` | School Management | Learning Tracking, Scheduling | `vairas.school.enrollment-completed.v1` | Domain event named; payload proposed |
| `StudentEnrollmentEnded` | School Management | Learning Tracking, Scheduling | `vairas.school.enrollment-ended.v1` | Domain event named; payload proposed |
| `StudentAssignedToGroup` | School Management | Scheduling | `vairas.school.student-assigned-to-group.v1` | Domain event named; payload proposed |
| `StudentRemovedFromGroup` | School Management | Scheduling | `vairas.school.student-removed-from-group.v1` | Domain event named; payload proposed |
| `TeacherAssignedToGroup` | School Management | Scheduling | `vairas.school.teacher-assigned-to-group.v1` | Domain event named; payload proposed |
| `SchoolMembershipEnded` | School Management | Scheduling | `vairas.school.membership-ended.v1` | Domain event named; payload proposed |
| `VehicleDeactivated` | Vehicle Management | Scheduling | `vairas.vehicle.deactivated.v1` | Domain event named; payload proposed |
| `VehicleActivated` | Vehicle Management | Scheduling | `vairas.vehicle.activated.v1` | Domain event named; payload proposed |
| `MaintenanceScheduled` | Vehicle Management | Notifications | `vairas.vehicle.maintenance-scheduled.v1` | Optional; blocked by current Notifications DB source/type constraints (G-04) |
| `MaintenanceStarted` | Vehicle Management | Scheduling | `vairas.vehicle.maintenance-started.v1` | Domain event named; payload proposed |
| `MaintenanceCompleted` | Vehicle Management | Scheduling | `vairas.vehicle.maintenance-completed.v1` | Domain event named; payload proposed |
| `LessonScheduled` | Scheduling | Notifications | `vairas.scheduling.lesson-scheduled.v1` | Domain event named; payload proposed |
| `LessonRescheduled` | Scheduling | Notifications | `vairas.scheduling.lesson-rescheduled.v1` | Domain event named; payload proposed |
| `LessonCancelled` | Scheduling | Notifications | `vairas.scheduling.lesson-cancelled.v1` | Domain event named; payload proposed |
| `LessonCompleted` | Scheduling | Learning Tracking | `vairas.scheduling.lesson-completed.v1` | Domain event named; payload proposed |
| `AssessmentPassed` | Learning Tracking | Notifications | `vairas.learning.assessment-passed.v1` | Domain event named; payload proposed |
| `AssessmentFailed` | Learning Tracking | Notifications | `vairas.learning.assessment-failed.v1` | Domain event named; payload proposed |
| `PracticalRecordConfirmed` | Learning Tracking | Document Management | `vairas.learning.practical-record-confirmed.v1` | **NEW — approval needed** |
| `PracticalRecordRevised` | Learning Tracking | Document Management | `vairas.learning.practical-record-revised.v1` | **NEW — approval needed** |
| `UserDeactivated` | User Management | School Management, Scheduling | `vairas.user.deactivated.v1` | Sender implemented; consumers and live delivery unverified |

## Notes

- **Producer/consumer semantics:** `send` = service publishes, `receive` = service consumes. Topic ACLs, retention and routing policies govern production message delivery.
- **School scope:** almost all events include `schoolId` in payload. `UserDeactivated` is global and intentionally has no schoolId; distribute only to trusted, narrowly authorized consumers.
- **Identity:** `EnrollmentId` distinguishes enrollment histories for a student across schools. Do not use `StudentId` as a substitute for enrollment on training credit or journal queries.
- **Schema version:** `.v1` logical address plus header `eventVersion: 1`. The producer's `aggregateVersion` increases for the same `aggregateId`. An eventId identifies one immutable event and remains stable across redeliveries; it is not a business entity ID or a fresh ID for each delivery attempt.
- **Schema evolution:** breaking field changes or semantics require `.v2` event/topic, side-by-side delivery during migration; consumers must not read arbitrary fields from other tenants.
- **Credit safety:** `LessonCompleted` only records lesson lifecycle. Learning Tracking derives practical credit from a current Valid fact version, verified current source and instructor/student confirmations of that same version, without a later dispute. `PracticalRecordConfirmed` notifies downstream consumers; receiving or publishing it is not the credit authority. Theory requires a verified source, the complete immutable as-of roster and assigned-teacher confirmation of the current Valid version: Present receives full minutes, Absent zero. Corrections require new fact versions and fresh required confirmations.
- **Saga safety:** `MaintenanceStarted` is a post-commit fact, never a substitute for the synchronous `BlockVehicleBookings` Saga step. Emergency faults may require fail-closed validation and follow-up reconciliation.
- **Document history:** `PracticalRecordRevised` invalidates operational readiness of old generated artifacts but must not overwrite historical files.

See the [architecture alignment audit](../../audit/architecture-alignment.md) for five producer topics, ten proposed consumer service pairs and unresolved owner gates. Logical event addresses are not physical broker topic names.
