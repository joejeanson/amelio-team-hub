# Amelio Team - Windsurf Configuration Bundle

> Self-contained bundle for onboarding Amelio developers.
> Installs everything: tools, repos, Docker, databases, configs, IDE, and workspace.

## Quick Start

1. Place this folder anywhere on your machine
2. Open `windsurf/workspace/Simple.code-workspace` in **Windsurf IDE**
3. The Team bundle folder is visible in the sidebar ("👥 Team Bundle")
4. Drag the file `windsurf/global_workflows/amelio-onboarding.md` into the **Cascade chat panel**
5. Cascade will read the workflow and start the interactive onboarding
6. Follow the 13 guided steps (~30-45 minutes for a fresh machine)

> ℹ️ After onboarding, the workflow is deployed to your system — you can then invoke it with `/amelio-onboarding`.

For manual updates only:
```bash
./setup.sh --check     # Preview what would change
./setup.sh --install   # Apply changes
```

## What's Included

### Skills (2)

| Skill | Description |
|-------|-------------|
| `skill-creator` | Create and optimize Windsurf skills |
| `code-quality-audit` | 31 TypeScript criteria + 19 code smells audit |

### Workflows (3)

| Workflow | Description |
|----------|-------------|
| `amelio-onboarding.md` | Complete developer onboarding (13 steps: deps, repos, Docker, DBs, configs, IDE) |
| `create-perfo-fe-pr.md` | Create FE / UI Library PR on Azure DevOps |
| `create-perfo-be-pr.md` | Create Backend PR on Azure DevOps |

### Rules (5)

| Rule | Triggers on |
|------|------------|
| `backend-dotnet.md` | `.cs`, `.csproj`, `.sln` files |
| `frontend-react.md` | `.ts`, `.tsx` files |
| `frontend-styling.md` | `.css`, `.tsx`, `tailwind.config.js` |
| `general-devops.md` | Git, PR, Work Item operations |
| `testing.md` | Test files |

### Global Rules

| File | Description |
|------|-------------|
| `global_rules.md` | AI behavior rules, coding standards, communication guidelines |

### Config Files (pre-configured templates)

| Directory | Description |
|-----------|-------------|
| `config-files/performance-backend/` | `appsettings.Development.json`, `appsettings.Testing.json` |
| `config-files/performance-fe/` | `.env.template` for Performance Frontend |
| `config-files/legacy-fe/` | `.env.development.template`, `.env.local.template` for Legacy Frontend |
| `config-files/nuget/` | `NuGet.Config.template` for macOS NuGet setup |

### IDE Extensions

| File | Description |
|------|-------------|
| `extensions-team.txt` | 23 essential extensions (ESLint, GitLens, C#, Tailwind, Docker...) |
| `extensions-optional.txt` | 4 visual extras (Material Icons, Folder Color, Mermaid...) |
| `extensions-extras.txt` | 4 bonus tools (PDF viewer, ADO Boards, LiveServer, Qodo) |

### Workspace Template

| File | Description |
|------|-------------|
| `Simple.code-workspace` | Multi-root workspace with terminal profiles (macOS + Windows + Linux) |

## Bundle Structure

```
Team/
├── README.md
├── TESTING-GUIDE.md                      <- How to test the onboarding
├── setup.sh                              <- Manual installer (bash)
├── config-files/
│   ├── README.md
│   ├── performance-backend/
│   │   ├── appsettings.Development.json  <- Deployed to Perf BE WebApi/
│   │   └── appsettings.Testing.json
│   ├── performance-fe/
│   │   └── .env.template                 <- Deployed as .env
│   ├── legacy-fe/
│   │   ├── .env.development.template     <- Deployed to Amelio - React/
│   │   └── .env.local.template           <- MFE integration config
│   └── nuget/
│       └── NuGet.Config.template         <- macOS NuGet user-level config
├── ide-settings/
│   ├── extensions-team.txt
│   ├── extensions-optional.txt
│   └── extensions-extras.txt
└── windsurf/
    ├── skills/
    │   ├── skill-creator/                -> ~/.codeium/windsurf/skills/
    │   └── code-quality-audit/           -> ~/.codeium/windsurf/skills/
    ├── global_workflows/
    │   ├── amelio-onboarding.md          <- THE orchestrator workflow (13 steps)
    │   ├── create-perfo-fe-pr.md         -> repo .windsurf/workflows/
    │   └── create-perfo-be-pr.md         -> repo .windsurf/workflows/
    ├── rules/
    │   ├── backend-dotnet.md             -> ~/.codeium/.windsurf/rules/
    │   ├── frontend-react.md
    │   ├── frontend-styling.md
    │   ├── general-devops.md
    │   └── testing.md
    ├── memories/
    │   └── global_rules.md               -> ~/.codeium/windsurf/memories/
    └── workspace/
        └── Simple.code-workspace         <- Template (paths replaced at install)
```

## How the Onboarding Works (13 Steps)

| Step | Name | What it does |
|------|------|-------------|
| 0 | Welcome & Setup | Detects OS, asks for install path and ADO PAT |
| 1 | System Dependencies | Validates and installs node, yarn, npm, git, dotnet, docker, mongosh |
| 2 | Directory Structure | Creates `Amelio_primary/REPOs/Amelio_FullStack/` |
| 3 | Clone Repos | Clones 5 Azure DevOps repos |
| 4 | Deploy Windsurf Config | Rules, skills, global rules, workflows |
| 5 | Docker Containers | MongoDB + PostgreSQL + Redis + Mailpit |
| 6 | Database Setup | MongoDB Freemium import + PostgreSQL migrations |
| 7 | Config Files | appsettings, .env files, NuGet (Mac) |
| 8 | Install & Build | npm/yarn install, UI Library build, dotnet restore |
| 9 | Extensions | Installs IDE extensions (3 tiers) |
| 10 | Workspace | Generates personalized `Simple_<user>.code-workspace` |
| 11 | Bookmarks | Useful URLs for ADO, local services, tools |
| 12 | Secondary (optional) | Second workspace for parallel tasks |
| 13 | Validation | 12-point checklist to verify everything |

## Prerequisites

- **Windsurf IDE** installed
- **Azure DevOps PAT** (scopes: Code Read/Write, Packaging Read)
- **DB_Freemium dump** (optional — for Legacy Backend data)

## Important Notes

- **Re-running is safe** — only updates changed files
- **No personal repos** are cloned — only Azure DevOps ameliodev repos
- **Cross-platform** — onboarding supports macOS and Windows
- **Legacy Frontend uses npm** (not yarn) with `--legacy-peer-deps`
- **UI Library must be built** before Performance Frontend can work
