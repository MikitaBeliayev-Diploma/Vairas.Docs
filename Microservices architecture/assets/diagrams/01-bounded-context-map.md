# Bounded Context Map

Business responsibilities, ownership boundaries and logical integration between six business contexts and two supporting contexts.

## Diagram

```mermaid
flowchart TB
    subgraph BUSINESS["Vairas — business bounded contexts"]
        USER["User Management<br/>Profiles, contacts, user status"]
        SCHOOL["School Management<br/>Schools, memberships, enrollments, groups"]
        SCHED["Scheduling<br/>Lessons, proposals, conflicts, reservations"]
        VEH["Vehicle Management<br/>Vehicles, eligibility, maintenance"]
        LEARN["Learning Tracking<br/>Practical records, hours, assessments"]
        DOC["Document Management<br/>Contracts, templates, document output"]
    end
    subgraph SUPPORT["Supporting bounded contexts"]
        AUTH["Authentication<br/>Identity, credentials, sessions"]
        NOTIF["Notifications<br/>Email templates and delivery"]
    end
    AUTH -.->|IdentityId| USER
    SCHOOL -->|Profile IDs| USER
    SCHED -->|Enrollment and group validation| SCHOOL
    SCHED -->|Eligibility REST| VEH
    VEH -->|Saga booking-block REST| SCHED
    SCHED -.->|LessonCompleted event| LEARN
    LEARN -->|Enrollment ID validation| SCHOOL
    DOC -->|Enrollment data| SCHOOL
    DOC -->|Confirmed training facts| LEARN
    SCHED -.->|Lesson events| NOTIF
    LEARN -.->|Assessment events| NOTIF
    VEH -.->|Maintenance events| NOTIF
```

[Back to architecture overview](../../README.md)
