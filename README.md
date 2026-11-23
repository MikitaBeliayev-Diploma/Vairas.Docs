# Vairas.Docs

Developer and diploma documentation for Vairas, a driving-school training platform with an MCP-based AI assistant.

Repository: [MikitaBeliayev-Diploma/Vairas.Docs](https://github.com/MikitaBeliayev-Diploma/Vairas.Docs).

This repository contains documentation, machine-readable contracts, database schemas, DDL/migrations, access-role definitions and synthetic seed data. Application code, executable tests, validation utilities and dependency caches belong outside this repository.

## Expert reviews

| Area | Expert | Materials and review arrangements |
|---|---|---|
| Database | Aleksei Khariukov, aleksei.khariukov@esdc.lt | [Database requirements and materials](Database/README.md). The expert will send the table of available slots. |
| Microservices | Pavlo Andriiash, pavlo.andriiash@esdc.lt | [Architecture requirements and materials](<Microservices architecture/README.md>). [Book a review](https://bookings.cloud.microsoft/book/Microservices@esdc.lt/). |

- [Contract review and backend integration guide](Communication/guides/getting-started.md)
- [API reference](Communication/reference/README.md), [OpenAPI/AsyncAPI/MCP contracts](Communication/README.md)
- [Architecture and diagrams](<Microservices architecture/README.md>)
- [Database documentation](Database/README.md)
- [Business Analysis](<Business Analysis/BA_Belyaev_Mikita.docx>)
- [Architecture alignment report](Communication/audit/architecture-alignment.md) and [Documentation coverage](Communication/audit/requirements-matrix.md)

This repository contains documentation. The existing User Management solution is in the separate sibling `Backend/Vairas.UserManagement` checkout. To run it, use .NET SDK 10 and PostgreSQL, apply its documented migrations/grants and configure credentials and Auth/School/Chat providers outside Git. From that solution directory run:

```powershell
dotnet restore Vairas.UserManagement.slnx
dotnet build Vairas.UserManagement.slnx --no-restore
dotnet run --project Vairas.UserManagement --launch-profile http
```

The configured loopback development address is `http://localhost:5151`; raw API documentation is at `/openapi/v1.json` in Development. Follow [Getting Started](Communication/guides/getting-started.md) for the required database/provider setup and contract validation. Other service providers and MCP interfaces are proposed designs; their specifications do not establish running implementations.

Store secrets in environment variables, user-secrets or an external secret store. Never commit passwords, private keys, bearer/refresh tokens or connection credentials.
