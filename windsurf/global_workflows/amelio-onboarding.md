---
description: Complete Amelio developer onboarding — installs dependencies, clones ADO repos, sets up Docker/databases, configures all projects, deploys Windsurf config from amelio-team-hub, generates workspace, and verifies setup. Use for new team members or new machines.
---

# Amelio Onboarding

## BEHAVIOR RULES (MANDATORY)
- **NEVER interrupt or stop mid-phase** — execute each step fully, diagnose errors inline
- **ALWAYS use multiple-choice questions** when user input is needed — never open-ended
- **Task is NEVER complete** until the user explicitly confirms — keep asking after final step
- **On error**: show the error, propose 2-3 fix options, let user choose, then continue
- **Chat in the language chosen by the user in Step 0a** (`CHAT_LANG`), all generated files/code/configs in **English**
- **Do NOT skip steps** — if a tool is already installed, confirm version and move on
- **VALIDATE BEFORE INSTALLING** — always check what is already present before installing anything

## CONTEXT
The user has cloned the `amelio-team-hub` repo from GitHub and opened `windsurf/workspace/Simple.code-workspace` in Windsurf.
The first folder visible in the sidebar is **"👥 — 🏠 Amelio Team Hub"** — this IS the team hub repo.
The user dragged this workflow file into the Cascade chat panel to start the onboarding.
All source files (skills, workflows, rules, extensions lists, workspace template, config files) are **inside this repo**.
**No external personal repositories are used** — only Azure DevOps ameliodev repos.

---

## Step 0 — Welcome & Interactive Setup

### 0a — Welcome message & language choice
Display a welcome message in **English** first, then immediately ask the user to choose their preferred chat language:

> 👋 Welcome to Amelio onboarding! I will configure your complete development environment.
> This includes: system tools, 5 repos, Docker, databases, IDE config, and project setup.

Ask with a multiple-choice question:
- **A**: 🇫🇷 Français — Continuer en français
- **B**: 🇬🇧 English — Continue in English
- **C**: 🌍 Other — I'll specify my preferred language

Store the user's choice as `CHAT_LANG`. From this point on, **all chat messages** must be in the chosen language.
Code, configs, comments, and generated files remain in **English** regardless of the chat language.

### 0b — Detect OS, user, and Team Hub location
// turbo
```bash
echo "OS=$(uname -s)" && echo "USER=$(whoami)" && echo "HOME=$HOME"
```

Detect `TEAM_DIR` automatically using this strategy (in order):
1. **From this workflow file's path**: this file lives at `TEAM_DIR/windsurf/global_workflows/amelio-onboarding.md` — resolve two levels up to get `TEAM_DIR`
2. **Search the current workspace**: look for the folder named `"👥 — 🏠 Amelio Team Hub"` in the Windsurf workspace roots
3. **Search common locations**: look for a directory named `amelio-team-hub` in `~/`, `~/Desktop/`, `~/Downloads/`, and the current working directory

The `TEAM_DIR` is the root of the `amelio-team-hub` repo (contains `README.md`, `setup.sh`, `windsurf/`, `config-files/`).
If detection fails, ask the user to confirm the path.

### 0c — Ask installation directory
Ask the user with a multiple-choice question:
- **A**: Use **this repo as parent** — repos will be cloned inside `amelio-team-hub/REPOs/Amelio_FullStack/` (recommended — single root, everything in one place)
- **B**: Create a separate `~/Amelio_primary` folder — repos cloned there, team-hub stays independent
- **C**: Install in a different folder (I will specify the path)

If C, ask the user to type the absolute path.

**Option A behavior (team-hub as parent)**:
- `AMELIO_DIR` = `TEAM_DIR` (the amelio-team-hub repo root)
- `REPOs/` and `DB_Freemium/` are already in `.gitignore` — they will NOT pollute the team-hub git history
- The workspace file will reference paths relative to the team-hub root
- Advantage: single `git clone` + onboarding = everything is set up, no scattered directories

**Option B/C behavior (separate directory)**:
- `AMELIO_DIR` = `${HOME_DIR}/Amelio_primary` (or user-specified path)
- Team-hub repo remains a standalone config bundle
- Classic layout with repos in a separate directory tree

Store variables:
- `OS_TYPE` = `Darwin` (macOS) or `Linux` or `Windows_NT`
- `USERNAME` = result of `whoami`
- `HOME_DIR` = `$HOME` (macOS/Linux) or `$env:USERPROFILE` (Windows)
- `INSTALL_MODE` = `team-hub-parent` (A) or `separate` (B/C)
- `AMELIO_DIR` = `TEAM_DIR` if mode A, else user's chosen path (default: `${HOME_DIR}/Amelio_primary`)
- `FS_DIR` = `${AMELIO_DIR}/REPOs/Amelio_FullStack`
- `TEAM_DIR` = auto-detected bundle path
- `CFG_DIR` = `${TEAM_DIR}/config-files`

### 0d — Collect Azure DevOps PAT
Ask the user:
> To clone the 5 Azure DevOps repositories, I need your **Personal Access Token (PAT)**.
> You can generate one here: https://dev.azure.com/ameliodev/_usersSettings/tokens
> Required scopes: **Code (Read & Write)**, **Packaging (Read)**
> Paste it below (it will not be stored):

### 0e — Confirm before proceeding
Present a summary and ask for confirmation:
> **Configuration summary:**
> - OS: [detected]
> - User: [detected]
> - Install mode: [team-hub-parent / separate]
> - Installation directory: [chosen path]
> - Azure DevOps PAT: [masked, e.g. "****abcd"]
>
> If mode is `team-hub-parent`, also display:
> - Team Hub repo: [TEAM_DIR]
> - Repos will be cloned inside: [TEAM_DIR]/REPOs/Amelio_FullStack/
> - `.gitignore` already excludes `REPOs/` and `DB_Freemium/`
>
> **Ready to start?**
- **A**: All good, let's go!
- **B**: I want to change something

---

## Step 1 — System Dependencies (Validate First, Install Missing Only)

### 1a — Check existing installations
// turbo
```bash
echo "=== Checking installed tools ===" && \
echo "node: $(node -v 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "npm: $(npm -v 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "yarn: $(yarn -v 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "git: $(git --version 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "dotnet: $(dotnet --version 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "docker: $(docker --version 2>/dev/null || echo 'NOT INSTALLED')" && \
echo "gh: $(gh --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')" && \
echo "mongosh: $(mongosh --version 2>/dev/null || echo 'NOT INSTALLED')"
```

Present a table of what is installed vs missing. **Only install what is missing.**

### 1b — Install missing tools (macOS)
If `OS_TYPE` = `Darwin`:
```bash
which brew &>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Then install ONLY missing tools from this list:
```bash
brew install node yarn git git-lfs gh dotnet@8 azure-cli
brew tap mongodb/brew && brew install mongodb-community mongosh
brew install --cask mongodb-compass docker
```

### 1c — Install missing tools (Windows)
If `OS_TYPE` = `Windows_NT`:
Use `winget` (built-in Windows 11) to install ONLY missing tools:
```powershell
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Yarn.Yarn -e
winget install --id Git.Git -e
winget install --id GitHub.cli -e
winget install --id Microsoft.DotNet.SDK.8 -e
winget install --id Microsoft.AzureCLI -e
winget install --id MongoDB.Server -e
winget install --id MongoDB.Shell -e
winget install --id MongoDB.Compass.Full -e
winget install --id Docker.DockerDesktop -e
```

### 1d — Docker Desktop
After install, tell user: **Open Docker Desktop and wait for it to fully start** before continuing.
Wait for confirmation, then verify:
// turbo
```bash
docker info --format '{{.ServerVersion}}' 2>&1
```

### 1e — Verify all
// turbo
```bash
echo "=== Final verification ===" && node -v && npm -v && yarn -v && dotnet --version && docker --version && gh --version && mongosh --version
```

---

## Step 2 — Create Directory Structure

Both modes create the same subdirectory structure — the only difference is where `AMELIO_DIR` points.

**If `INSTALL_MODE` = `team-hub-parent`**: `AMELIO_DIR` = `TEAM_DIR` (the amelio-team-hub repo root).
The `REPOs/` and `DB_Freemium/` directories will be created **inside** the team-hub repo, but they are excluded from git via `.gitignore`.

**If `INSTALL_MODE` = `separate`**: `AMELIO_DIR` = `~/Amelio_primary` (or custom path).

```bash
mkdir -p "${AMELIO_DIR}/REPOs/Amelio_FullStack"
mkdir -p "${AMELIO_DIR}/REPOs/Documentations"
mkdir -p "${AMELIO_DIR}/REPOs/WorkSpace"
mkdir -p "${AMELIO_DIR}/DB_Freemium"
```

On Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "${AMELIO_DIR}\REPOs\Amelio_FullStack"
New-Item -ItemType Directory -Force -Path "${AMELIO_DIR}\REPOs\Documentations"
New-Item -ItemType Directory -Force -Path "${AMELIO_DIR}\REPOs\WorkSpace"
New-Item -ItemType Directory -Force -Path "${AMELIO_DIR}\DB_Freemium"
```

---

## Step 3 — Clone Azure DevOps Repositories (5 repos ONLY)

```bash
ADO="https://${ADO_PAT}@dev.azure.com/ameliodev"
```

Clone each repo into `${FS_DIR}`:
```bash
git clone "${ADO}/Amelio%20-%20First%20Product/_git/Amelio%20-%20Back-End" "${FS_DIR}/Amelio - Back-End"
git clone "${ADO}/Amelio%20-%20First%20Product/_git/Amelio%20-%20React" "${FS_DIR}/Amelio - React"
git clone "${ADO}/Amelio-Performance%20Management/_git/amelio-performance-backend" "${FS_DIR}/amelio-performance-backend"
git clone "${ADO}/Amelio-Performance%20Management/_git/amelio-performance-fe" "${FS_DIR}/amelio-performance-fe"
git clone "${ADO}/Amelio-Development%20Packages/_git/amelio-ui-library" "${FS_DIR}/amelio-ui-library"
```

### Verify clones
// turbo
```bash
ls -1 "${FS_DIR}"
```

---

## Step 4 — Deploy Windsurf Configuration (from amelio-team-hub)

All source files come from `${TEAM_DIR}` — the amelio-team-hub repo the user cloned.

### 4a — Deploy rules
```bash
mkdir -p "${HOME_DIR}/.codeium/.windsurf/rules"
cp "${TEAM_DIR}/windsurf/rules/"*.md "${HOME_DIR}/.codeium/.windsurf/rules/"
```

### 4b — Deploy global rules (memories)
```bash
mkdir -p "${HOME_DIR}/.codeium/windsurf/memories"
cp "${TEAM_DIR}/windsurf/memories/global_rules.md" "${HOME_DIR}/.codeium/windsurf/memories/"
```

### 4c — Deploy shared skills
```bash
for skill_dir in "${TEAM_DIR}/windsurf/skills/"*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "${HOME_DIR}/.codeium/windsurf/skills/${skill_name}"
  cp -R "${skill_dir}"* "${HOME_DIR}/.codeium/windsurf/skills/${skill_name}/"
done
```

### 4d — Deploy global workflows
```bash
mkdir -p "${HOME_DIR}/.codeium/windsurf/global_workflows"
cp "${TEAM_DIR}/windsurf/global_workflows/"*.md "${HOME_DIR}/.codeium/windsurf/global_workflows/"
```

### 4e — Deploy PR workflows to repos
```bash
for repo in amelio-performance-fe amelio-ui-library; do
  mkdir -p "${FS_DIR}/${repo}/.windsurf/workflows"
  cp "${TEAM_DIR}/windsurf/global_workflows/create-perfo-fe-pr.md" "${FS_DIR}/${repo}/.windsurf/workflows/"
done
mkdir -p "${FS_DIR}/amelio-performance-backend/.windsurf/workflows"
cp "${TEAM_DIR}/windsurf/global_workflows/create-perfo-be-pr.md" "${FS_DIR}/amelio-performance-backend/.windsurf/workflows/"
```

### 4f — Verify deployment
// turbo
```bash
echo "=== Rules ===" && ls "${HOME_DIR}/.codeium/.windsurf/rules/"
echo "=== Global Rules ===" && ls "${HOME_DIR}/.codeium/windsurf/memories/global_rules.md"
echo "=== Skills ===" && ls "${HOME_DIR}/.codeium/windsurf/skills/"
echo "=== Global Workflows ===" && ls "${HOME_DIR}/.codeium/windsurf/global_workflows/"
echo "=== Repo Workflows ===" && ls "${FS_DIR}/amelio-performance-fe/.windsurf/workflows/" && ls "${FS_DIR}/amelio-performance-backend/.windsurf/workflows/"
```

---

## Step 5 — Docker Containers Setup

Ensure Docker Desktop is running before this step.

### 5a — Start MongoDB container (for Legacy Backend)
```bash
docker run -d --name amelio_mongodb \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=ameliodb \
  -e MONGO_INITDB_ROOT_PASSWORD=ameliodb \
  --restart unless-stopped \
  mongo --auth
```

If container already exists, start it:
```bash
docker start amelio_mongodb 2>/dev/null || true
```

### 5b — Start Performance Backend containers (PostgreSQL, Redis, Mailpit)
```bash
cd "${FS_DIR}/amelio-performance-backend" && npm run start-docker
```

This starts:
- **dev_db** (PostgreSQL) on port 5432
- **test_db** (PostgreSQL) on port 5433
- **dev_cache** (Redis) on port 6379
- **mailpit** on ports 8025 (UI) and 1025 (SMTP)

### 5c — Verify all containers
// turbo
```bash
echo "=== Docker containers ===" && docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected: 5 containers running (amelio_mongodb, dev_db, test_db, dev_cache, mailpit).

---

## Step 6 — Database Setup

### 6a — Import MongoDB Freemium database
Ask the user:
> The Legacy Backend needs the Freemium MongoDB database.
> Do you have the `DB_Freemium/Freemium/` dump folder?
- **A**: Yes, I have it (I will provide the path)
- **B**: No, I will get it later — skip for now

If A:
```bash
mongorestore --host localhost:27017 \
  --username ameliodb --password ameliodb \
  --authenticationDatabase admin \
  --db Freemium \
  "<PATH_TO_DB_FREEMIUM>/Freemium/"
```

Verify:
```bash
mongosh "mongodb://ameliodb:ameliodb@localhost:27017/Freemium?authSource=admin" --eval "db.getCollectionNames().length + ' collections imported'"
```

### 6b — Run PostgreSQL migrations (Performance Backend)
```bash
cd "${FS_DIR}/amelio-performance-backend" && npm run update-database
```

If migration fails, offer:
- **A**: Drop and recreate: `npm run drop-database && npm run update-database`
- **B**: Skip for now

---

## Step 7 — Project Configuration Files (from bundle)

Configuration templates are in `${CFG_DIR}` (= `${TEAM_DIR}/config-files/`).

### 7a — Performance Backend config
```bash
cp "${CFG_DIR}/performance-backend/appsettings.Development.json" "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/"
cp "${CFG_DIR}/performance-backend/appsettings.Testing.json" "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/"
```

### 7b — Legacy Backend config (MongoDB connection strings)
Modify **3 files** to use local Docker MongoDB:

**File 1**: `${FS_DIR}/Amelio - Back-End/IdentityServer/appsettings.json`
- Find `"MongoConnection"` and replace the IP (e.g. `192.168.0.172`) with:
  `mongodb://ameliodb:ameliodb@localhost:27017/Freemium?authSource=admin`

**File 2**: `${FS_DIR}/Amelio - Back-End/OPIA.API.V2/appsettings.Development.json`
- Find ALL `MongoDbSettings` connection strings and replace IPs with `localhost`
- Ensure all use `?authSource=admin`
- Example:
```json
"Connection": "mongodb://ameliodb:ameliodb@localhost:27017/Freemium?authSource=admin"
```

**File 3** (optional): `${FS_DIR}/Amelio - Back-End/OPIA.Scheduler.V2/appsettings.json`
- Same MongoDB connection string update

After modifying, protect local changes from git:
```bash
cd "${FS_DIR}/Amelio - Back-End"
git update-index --skip-worktree IdentityServer/appsettings.json
git update-index --skip-worktree OPIA.API.V2/appsettings.Development.json
git update-index --skip-worktree OPIA.Scheduler.V2/appsettings.json
```

### 7c — NuGet setup (macOS ONLY)
On macOS, the `NuGet.config` uses `$(UserProfile)` which is a Windows variable. Must override locally.

**Step 1**: Modify `NuGet.config` in the Legacy Backend repo:
```bash
cd "${FS_DIR}/Amelio - Back-End"
```
Edit the `<config>` section in `NuGet.config` to:
```xml
<config>
  <add key="globalPackagesFolder" value="${HOME_DIR}/.nuget/packages" />
  <add key="repositoryPath" value="${HOME_DIR}/.nuget/packages" />
  <add key="maxHttpRequestsPerSource" value="16" />
</config>
```
(Replace `${HOME_DIR}` with the actual absolute path, e.g. `/Users/testdev`)

**Step 2**: Protect from git:
```bash
git update-index --skip-worktree NuGet.config
```

**Step 3**: Create user-level NuGet config:
```bash
mkdir -p "${HOME_DIR}/.nuget/NuGet"
```
Read the template from `${CFG_DIR}/nuget/NuGet.Config.template`, replace:
- `<HOME_DIR>` with the actual home directory path
- `<REPLACE_WITH_NUGET_PAT>` with the ADO PAT from Step 0d

Save to: `${HOME_DIR}/.nuget/NuGet/NuGet.Config`

### 7d — Legacy Frontend config
```bash
cp "${CFG_DIR}/legacy-fe/.env.development.template" "${FS_DIR}/Amelio - React/.env.development"
cp "${CFG_DIR}/legacy-fe/.env.local.template" "${FS_DIR}/Amelio - React/.env.local"
```

Protect from git:
```bash
cd "${FS_DIR}/Amelio - React"
git update-index --skip-worktree .env.development
```

### 7e — Performance Frontend config
If `.env.sample` exists in the repo, copy it:
```bash
cd "${FS_DIR}/amelio-performance-fe"
if [ -f .env.sample ]; then
  cp .env.sample .env
else
  cp "${CFG_DIR}/performance-fe/.env.template" .env
fi
```

Tell user:
> The `VITE_DEV_TOKEN` in `.env` needs a JWT token from the Legacy Frontend.
> You can get it later by logging into http://localhost:3011, opening DevTools > Network,
> and copying the Bearer token from any API request header.

---

## Step 8 — Install Dependencies & Build Projects

### 8a — Azure DevOps npm authentication (for @amelio packages)
```bash
cd "${FS_DIR}/amelio-ui-library"
npx vsts-npm-auth -config .npmrc
```
If this fails (e.g. on macOS), manually create/verify `.npmrc`:
```bash
cat .npmrc
```
Ensure it contains:
```
registry=https://registry.npmjs.org/
@amelio:registry=https://pkgs.dev.azure.com/ameliodev/_packaging/amelio-performance-feed/npm/registry/
always-auth=true
```

### 8b — UI Library (install + build — REQUIRED before Performance FE)
```bash
cd "${FS_DIR}/amelio-ui-library" && yarn install && yarn build
```
The `yarn build` creates the `dist/` folder that Performance FE depends on.

### 8c — Performance Frontend
```bash
cd "${FS_DIR}/amelio-performance-fe"
npx vsts-npm-auth -config .npmrc 2>/dev/null || true
yarn install
```

### 8d — Performance Backend
```bash
cd "${FS_DIR}/amelio-performance-backend" && dotnet restore
```

### 8e — Legacy Frontend (uses npm, NOT yarn)
```bash
cd "${FS_DIR}/Amelio - React" && npm install --legacy-peer-deps
```
**IMPORTANT**: This project uses `npm` with `--legacy-peer-deps` due to React 18 peer dependency conflicts. Do NOT use `yarn`.

### 8f — Legacy Backend
```bash
cd "${FS_DIR}/Amelio - Back-End" && dotnet restore
```

Verify NuGet restore succeeded (macOS):
```bash
find . -name "*.nupkg" | wc -l
```
Expected: `0`. If packages appear in the repo, the NuGet config from Step 7c needs fixing.

### 8g — Verify all installs
// turbo
```bash
echo "=== UI Library dist ===" && ls "${FS_DIR}/amelio-ui-library/dist/" 2>&1 | head -5
echo "=== Perf FE node_modules ===" && ls "${FS_DIR}/amelio-performance-fe/node_modules/" 2>&1 | head -3
echo "=== Legacy FE node_modules ===" && ls "${FS_DIR}/Amelio - React/node_modules/" 2>&1 | head -3
echo "=== Perf BE restore ===" && ls "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/bin/" 2>&1 | head -3
echo "=== Legacy BE restore ===" && ls "${FS_DIR}/Amelio - Back-End/OPIA.API.V2/bin/" 2>&1 | head -3
```

---

## Step 9 — Extensions Installation

Ask the user with a multiple-choice question:
- **A**: Essential only (23 — ESLint, GitLens, C#, Tailwind, Docker, Vitest, MongoDB...)
- **B**: Essential + Visual (27 — adds Material Icons, Folder Color, Mermaid, Color Highlight)
- **C**: Essential + Visual + Extras (31 — adds PDF viewer, ADO Boards sidebar, LiveServer, Qodo AI tests)
- **D**: Skip extension installation

Extension files are in `${TEAM_DIR}/ide-settings/`:

For **A/B/C**, install essentials:
```bash
while IFS= read -r ext; do
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  windsurf --install-extension "$ext" --force 2>&1 || echo "FAILED: $ext"
done < "${TEAM_DIR}/ide-settings/extensions-team.txt"
```

For **B/C**, also install optional:
```bash
while IFS= read -r ext; do
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  windsurf --install-extension "$ext" --force 2>&1 || echo "FAILED: $ext"
done < "${TEAM_DIR}/ide-settings/extensions-optional.txt"
```

For **C**, also install extras (parse `ext-id | description`):
```bash
while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  ext_id=$(echo "$line" | cut -d'|' -f1 | xargs)
  windsurf --install-extension "$ext_id" --force 2>&1 || echo "FAILED: $ext_id"
done < "${TEAM_DIR}/ide-settings/extensions-extras.txt"
```

Report: X succeeded, Y failed. If any failed, propose manual install.

---

## Step 10 — Generate Personalized Workspace

Read the workspace template from `${TEAM_DIR}/windsurf/workspace/Simple.code-workspace`.

### If `INSTALL_MODE` = `team-hub-parent`
Modifications to apply:
1. **Keep** the first folder entry `"👥 — 🏠 Amelio Team Hub"` but change its `path` from `"../.."` to `"."` (the team-hub IS the root)
2. **Replace** ALL `<AMELIO_DIR>` with the actual `${AMELIO_DIR}` (= `${TEAM_DIR}`) path:
   - macOS: e.g. `/Users/${USERNAME}/amelio-team-hub` (wherever the repo was cloned)
   - Windows: use forward slashes for VS Code

### If `INSTALL_MODE` = `separate`
Modifications to apply:
1. **Remove** the first folder entry `"👥 — 🏠 Amelio Team Hub"` (path `"../.."`), as it is only needed for the initial onboarding
2. **Replace** ALL `<AMELIO_DIR>` with the actual `${AMELIO_DIR}` path chosen in Step 0:
   - macOS: `/Users/${USERNAME}/Amelio_primary` (or custom path)
   - Windows: `C:/Users/${USERNAME}/Amelio_primary` (use forward slashes for VS Code)

Save as `${AMELIO_DIR}/REPOs/WorkSpace/Simple_${USERNAME}.code-workspace`.

Tell user:
> Your personalized workspace is ready! To open it:
> **File > Open Workspace from File** and select `Simple_${USERNAME}.code-workspace`.

---

## Step 11 — Chrome Bookmarks & Useful Links

Suggest these bookmarks to the user:

| Name | URL |
|---|---|
| ADO Home | `https://dev.azure.com/ameliodev/` |
| Perf Boards | `https://dev.azure.com/ameliodev/Amelio-Performance%20Management/_boards` |
| Perf Repos | `https://dev.azure.com/ameliodev/Amelio-Performance%20Management/_git` |
| Perf Pipelines | `https://dev.azure.com/ameliodev/Amelio-Performance%20Management/_build` |
| Legacy Boards | `https://dev.azure.com/ameliodev/Amelio%20-%20First%20Product/_boards` |
| Legacy Repos | `https://dev.azure.com/ameliodev/Amelio%20-%20First%20Product/_git` |
| UI Lib | `https://dev.azure.com/ameliodev/Amelio-Development%20Packages/_git/amelio-ui-library` |
| Mailpit | `http://localhost:8025` |

### Local development URLs (after starting services):
| Service | URL |
|---|---|
| Performance Frontend | `http://localhost:5173` |
| Legacy Frontend | `http://localhost:3011` |
| Performance Backend | `http://localhost:5120` |
| Legacy Backend (API) | `http://localhost:18489` |
| IdentityServer | `http://localhost:5000` |
| Storybook (UI Library) | `http://localhost:6006` |
| Mailpit (Email UI) | `http://localhost:8025` |

### Optional tools to install later:
- **Bruno** — API client (like Postman): https://www.usebruno.com/downloads
- **DBeaver** — Database client (PostgreSQL, MongoDB): https://dbeaver.io/download/

---

## Step 12 — Optional: Secondary Workspace

Ask the user:
- **A**: "I want a second workspace to work on two tasks in parallel"
- **B**: "Skip — one workspace is enough for now"

If A, create a second directory and clone the same 5 ADO repos:
```bash
mkdir -p "${HOME_DIR}/Amelio_secondary/REPOs/Amelio_FullStack"
ADO="https://${ADO_PAT}@dev.azure.com/ameliodev"
FS2="${HOME_DIR}/Amelio_secondary/REPOs/Amelio_FullStack"
git clone "${ADO}/Amelio%20-%20First%20Product/_git/Amelio%20-%20Back-End" "${FS2}/Amelio - Back-End"
git clone "${ADO}/Amelio%20-%20First%20Product/_git/Amelio%20-%20React" "${FS2}/Amelio - React"
git clone "${ADO}/Amelio-Performance%20Management/_git/amelio-performance-backend" "${FS2}/amelio-performance-backend"
git clone "${ADO}/Amelio-Performance%20Management/_git/amelio-performance-fe" "${FS2}/amelio-performance-fe"
git clone "${ADO}/Amelio-Development%20Packages/_git/amelio-ui-library" "${FS2}/amelio-ui-library"
```

Generate a second workspace file using the same template but with `Amelio_secondary` paths.

---

## Step 13 — FINAL VALIDATION CHECKLIST

Run ALL checks below. For each, report pass or fail. If ANY fail, fix before continuing.

// turbo
```bash
echo "=== 1. Dependencies ===" && node -v && npm -v && yarn -v && dotnet --version && docker --version && gh --version && mongosh --version
echo "=== 2. ADO Repos ===" && ls -d "${FS_DIR}/Amelio - Back-End" "${FS_DIR}/Amelio - React" "${FS_DIR}/amelio-performance-backend" "${FS_DIR}/amelio-performance-fe" "${FS_DIR}/amelio-ui-library" 2>&1
echo "=== 3. Docker Containers ===" && docker ps --format "{{.Names}}" 2>&1
echo "=== 4. MongoDB ===" && mongosh "mongodb://ameliodb:ameliodb@localhost:27017/Freemium?authSource=admin" --quiet --eval "db.getCollectionNames().length + ' collections'" 2>&1
echo "=== 5. PostgreSQL ===" && docker exec dev_db psql -U dev_user -d dev_db -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public'" 2>&1
echo "=== 6. Rules ===" && ls "${HOME_DIR}/.codeium/.windsurf/rules/"
echo "=== 7. Global Rules ===" && ls "${HOME_DIR}/.codeium/windsurf/memories/global_rules.md"
echo "=== 8. Skills ===" && ls "${HOME_DIR}/.codeium/windsurf/skills/"
echo "=== 9. Workflows ===" && ls "${HOME_DIR}/.codeium/windsurf/global_workflows/" && ls "${FS_DIR}/amelio-performance-fe/.windsurf/workflows/" && ls "${FS_DIR}/amelio-performance-backend/.windsurf/workflows/"
echo "=== 10. Workspace ===" && ls "${AMELIO_DIR}/REPOs/WorkSpace/Simple_${USERNAME}.code-workspace" 2>&1
echo "=== 11. UI Library dist ===" && ls "${FS_DIR}/amelio-ui-library/dist/index.css" 2>&1
echo "=== 12. Config files ===" && ls "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/appsettings.Development.json" "${FS_DIR}/amelio-performance-fe/.env" "${FS_DIR}/Amelio - React/.env.development" 2>&1
```

Present summary table:

| # | Check | Status |
|---|---|---|
| 1 | Dependencies (node, npm, yarn, dotnet, docker, gh, mongosh) | ? |
| 2 | 5 ADO repos cloned | ? |
| 3 | Docker containers running (5: mongo, pg×2, redis, mailpit) | ? |
| 4 | MongoDB Freemium database imported | ? |
| 5 | PostgreSQL migrations applied | ? |
| 6 | Windsurf rules deployed | ? |
| 7 | Global rules (global_rules.md) | ? |
| 8 | Shared skills deployed | ? |
| 9 | Workflows deployed (global + repo-specific) | ? |
| 10 | Personalized workspace file | ? |
| 11 | UI Library built (dist/) | ? |
| 12 | Config files deployed (appsettings, .env) | ? |

If ALL pass, ask user:
- **A**: "Everything is perfect, onboarding is complete"
- **B**: "There are still things to fix"
- **C**: "I want to verify a specific point"

**CRITICAL: Task is NEVER done until the user explicitly says so. Always keep asking.**
