# Authentication — Data Dictionary

Current source: [authentication.dbml](../schema/schema.dbml), SHA-256 `4d03807e055927b1ce2cac1faee1ad0bfdf7d01444a5b3fc5780d4643a1f3401`. Current tactical proposal; no deployed handlers inferred.

8 tables / 59 columns. This dictionary is an enriched source-derived specification, not a claim of deployed APIs. No cross-service FK.

Classification is conservative: even opaque identifiers/audit timestamps can be personal when linked. No legal retention duration or GDPR certification is inferred.

## identity

Global authentication account; immutable IdentityId is JWT subject, independent of User Management UserId.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| identity_id | uuid | NOT NULL; default none | PK(identity_id) | Stable identifier within identity ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| login_email | varchar(254) | NULL; default none | UNIQUE(login_email) | Authentication login/challenge address, distinct from UM optional business contact. | Personal/contact |
| email_verified_at | timestamptz | NULL; default none | Non-key attribute | Recorded proof of control of login address, not physical-person identity proof. | Personal/contact |
| security_state | varchar(16) | NOT NULL; default Enabled | Non-key attribute | Enabled/Disabled account-security gate, distinct from UM Active/Inactive. | Operational/configuration metadata; restricted if linked to a person |
| credential_revision | bigint | NOT NULL; default 1 | Non-key attribute | Monotonic security version binding stale password/challenge operations. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Recorded created instant for identity; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(identity_id)`.
- UNIQUE `(login_email)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `identity_id`, `created_at`.

## password_credential

Optional one-to-one local password credential child of Identity.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| identity_id | uuid | NOT NULL; default none | PK(identity_id); local FK (identity_id) → identity(identity_id) | Stable identifier within password_credential ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| password_hash | text | NOT NULL; default none | Non-key attribute | Encoded salted Argon2id record, not plaintext or reusable encrypted password. | Restricted credential/security material (digests/ciphertext remain sensitive) |
| changed_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Password replacement time, independent of account profile edits. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(identity_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `identity_id`.

## external_identity

Exact configured OIDC issuer/opaque subject binding to a local Identity.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| external_identity_id | uuid | NOT NULL; default none | PK(external_identity_id) | Stable identifier within external_identity ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| identity_id | uuid | NOT NULL; default none | local FK (identity_id) → identity(identity_id) | Local Authentication account, not UM UserId. | Pseudonymous personal/security identifier |
| issuer | varchar(512) | NOT NULL; default none | UNIQUE(issuer,subject) | Exact allowlisted provider issuer, not an arbitrary request URL. | Operational/configuration metadata; restricted if linked to a person |
| subject | varchar(255) | NOT NULL; default none | UNIQUE(issuer,subject) | Opaque case-sensitive provider subject under issuer. | Operational/configuration metadata; restricted if linked to a person |
| linked_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Recorded linked instant for external_identity; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(external_identity_id)`.
- UNIQUE `(issuer, subject)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `external_identity_id`, `issuer`, `subject`, `identity_id`, `linked_at`.

## auth_session

Authenticated account session with absolute expiry and revocation.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| session_id | uuid | NOT NULL; default none | PK(session_id); UNIQUE(session_id,identity_id) | Stable identifier within auth_session ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| identity_id | uuid | NOT NULL; default none | UNIQUE(session_id,identity_id); local FK (identity_id) → identity(identity_id) | Stable identifier within auth_session ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| auth_method | varchar(16) | NOT NULL; default none | Non-key attribute | Password or Oidc entry path, not school role. | Operational/configuration metadata; restricted if linked to a person |
| created_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Recorded created instant for auth_session; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| expires_at | timestamptz | NOT NULL; default none | Non-key attribute | Absolute session expiry, not JWT issue/expiry. | Operational/configuration metadata; restricted if linked to a person |
| revoked_at | timestamptz | NULL; default none | Non-key attribute | Authoritative explicit session revocation time; NULL means no recorded revocation, not necessarily valid now. | Operational/configuration metadata; restricted if linked to a person |
| revocation_reason | varchar(40) | NULL; default none | Non-key attribute | Revocation reason belonging to auth_session; Authentication sign-in/session administration. | Restricted free text/document/payload; may contain personal data |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(session_id)`.
- UNIQUE `(session_id, identity_id)`.
- INDEX `(identity_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `session_id`, `identity_id`, `auth_method`, `created_at`, `expires_at`.

## refresh_token

Single-use digest-only refresh lineage with replay revocation.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| refresh_token_id | uuid | NOT NULL; default none | PK(refresh_token_id); UNIQUE(refresh_token_id,session_id) | Stable identifier within refresh_token ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| session_id | uuid | NOT NULL; default none | UNIQUE(refresh_token_id,session_id); UNIQUE(parent_token_id,session_id); local FK (session_id) → auth_session(session_id); local FK (parent_token_id,session_id) → refresh_token(refresh_token_id,session_id) | Stable identifier within refresh_token ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| parent_token_id | uuid | NULL; default none | UNIQUE(parent_token_id,session_id); local FK (parent_token_id,session_id) → refresh_token(refresh_token_id,session_id) | Prior consumed refresh record in exactly the same session. | Scoped identifier; linkability/access control required |
| secret_digest | varchar(64) | NOT NULL; default none | UNIQUE(secret_digest) | SHA-256 of CSPRNG refresh secret, never the token itself. | Restricted credential/security material (digests/ciphertext remain sensitive) |
| created_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Recorded created instant for refresh_token; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| expires_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded expires instant for refresh_token; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| consumed_at | timestamptz | NULL; default none | Non-key attribute | Single-use consumption time; reuse subsequently revokes family. | Operational/configuration metadata; restricted if linked to a person |
| revoked_at | timestamptz | NULL; default none | Non-key attribute | Family/security revocation metadata distinct from consumption. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(refresh_token_id)`.
- UNIQUE `(refresh_token_id, session_id)`.
- UNIQUE `(parent_token_id, session_id)`.
- UNIQUE `(secret_digest)`.
- INDEX `(session_id)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `refresh_token_id`, `session_id`, `parent_token_id`, `secret_digest`, `created_at`, `expires_at`.

## account_challenge

Single-use challenge pinned to exact login address and credential revision.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| challenge_id | uuid | NOT NULL; default none | PK(challenge_id) | Stable identifier within account_challenge ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| identity_id | uuid | NOT NULL; default none | local FK (identity_id) → identity(identity_id) | Stable identifier within account_challenge ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| purpose | varchar(20) | NOT NULL; default none | Non-key attribute | VerifyEmail or ResetPassword, never SchoolInvitation. | Operational/configuration metadata; restricted if linked to a person |
| login_email | varchar(254) | NOT NULL; default none | Non-key attribute | Address at challenge issue, not a join to mutable current contact. | Personal/contact |
| credential_revision | bigint | NOT NULL; default none | Non-key attribute | Expected account credential revision at consumption. | Operational/configuration metadata; restricted if linked to a person |
| secret_digest | varchar(64) | NOT NULL; default none | UNIQUE(secret_digest) | Secret digest belonging to account_challenge; Authentication challenge creation/consumption. | Restricted credential/security material (digests/ciphertext remain sensitive) |
| created_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Recorded created instant for account_challenge; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| expires_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded expires instant for account_challenge; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| consumed_at | timestamptz | NULL; default none | Non-key attribute | Recorded consumed instant for account_challenge; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| invalidated_at | timestamptz | NULL; default none | Non-key attribute | Recorded invalidated instant for account_challenge; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(challenge_id)`.
- UNIQUE `(secret_digest)`.
- INDEX `(identity_id, purpose)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `challenge_id`, `identity_id`, `purpose`, `login_email`, `credential_revision`, `secret_digest`, `created_at`, `expires_at`.

## oidc_request

Short-lived browser-bound OIDC login/link transaction.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| request_id | uuid | NOT NULL; default none | PK(request_id) | Stable identifier within oidc_request ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| purpose | varchar(8) | NOT NULL; default none | Non-key attribute | Purpose belonging to oidc_request; Authentication OIDC initiation/callback. | Operational/configuration metadata; restricted if linked to a person |
| issuer | varchar(512) | NOT NULL; default none | Non-key attribute | Issuer belonging to oidc_request; Authentication OIDC initiation/callback. | Operational/configuration metadata; restricted if linked to a person |
| state_digest | varchar(64) | NOT NULL; default none | UNIQUE(state_digest) | Digest of one-use callback state. | Operational/configuration metadata; restricted if linked to a person |
| browser_digest | varchar(64) | NOT NULL; default none | Non-key attribute | Digest binding initiating browser. | Operational/configuration metadata; restricted if linked to a person |
| nonce_digest | varchar(64) | NOT NULL; default none | Non-key attribute | Digest of nonce checked against provider ID token. | Restricted credential/security material (digests/ciphertext remain sensitive) |
| pkce_verifier_ciphertext | text | NOT NULL; default none | Non-key attribute | Encrypted verifier needed at code exchange, not a reusable provider access token. | Restricted credential/security material (digests/ciphertext remain sensitive) |
| redirect_uri | varchar(1024) | NOT NULL; default none | Non-key attribute | Exact configured callback URI, not model/client-chosen redirect. | Operational/configuration metadata; restricted if linked to a person |
| link_identity_id | uuid | NULL; default none | local FK (link_session_id,link_identity_id) → auth_session(session_id,identity_id) | Stable identifier within oidc_request ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| link_session_id | uuid | NULL; default none | local FK (link_session_id,link_identity_id) → auth_session(session_id,identity_id) | Stable identifier within oidc_request ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| created_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Recorded created instant for oidc_request; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| expires_at | timestamptz | NOT NULL; default none | Non-key attribute | Recorded expires instant for oidc_request; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |
| consumed_at | timestamptz | NULL; default none | Non-key attribute | Recorded consumed instant for oidc_request; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(request_id)`.
- UNIQUE `(state_digest)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `request_id`, `purpose`, `issuer`, `state_digest`, `browser_digest`, `nonce_digest`, `pkce_verifier_ciphertext`, `redirect_uri`, `link_identity_id`, `link_session_id`, `created_at`, `expires_at`.

## security_event

Minimal append-only authentication security outcome audit.

| Column | PostgreSQL type | Null / default | Key / relationship | Meaning and source | Classification |
|---|---|---|---|---|---|
| event_id | uuid | NOT NULL; default none | PK(event_id) | Stable identifier within security_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Scoped identifier; linkability/access control required |
| identity_id | uuid | NULL; default none | local FK (identity_id) → identity(identity_id); local FK (session_id,identity_id) → auth_session(session_id,identity_id) | Stable identifier within security_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| session_id | uuid | NULL; default none | local FK (session_id,identity_id) → auth_session(session_id,identity_id) | Stable identifier within security_event ownership/relationship; source is the local aggregate unless explicitly marked external. | Pseudonymous personal/security identifier |
| event_type | varchar(48) | NOT NULL; default none | Non-key attribute | Event type belonging to security_event; Authentication security handlers, not arbitrary provider dumps. | Operational/configuration metadata; restricted if linked to a person |
| outcome_code | varchar(48) | NOT NULL; default none | Non-key attribute | Bounded non-secret outcome code, never raw exception/provider response. | Operational/configuration metadata; restricted if linked to a person |
| correlation_id | uuid | NOT NULL; default none | Non-key attribute | Technical request/incident correlation, not an idempotent business command or authorization. | Scoped identifier; linkability/access control required |
| occurred_at | timestamptz | NOT NULL; default clock_timestamp() | Non-key attribute | Recorded occurred instant for security_event; timestamptz/UTC wire format, server/source authority per lifecycle. | Operational/configuration metadata; restricted if linked to a person |

**Keys and index declarations** (PK/UNIQUE indexes are implicit; do not add duplicate indexes):

- PK `(event_id)`.
- INDEX `(identity_id, occurred_at)`.

**Row CHECKs:**

- No additional DBML row CHECK; enum/key/nullability and companion rules still apply.

**Lifecycle / immutable / audit:** See the current context contract and local SQL companion; service-only rules are not falsely certified by row CHECKs.

Immutable design attributes: `event_id`, `identity_id`, `session_id`, `event_type`, `outcome_code`, `correlation_id`, `occurred_at`.

## Enum vocabulary

Native enums absent; status vocabularies are in exact CHECKs and current context contract.

Supplemental partial indexes, exclusion/trigger/function rules and deployed CHECK definitions are recorded in [logical schema](logical-schema.md) and verification. External IDs are owner API references, not permission grants.
