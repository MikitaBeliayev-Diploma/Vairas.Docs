# Business Analysis coverage

Source: Appendix A of the local BA document (25 user stories, 102 acceptance criteria). All mapped business providers below remain proposed; User Management is a supporting implemented dependency. Schemas describe intended interfaces, not executed acceptance results.

| Story | Required behavior | Owning contracts | Interface / limitation |
|---|---|---|
| US-001 | School enrollment | [school-management](../Api/school-management.openapi.yaml) | createEnrollment |
| US-002 | Group, programme and pinned enrollment training | [school-management](../Api/school-management.openapi.yaml), [learning-tracking](../Api/learning-tracking.openapi.yaml) | assignEnrollmentGroup; startStudentTraining |
| US-003 | Missing planning inputs | [school-management](../Api/school-management.openapi.yaml) | getPlanningInputs |
| US-004 | Editable school-scoped draft | [scheduling](../Api/scheduling.openapi.yaml) | createSchedulingDraft; reviseSchedulingDraft; getSchedulingRequest |
| US-005 | Unconfirmed proposal or safe infeasibility | [scheduling](../Api/scheduling.openapi.yaml) | generateScheduleProposal |
| US-006 | Exact proposal revalidation and atomic reservation | [scheduling](../Api/scheduling.openapi.yaml) | confirmScheduleProposal; getSchedulingOperation |
| US-007 | Soft preferences | [scheduling](../Api/scheduling.openapi.yaml) | DraftInputs.preferences; typed rule versions; owner catalogue gate |
| US-008 | Manual theory/practical lesson and global non-disclosing conflicts | [scheduling](../Api/scheduling.openapi.yaml) | createPracticalLesson; createTheoryLesson |
| US-009 | Reschedule/cancel with history | [scheduling](../Api/scheduling.openapi.yaml) | reschedulePracticalLesson; cancelPracticalLesson |
| US-010 | Additional lesson or repeated assessment | [scheduling](../Api/scheduling.openapi.yaml), [learning-tracking](../Api/learning-tracking.openapi.yaml) | createPracticalLesson; scheduleAssessmentAppointment; recordAssessmentResult |
| US-011 | Schedule-change notification | [notifications](../Api/notifications.openapi.yaml) | NotificationStatus; LessonScheduled/Rescheduled/Cancelled consumer |
| US-012 | Actual completion facts and assigned teacher confirmation | [scheduling](../Api/scheduling.openapi.yaml), [learning-tracking](../Api/learning-tracking.openapi.yaml) | getLessonTrainingSource; createPracticalRecord; revisePracticalRecord; recordTheoryAttendance; getTheoryRecord; reviseTheoryRecord; confirmTheoryRecord; practical confirmations (G-01) |
| US-013 | Student current-version confirm/dispute | [learning-tracking](../Api/learning-tracking.openapi.yaml) | getPracticalRecord; confirmations; disputePracticalRecord |
| US-014 | Confirmed credit and outstanding requirements | [learning-tracking](../Api/learning-tracking.openapi.yaml) | getStudentProgress |
| US-015 | Journal generation and review | [document-management](../Api/document-management.openapi.yaml) | generatePracticalJournal; getDocumentJob; getDocumentDownload |
| US-016 | Internal completion report | [learning-tracking](../Api/learning-tracking.openapi.yaml), [document-management](../Api/document-management.openapi.yaml) | getCompletionEvidence; generateCompletionReport; getDocumentJob |
| US-017 | Assigned instructor lessons and permitted enrollment | [scheduling](../Api/scheduling.openapi.yaml), [school-management](../Api/school-management.openapi.yaml) | getMyLessons; getEnrollment |
| US-018 | Authorized MCP schedules/progress/requirements | [MCP](../mcp/tools.json) | get_my_enrollments; get_my_lessons; get_student_training_progress; find_available_lessons |
| US-019 | Exactly confirmed MCP creation or rescheduling | [MCP](../mcp/tools.json), [chat](../Api/chat.openapi.yaml) | preview_lesson_booking; create_lesson_booking; preview_lesson_rescheduling; reschedule_lesson_booking; recordHumanApproval |
| US-020 | Restricted MCP write audit | [chat](../Api/chat.openapi.yaml) | getAssistantAudit |
| US-021 | Immutable submitted request revision | [scheduling](../Api/scheduling.openapi.yaml) | submitSchedulingRequest; immutable snapshot constraints |
| US-022 | Administrator enrollment progress | [learning-tracking](../Api/learning-tracking.openapi.yaml) | progress route with school/role authorization |
| US-023 | Assigned instructor enrollment progress | [learning-tracking](../Api/learning-tracking.openapi.yaml) | progress route with assignment authorization |
| US-024 | Formal prerequisite check and separate assessor decision | [learning-tracking](../Api/learning-tracking.openapi.yaml) | evaluateReadiness; decideReadiness; recordAssessmentResult |
| US-025 | School rules cannot weaken verified law | [scheduling](../Api/scheduling.openapi.yaml) | createSchoolRuleVersion; implemented catalogue and legal verification gate |

AC-075–082 require same-current-version confirmation, correction invalidation and credit derived once. AC-083/090–102 require trusted global learner identity, privacy-safe conflicts and uncertain-outcome reconciliation. AC-101 group activation needs cross-service coordination. These remain runtime/owner gates; see [acceptance scenarios](acceptance-scenarios.md).

Programme authoring, rule verification and retention/signature policy are not inferred as generic CRUD from database tables. Current providers require reviewed implementations and adopted policy before operating these workflows.
