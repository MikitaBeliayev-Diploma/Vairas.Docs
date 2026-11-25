# Vairas School Management API

Current implementation export, including optional Scheduling coordination and operator abort. Activation requires enabled owner integration; Learning completion remains gated.

| Method | Path | Behavior |
|---|---|---|
| POST | `/internal/v1/vehicle-authority/validate` | Validate exact current school/branch/administrator/teacher authority for Vehicle Management. |
| POST | `/internal/v1/profile-provisioning/validate` | Local-only read-only invitation/bootstrap validation for User Management; never calls UM back. |
| GET | `/internal/v1/enrollments/{enrollmentId}/eligibility` | Validate current school/enrollment/actor/teacher scope using authoritative global bindings. |
| GET | `/internal/v1/groups/{groupId}/participants` | Return the exact retained roster revision for a full lesson interval; never substitute current roster. |
| POST | `/api/v1/schools/{schoolId}/invitations` | Issue a 24-hour invitation to an exact UserId, with no membership activation. |
| GET | `/api/v1/schools/{schoolId}/invitations/{invitationId}` | Read an invitation as its target or a currently authorized issuer. |
| POST | `/api/v1/schools/{schoolId}/invitations/{invitationId}/accept` | Accept as the exact target; new effective membership/enrollment returns 503 before effects until Scheduling gate exists. |
| POST | `/api/v1/schools/{schoolId}/invitations/{invitationId}/revoke` | Revoke Pending invitation atomically; accepted membership is never compensated here. |
| GET | `/api/v1/users/me/invitations` | List only invitations addressed to the authenticated global UserId. |
| GET | `/api/v1/users/me/enrollments` | Read only the caller's enrollments, independently across schools and categories. |
| POST | `/internal/v1/scheduling/snapshots` | Current School authorization, exact interval and roster for Scheduling. |
| GET | `/internal/v1/scheduling/access` | Current school membership and explicit special permission evidence. |
| POST | `/internal/v1/scheduling/rule-scope` | Authorize the exact School rule resource scope. |
| GET | `/internal/v1/scheduling/coordination/{operationId}` | Return the durable local decision for Scheduling finalize/abort reconciliation. |
| POST | `/api/v1/schools/{schoolId}/memberships/{membershipId}/permissions` | Platform operator grants SchoolRuleOwner to an Administrator or Assessor to a Teacher. |
| POST | `/api/v1/schools/{schoolId}/permission-grants/{grantId}/revocation` | Revoke an exact permission grant with an accountable reason. |
| GET | `/api/v1/schools/{schoolId}/activation-operations/{operationId}` | Read only the caller's coordination outcome or a configured operator's scope. |
| POST | `/api/v1/schools/{schoolId}/activation-operations/{operationId}/abort` | Platform operator aborts only an intent with no local School commit; unknown Scheduling outcomes retain protection. |
| POST | `/api/v1/schools/{schoolId}/enrollments/{enrollmentId}/group-removal` | Remove one group association through the same durable reservation protocol. |
| GET | `/api/v1/schools/{schoolId}` | Read school metadata under current membership or configured operator authority. |
| PATCH | `/api/v1/schools/{schoolId}/name` | Rename a school without changing eligibility. |
| GET | `/api/v1/schools/{schoolId}/branches` | List branches in the authorized school. |
| POST | `/api/v1/schools/{schoolId}/branches` | Create a branch; this grants no membership or scheduling rights. |
| GET | `/api/v1/schools/{schoolId}/branches/{branchId}` | Read one same-school branch. |
| PUT | `/api/v1/schools/{schoolId}/branches/{branchId}` | Update branch display/address metadata with optimistic concurrency. |
| GET | `/api/v1/schools/{schoolId}/groups` | List only groups visible through the caller's school relationships. |
| POST | `/api/v1/schools/{schoolId}/groups` | Create an empty group and its initial immutable empty roster. |
| GET | `/api/v1/schools/{schoolId}/groups/{groupId}` | Read one authorized group. |
| PATCH | `/api/v1/schools/{schoolId}/groups/{groupId}/name` | Rename a group; branch, category and periods remain outside this command. |
| GET | `/api/v1/schools/{schoolId}/memberships` | Read school-local roles; global profiles do not imply these roles. |
| GET | `/api/v1/schools/{schoolId}/enrollments/{enrollmentId}` | Read a specific enrollment under self, school administrator or assigned-teacher authority. |
| GET | `/api/v1/schools/{schoolId}/planning-inputs` | Check actual missing school planning dependencies; absent providers never produce complete=true. |
| POST | `/api/v1/schools/{schoolId}/enrollments` | Create enrollment. Uses durable Scheduling eligibility coordination. |
| PUT | `/api/v1/schools/{schoolId}/enrollments/{enrollmentId}/group-assignment` | Assign group/programme. Requires Scheduling coordination and verified Learning programme applicability; missing integration is absent. |
| POST | `/api/v1/schools/{schoolId}/enrollments/{enrollmentId}/termination` | End enrollment. No lifecycle activation without Scheduling and completion evidence where required. |
| POST | `/api/v1/schools/{schoolId}/memberships/{membershipId}/termination` | End membership. Requires coordinated source invalidation; currently unavailable. |
| POST | `/api/v1/schools/{schoolId}/groups/{groupId}/teacher-assignments` | Assign a teacher to a group. Activation is unavailable without Scheduling coordination. |
| POST | `/api/v1/schools/{schoolId}/status` | Change school status. Requires coordinated eligibility invalidation; currently unavailable. |
| POST | `/api/v1/schools/{schoolId}/branches/{branchId}/status` | Change branch status. Requires coordinated eligibility invalidation; currently unavailable. |
