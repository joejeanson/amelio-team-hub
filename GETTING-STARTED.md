# Amelio — Getting Started

> Everything you need to set up your Amelio development environment from scratch.

## Prerequisites

- [**Windsurf IDE**](https://windsurf.com) installed
- **Git** installed (`git --version` to verify)
- **Azure DevOps PAT** — ask your lead for the scopes needed (Code Read/Write, Packaging Read)

## 1. Clone the Team Hub

```bash
git clone https://github.com/joejeanson/amelio-team-hub.git
```

> This repo can also serve as your **parent directory** for the entire Amelio workspace — the onboarding will ask you to choose.

## 2. Open the Workspace

Open the file below in **Windsurf IDE**:

```
amelio-team-hub/windsurf/workspace/Template.code-workspace
```

> You can open it via `File > Open Workspace from File...` or drag it onto the IDE.

## 3. Start the Onboarding

1. Open **Cascade** in Windsurf (chat panel on the right)
2. Type the slash command:
   ```
   /amelio-onboarding
   ```
3. Cascade reads the workflow and walks you through **13 interactive steps** (~30–45 min)

> **Note**: The workflow file is located at `windsurf/global_workflows/amelio-onboarding.md` inside the Team Hub repo. It is automatically discovered by Windsurf once the workspace is open.

During the onboarding, you will be asked to choose an **installation mode**:

- **Mode A (recommended)**: Use this repo as the parent — all repos cloned inside `amelio-team-hub/REPOs/`
- **Mode B**: Create a separate `~/Amelio_primary` folder — classic layout with repos in a dedicated directory

The onboarding handles everything automatically:
- System dependencies (Node.js, .NET, Docker, etc.)
- Cloning all 5 Amelio repositories from Azure DevOps
- Docker containers (MongoDB, PostgreSQL, Redis, Mailpit)
- Database setup and migrations
- Config files and environment variables
- IDE extensions and workspace configuration

## 4. After Onboarding

Once complete, the workflow is deployed to your global Windsurf config. You can re-invoke it anytime from any workspace with:

```
/amelio-onboarding
```

For more details, see the full [README](./README.md) inside the repo.

## Need Help?

If you run into issues, reach out to your lead or check the `TESTING-GUIDE.md` in the repo for troubleshooting steps.
