# MCP tool contracts — status

MCP tools are **not** OpenAPI/AsyncAPI operations. The uploaded AI diagrams specify a proposed **Vairas MCP Server**, accessed by a Microsoft Foundry agent. This architecture bundle includes REST APIs for the downstream business services and asynchronous integration event schemas; it **does not yet contain approved MCP tool definitions** (`tools/list` input/output JSON schemas).

Before implementing the agent, define and approve individual tools such as `find_available_lessons`, `get_student_progress` and `propose_lesson_booking` in the MCP server, with input validation and output schemas. For mutating tools, require explicit user approval, end-user authorization, tenant-bound validation, and backend enforcement; the LLM never directly accesses databases.

See the [AI assistant architecture](../../README.md#ai-assistant-and-mcp-integration), [MCP architecture diagram](../../assets/diagrams/10-ai-agent-mcp-architecture.md) and [tool-call sequence](../../assets/diagrams/11-ai-agent-tool-sequence.md).
