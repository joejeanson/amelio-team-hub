---
trigger: glob
globs: ["**/*.cs", "**/*.csproj", "**/*.sln"]
description: Backend C# and .NET coding standards, naming conventions, and best practices.
---

# ⚙️ Backend Standards (.NET/C#)

> **Scope**: All C# code in Amelio repositories.

## 1. Naming Conventions
- **Classes/Methods/Properties**: `PascalCase` (e.g., `UserService`, `GetUserById`).
- **Local Variables/Parameters**: `camelCase` (e.g., `userId`, `isValid`).
- **Interfaces**: `I` prefix + `PascalCase` (e.g., `IUserService`).
- **Constants**: `PascalCase` (standard C#) or `UPPER_SNAKE_CASE` (internal team preference if established - verify existing). *Default to PascalCase for consts in C# standards unless specified otherwise.*
- **Async Methods**: End with `Async` (e.g., `GetDataAsync`).

## 2. Code Structure & Syntax
- **LINQ**:
  - Prefer `SelectMany` to flatten nested iterations.
  - Use `GroupBy` and `ToDictionary` for aggregation.
  - Avoid nested `foreach` loops when LINQ can express it clearly.
- **Modern C# Features**:
  - Use target-typed `new()` when the type is obvious.
  - Use collection initializers: `new List<T> { ... }`.
  - Use tuple deconstruction for multiple return values.
- **Variables**:
  - Use explicit types (`int`, `string`, `CustomType`) for declarations.
  - Avoid `var` unless the type is obvious from the right-hand side (e.g., `var stream = new MemoryStream()`).

## 3. API & Services
- **Service Reuse**: Always check for existing services/repositories before creating new ones.
- **Response Format**: Follow `response.data.methodResults` structure for standard API responses.
- **Typing**: Ensure strong typing for all API responses.
- **Empty Collections**: Always return `Enumerable.Empty<T>()` or `new List<T>()` instead of `null` for collections.
- **Cancellation Tokens**:
  - All async API endpoints should accept a `CancellationToken`.
  - Pass it down to all async calls (EF Core, HTTP calls).
  - Use `TOKENS.REQUEST_NAME` pattern where applicable in frontend-initiated requests.

## 4. Multilingual Labels
- **Structure**: Backend stores multilingual data as a list of objects with `Language` and `Description`.
- **Handling**: Use existing helper extensions to retrieve the correct language.
- **Fallback**: Always default to English (`en`) if the requested language is missing.

## 5. Defensive Coding
- **Null Checks**: Do not add them blindly. Trace the call chain.
- **Fallbacks**: Check if `FirstOrDefault`, `?.`, or `??` are already used.
- **Exceptions**: Use `try-catch` only when you can handle the error or need to wrap it. Let global handlers catch unhandled exceptions.
