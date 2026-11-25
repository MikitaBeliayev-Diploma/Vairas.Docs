# User flows Vairas

## Навигация

```mermaid
flowchart TD
    Login[Sign in with school account] --> Overview[Overview]
    Overview --> Schedule[Schedule]
    Overview --> Assistant[AI Assistance]
    Overview --> Profile[Profile]
    Overview -->|Administrator| Planning[Schedule planning]
    Overview -->|Administrator or Instructor| Learners[Learners]
    Overview -->|Student| Training[My training]
    Learners --> Training
    Training --> Record[Practical record review]
    Training -->|Authorized staff| Readiness[Prerequisites and assessor decision]
    Overview -->|Administrator| Documents[Documents]
    Assistant --> Preview[Exact action preview]
    Preview --> Approval[Human confirmation]
    Approval --> Schedule
    Overview --> Switch[Switch authorized school]
    Switch --> Overview
```

Главная навигация сохраняется на всех рабочих экранах. На mobile sidebar открывается отдельной кнопкой и закрывается после выбора страницы. Student видит свои enrollments; Instructor — доступные назначения; Administrator — текущую школу. Запрещённый route открывает Forbidden, неизвестный — Not Found.

## Сценарий 1: подготовить и подтвердить расписание

Цель Administrator — проверить состав proposal до резервирования ресурсов.

```mermaid
flowchart TD
    Inputs[Select enrollment, instructor, vehicle and time window] --> Draft[Save editable Draft Input Set]
    Draft --> Missing{Missing inputs?}
    Missing -->|yes| Inputs
    Missing -->|no| Submit[Submit immutable request revision]
    Submit --> Generate[Generate unconfirmed proposal]
    Generate --> Feasible{Feasible?}
    Feasible -->|no| Issues[Review safe infeasibility reasons]
    Issues --> Inputs
    Feasible -->|yes| Review[Review exact times and resources]
    Review --> Confirm[Explicit confirmation]
    Confirm --> Result{Commit outcome}
    Result -->|Committed| Schedule[View reserved lessons]
    Result -->|Conflict or stale| Recheck[Reload and prepare a new proposal]
    Result -->|Pending or unknown| Reconcile[Query the same operation identity]
    Reconcile --> Result
```

Сохранение draft позволяет вернуться к неполным данным. Submission фиксирует версию. Proposal не является booking. При conflict не показываются чужая школа или чужой календарь. При неопределённом commit новая операция блокируется до выяснения результата.

## Сценарий 2: подтвердить факты и пересчитать прогресс

Цель Instructor и Student — согласовать одну и ту же версию фактов обучения.

```mermaid
flowchart TD
    Lesson[Instructor records verified actual lesson completion] --> Facts[Create practical facts from current source snapshot]
    Facts --> Instructor[Instructor confirms current fact version]
    Instructor --> Student[Student reviews the exact facts]
    Student --> Choice{Response}
    Choice -->|Confirm same version| Credit[Authoritative progress includes teaching minutes]
    Choice -->|Dispute with reason| NoCredit[Disputed version gives no credit]
    NoCredit --> Correction[Instructor appends corrected facts]
    Credit -->|Correction needed| Correction
    Correction --> Fresh[Old confirmations no longer count]
    Fresh --> Instructor
    Credit --> Evaluate[Staff evaluates readiness prerequisites]
    Evaluate --> Ready{Prerequisites satisfied?}
    Ready -->|no| Block[Approval blocked; show outstanding requirements]
    Ready -->|yes| Decision[Authorized assessor records a decision]
```

Completed lesson, credited practical minutes и readiness — разные состояния. Teaching minutes не выводятся автоматически из planned interval. Instructor вводит факты; Student может оспорить их с причиной. При correction сохраняется история и нужна новая пара подтверждений.

## Сценарий 3: действие через AI Assistance

Цель Administrator — использовать разговорный запрос, сохраняя контроль над записью.

```mermaid
flowchart TD
    Message[Ask to book or reschedule] --> Scope[Verify current identity, role and school]
    Scope --> Preview[Prepare exact non-committing preview]
    Preview --> Review[Review school, learner, instructor, vehicle and interval]
    Review --> Choice{Human choice}
    Choice -->|Cancel| Stop[No mutation]
    Choice -->|Approve| Approval[Record exact authenticated approval]
    Approval --> Revalidate[Revalidate preview, expiry and availability]
    Revalidate --> Result{Outcome}
    Result -->|Committed| Success[Show committed result]
    Result -->|Expired or conflict| NewPreview[Request a fresh preview]
    Result -->|Unknown| Query[Reconcile the same operation]
```

The assistant uses the configured local Chat Backend. It never treats model text as authorization; writes require an exact backend preview and explicit approval. The local model test double is configured behind Chat Backend, outside the frontend runtime.
