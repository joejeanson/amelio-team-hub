# Configuration Files

Pre-configured templates for local development. The onboarding workflow deploys these automatically.

## Contents

| Directory | Files | Target |
|-----------|-------|--------|
| `performance-backend/` | `appsettings.Development.json`, `appsettings.Testing.json` | `amelio-performance-backend/PerformanceManagement.WebApi/` |
| `performance-fe/` | `.env.template` | `amelio-performance-fe/.env` |
| `legacy-fe/` | `.env.development.template`, `.env.local.template` | `Amelio - React/` |
| `nuget/` | `NuGet.Config.template` | `~/.nuget/NuGet/NuGet.Config` (macOS only) |

## Notes

- Templates with `<REPLACE_WITH_...>` placeholders are filled in by the onboarding workflow
- The NuGet config is only needed on macOS (Windows uses `$(UserProfile)` natively)
- Performance FE `.env` should be synced with `.env.sample` from the repo if feature flags change
