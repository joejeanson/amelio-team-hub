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
- **Windows shell strategy**: After Step 1c installs Git (includes Git Bash), **use Git Bash for all subsequent commands**. Git Bash provides a full Unix environment (`bash`, `find`, `sed`, `cp`, `diff`, etc.) making all commands identical to macOS. PowerShell blocks in this workflow are **fallback only** — prefer bash via Git Bash. Step 1c itself uses PowerShell (`winget`) since Git Bash isn't installed yet.
- **🚫 NEVER modify any git-tracked file inside the 5 cloned ADO repositories.** This includes `.npmrc`, `appsettings.json`, `docker-compose.yml`, `package.json`, or ANY other file tracked by git. Always verify with `git status` before touching a file. For local overrides, use ONLY files already listed in `.gitignore` (e.g. `docker-compose.override.yml`, `appsettings.Local.json`, `appsettings.Development.json` if gitignored). Credentials and local config belong in **user-level files** (`~/.npmrc`, `~/.nuget/NuGet/NuGet.Config`) — never in repo files.

## CONTEXT
The user has cloned the `amelio-team-hub` repo from GitHub and opened `windsurf/workspace/Template.code-workspace` in Windsurf.
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

On Windows (PowerShell):
```powershell
Write-Host "OS=$([System.Environment]::OSVersion.Platform)" ; Write-Host "USER=$env:USERNAME" ; Write-Host "HOME=$env:USERPROFILE"
```

**OS detection note**: Cascade should detect the OS from the shell environment. If `uname` fails or returns nothing, assume Windows. On Windows, `HOME_DIR` = `$env:USERPROFILE` (e.g. `C:\Users\dev`). Use **forward slashes** in all generated paths for VS Code/Windsurf compatibility.

Detect `TEAM_DIR` automatically using this strategy (in order):
1. **From this workflow file's path**: this file lives at `TEAM_DIR/windsurf/global_workflows/amelio-onboarding.md` — resolve two levels up to get `TEAM_DIR`
2. **Search the current workspace**: look for the folder named `"👥 — 🏠 Amelio Team Hub"` in the Windsurf workspace roots
3. **Search common locations**: look for a directory named `amelio-team-hub` in `~/`, `~/Desktop/`, `~/Downloads/`, and the current working directory

The `TEAM_DIR` is the root of the `amelio-team-hub` repo (contains `README.md`, `setup.sh`, `windsurf/`, `config-files/`).
If detection fails, ask the user to confirm the path.

### 0c — Ask installation directory
Ask the user with a multiple-choice question:
- **A**: Use **this repo as parent** — repos will be cloned inside `amelio-team-hub/REPOs/` (recommended — single root, everything in one place)
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
- `FS_DIR` = `${AMELIO_DIR}/REPOs`
- `TEAM_DIR` = auto-detected bundle path
- `CFG_DIR` = `${TEAM_DIR}/config-files`

### 0d — Set up Azure DevOps PAT (via .env file)

**Do NOT paste your PAT directly in chat** — use the `.env` file approach instead.

**Step 1 — Create your `.env` file from the template:**
```bash
cp "${TEAM_DIR}/.env.template" "${TEAM_DIR}/.env"
```
On Windows (PowerShell):
```powershell
Copy-Item "${TEAM_DIR}/.env.template" "${TEAM_DIR}/.env"
```

**Step 2 — Open `${TEAM_DIR}/.env` and replace `your-azure-devops-pat-here`** with your real PAT.
> Generate one at: https://dev.azure.com/ameliodev/_usersSettings/tokens
> Required scopes: **Code (Read & Write)**, **Packaging (Read)**

The `.env` file is listed in `.gitignore` — it will **never** be committed to the repo.

**Step 3 — Load the PAT into the session:**
// turbo
```bash
export $(grep -v '^#' "${TEAM_DIR}/.env" | xargs)
echo "ADO_PAT loaded: ${ADO_PAT:0:4}****"
```
On Windows (PowerShell):
```powershell
Get-Content "${TEAM_DIR}/.env" | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '=' } | ForEach-Object {
  $parts = $_ -split '=', 2
  [System.Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
}
Write-Host "ADO_PAT loaded: $($env:ADO_PAT.Substring(0,4))****"
```

Confirm the PAT is loaded (shows first 4 chars only). Store as `ADO_PAT` for use in Step 3 and Step 12.

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
> - Repos will be cloned inside: [TEAM_DIR]/REPOs/
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

On Windows (PowerShell):
```powershell
Write-Host "=== Checking installed tools ==="
function Check-Tool($name, $cmd) { try { $v = & $cmd 2>$null; Write-Host "${name}: $v" } catch { Write-Host "${name}: NOT INSTALLED" } }
Check-Tool "node" { node -v }
Check-Tool "npm" { npm -v }
Check-Tool "yarn" { yarn -v }
Check-Tool "git" { git --version }
Check-Tool "dotnet" { dotnet --version }
Check-Tool "docker" { docker --version }
Check-Tool "gh" { (gh --version | Select-Object -First 1) }
Check-Tool "mongosh" { mongosh --version }
```

Present a table of what is installed vs missing. **Only install what is missing.**

### 1b — Install missing tools (macOS)
If `OS_TYPE` = `Darwin`:

**Step 1 — Install Homebrew if missing:**
```bash
which brew &>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Step 2 — Add Homebrew to PATH (Apple Silicon Macs):**
```bash
echo >> ~/.zprofile && echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile && eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

**Step 3 — Install ONLY missing tools:**
```bash
brew install node yarn git git-lfs gh mongosh
```

> **Note on yarn**: If `brew install yarn` reports a symlink conflict (`/opt/homebrew/bin/yarn already exists`), run:
> ```bash
> brew link --overwrite yarn
> ```

**Step 3b — Docker (choose one approach — ask the user):**
- **A**: Docker Desktop (full GUI — requires manual launch and system extension approval)
- **B**: Colima — Docker CLI only, fully headless, no GUI required (recommended for full automation)

If **A** (Docker Desktop):
```bash
brew install --cask docker
open /Applications/Docker.app
```
> Tell user: **Docker Desktop is launching — wait for the whale icon in the menu bar before continuing.**

If **B** (Colima — headless Docker Engine):
```bash
brew install colima docker docker-compose
colima start --cpu 4 --memory 8
```
> Colima runs a lightweight Linux VM with Docker Engine. All `docker` and `docker-compose` commands work identically to Docker Desktop.
> To auto-start on login:
> ```bash
> brew services start colima
> ```

Verify Docker is available:
```bash
docker info --format '{{.ServerVersion}}'
```

**Step 4 — Add dotnet tools to PATH:**
```bash
echo 'export PATH="$PATH:/Users/${USERNAME}/.dotnet/tools"' >> ~/.zprofile && export PATH="$PATH:${HOME}/.dotnet/tools"
```

**Step 5 — Install dotnet-ef (Entity Framework CLI):**
```bash
dotnet tool install --global dotnet-ef
```

**Step 6 — Configure git global identity:**
```bash
git config --global user.name "[Full Name]"
git config --global user.email "[email@example.com]"
```

### 1c — Install missing tools (Windows)
If `OS_TYPE` = `Windows_NT`:
Use `winget` (built-in Windows 11) to install ONLY missing tools.

**IMPORTANT: Install Git FIRST** — it includes Git Bash which provides the Unix shell environment needed for all subsequent steps.
```powershell
# Install Git first (includes Git Bash)
winget install --id Git.Git -e
```

After Git is installed, tell the user:
> Git Bash is now available. For the rest of this onboarding, I will use Git Bash commands.
> **Please configure Windsurf to use Git Bash as default terminal:**
> Settings > Terminal > Default Profile (Windows) > **Git Bash**
> Or add to settings.json: `"terminal.integrated.defaultProfile.windows": "Git Bash"`

Then install remaining tools:
```powershell
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Yarn.Yarn -e
winget install --id GitHub.cli -e
winget install --id Microsoft.DotNet.SDK.8 -e
winget install --id Microsoft.AzureCLI -e
winget install --id MongoDB.Server -e
winget install --id MongoDB.Shell -e
winget install --id MongoDB.Compass.Full -e
winget install --id Docker.DockerDesktop -e
```

**After this step, switch to Git Bash terminal** for all remaining commands. All bash commands in this workflow are compatible with Git Bash on Windows.

### 1d — Docker Engine (verify running)

Verify Docker is available and running:
// turbo
```bash
docker info --format '{{.ServerVersion}}' 2>&1
```

On Windows (PowerShell):
```powershell
docker info --format '{{.ServerVersion}}'
```

If Docker is not running:
- **macOS with Docker Desktop**: `open /Applications/Docker.app` and wait for the whale icon
- **macOS with Colima**: `colima start`
- **Windows**: Launch Docker Desktop from the Start menu

If Docker is not installed at all, go back to Step 1b/1c and install it.

### 1e — Verify all
// turbo
```bash
echo "=== Final verification ===" && node -v && npm -v && yarn -v && dotnet --version && docker --version && gh --version && mongosh --version
```

On Windows (PowerShell):
```powershell
Write-Host "=== Final verification ==="; node -v; npm -v; yarn -v; dotnet --version; docker --version; gh --version; mongosh --version
```

---

## Step 2 — Create Directory Structure

Both modes create the same subdirectory structure — the only difference is where `AMELIO_DIR` points.

**If `INSTALL_MODE` = `team-hub-parent`**: `AMELIO_DIR` = `TEAM_DIR` (the amelio-team-hub repo root).
The `REPOs/` and `DB_Freemium/` directories will be created **inside** the team-hub repo, but they are excluded from git via `.gitignore`.

**If `INSTALL_MODE` = `separate`**: `AMELIO_DIR` = `~/Amelio_primary` (or custom path).

```bash
mkdir -p "${AMELIO_DIR}/REPOs"
mkdir -p "${AMELIO_DIR}/Documentations"
mkdir -p "${AMELIO_DIR}/WorkSpace"
mkdir -p "${AMELIO_DIR}/DB_Freemium"
```

> **Layout note**: `Documentations/` and `WorkSpace/` are created **at the root of `AMELIO_DIR`** (beside `windsurf/`, `REPOs/`, etc.) — NOT inside `REPOs/`. The 5 cloned repos go directly inside `REPOs/` with no intermediate subfolder.

On Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "${AMELIO_DIR}\REPOs"
New-Item -ItemType Directory -Force -Path "${AMELIO_DIR}\Documentations"
New-Item -ItemType Directory -Force -Path "${AMELIO_DIR}\WorkSpace"
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

On Windows (PowerShell):
```powershell
Get-ChildItem "${FS_DIR}" -Name
```

---

## Step 4 — Deploy Windsurf Configuration (from amelio-team-hub)

All source files come from `${TEAM_DIR}` — the amelio-team-hub repo the user cloned.

### 4a — Deploy rules
```bash
mkdir -p "${HOME_DIR}/.codeium/.windsurf/rules"
cp "${TEAM_DIR}/windsurf/rules/"*.md "${HOME_DIR}/.codeium/.windsurf/rules/"
```

On Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "${HOME_DIR}/.codeium/.windsurf/rules"
Copy-Item "${TEAM_DIR}/windsurf/rules/*.md" "${HOME_DIR}/.codeium/.windsurf/rules/"
```

### 4b — Deploy global rules (memories)
```bash
mkdir -p "${HOME_DIR}/.codeium/windsurf/memories"
cp "${TEAM_DIR}/windsurf/memories/global_rules.md" "${HOME_DIR}/.codeium/windsurf/memories/"
```

On Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "${HOME_DIR}/.codeium/windsurf/memories"
Copy-Item "${TEAM_DIR}/windsurf/memories/global_rules.md" "${HOME_DIR}/.codeium/windsurf/memories/"
```

### 4c — Deploy shared skills
```bash
for skill_dir in "${TEAM_DIR}/windsurf/skills/"*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "${HOME_DIR}/.codeium/windsurf/skills/${skill_name}"
  cp -R "${skill_dir}"* "${HOME_DIR}/.codeium/windsurf/skills/${skill_name}/"
done
```

On Windows (PowerShell):
```powershell
Get-ChildItem "${TEAM_DIR}/windsurf/skills" -Directory | ForEach-Object {
  $dest = "${HOME_DIR}/.codeium/windsurf/skills/$($_.Name)"
  New-Item -ItemType Directory -Force -Path $dest
  Copy-Item "$($_.FullName)/*" $dest -Recurse -Force
}
```

### 4d — Deploy global workflows

> **🚫 NEVER deploy workflow files into the cloned ADO repos** (e.g. `amelio-ui-library/.windsurf/workflows/`, `amelio-performance-backend/.windsurf/workflows/`). Those files would be git-tracked and committed to shared repos. Workflows are **personal/machine-level config** and must ONLY go to the global Windsurf location below.

```bash
mkdir -p "${HOME_DIR}/.codeium/windsurf/global_workflows"
cp "${TEAM_DIR}/windsurf/global_workflows/"*.md "${HOME_DIR}/.codeium/windsurf/global_workflows/"
```

On Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "${HOME_DIR}/.codeium/windsurf/global_workflows"
Copy-Item "${TEAM_DIR}/windsurf/global_workflows/*.md" "${HOME_DIR}/.codeium/windsurf/global_workflows/"
```

### 4e — Verify deployment
// turbo
```bash
echo "=== Rules ===" && ls "${HOME_DIR}/.codeium/.windsurf/rules/"
echo "=== Global Rules ===" && ls "${HOME_DIR}/.codeium/windsurf/memories/global_rules.md"
echo "=== Skills ===" && ls "${HOME_DIR}/.codeium/windsurf/skills/"
echo "=== Global Workflows ===" && ls "${HOME_DIR}/.codeium/windsurf/global_workflows/"
```

On Windows (PowerShell):
```powershell
Write-Host "=== Rules ==="; Get-ChildItem "${HOME_DIR}/.codeium/.windsurf/rules/" -Name
Write-Host "=== Global Rules ==="; Test-Path "${HOME_DIR}/.codeium/windsurf/memories/global_rules.md"
Write-Host "=== Skills ==="; Get-ChildItem "${HOME_DIR}/.codeium/windsurf/skills/" -Name
Write-Host "=== Global Workflows ==="; Get-ChildItem "${HOME_DIR}/.codeium/windsurf/global_workflows/" -Name
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

On Windows (PowerShell):
```powershell
docker start amelio_mongodb 2>$null; if (-not $?) { Write-Host "Container not found, creating..." }
```

### 5b — Create docker-compose.override.yml for Performance Backend

> **IMPORTANT**: The `docker-compose.yml` in `amelio-performance-backend` uses `postgres:18` which has a known volume path incompatibility on fresh installs. **Do NOT modify `docker-compose.yml` directly** — it is tracked by git. Instead, create a `docker-compose.override.yml` (already listed in `.gitignore`) to pin postgres to version 17 locally.

```bash
cat > "${FS_DIR}/amelio-performance-backend/docker-compose.override.yml" << 'EOF'
services:
  dev_db:
    image: postgres:17
    volumes:
      - dev_db_data:/var/lib/postgresql/data
EOF
echo "docker-compose.override.yml created"
```

On Windows (PowerShell):
```powershell
@"
services:
  dev_db:
    image: postgres:17
    volumes:
      - dev_db_data:/var/lib/postgresql/data
"@ | Set-Content "${FS_DIR}/amelio-performance-backend/docker-compose.override.yml"
Write-Host "docker-compose.override.yml created"
```

### 5c — Start Performance Backend containers (PostgreSQL, Redis, Mailpit)
```bash
cd "${FS_DIR}/amelio-performance-backend" && npm run start-docker
```

This starts:
- **dev_db** (PostgreSQL 17) on port 5432
- **test_db** (PostgreSQL) on port 5433
- **dev_cache** (Redis) on port 6379
- **mailpit** on ports 8025 (UI) and 1025 (SMTP)

### 5d — Verify all containers
// turbo
```bash
echo "=== Docker containers ===" && docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected: 5 containers running (amelio_mongodb, dev_db, test_db, dev_cache, mailpit).

---

## Step 6 — Database Setup

### 6a — Import MongoDB Freemium database

The MongoDB dump (`DB_Freemium/`) contains ~242 compressed BSON files (~286 MB). It is **not in the git repo** — it is hosted on SharePoint.

**Step 1 — Open SharePoint and trigger the download:**

Tell the user:
> 🔐 **SharePoint access required** — you must be logged in with your `@amelio.co` Microsoft account.
> I'm opening the SharePoint folder now. Once the page loads, click **Download** in the top toolbar — SharePoint will automatically package the folder as a zip and save it to your `Downloads/` folder.

Open the SharePoint link in the default browser:
```bash
open "https://maximeamelio-my.sharepoint.com/:f:/g/personal/jonathan_jeanson_amelio_co/IgCvn1EI2JNaSaoYAr-OWY9oATasfEGdAIgKaJj-oeLm-Ys?e=DGMKIH"
```

On Windows (PowerShell):
```powershell
Start-Process "https://maximeamelio-my.sharepoint.com/:f:/g/personal/jonathan_jeanson_amelio_co/IgCvn1EI2JNaSaoYAr-OWY9oATasfEGdAIgKaJj-oeLm-Ys?e=DGMKIH"
```

Ask the user:
- **A**: The zip has finished downloading to my `Downloads/` folder
- **B**: I can't access SharePoint right now — skip for now

If B, skip and note that Legacy Backend will have no data on first run.

**Step 2 — Auto-detect and extract the zip:**

Once the user confirms (A), detect the zip automatically — SharePoint may name it `DB_Freemium.zip` or `DB_Freemium-[timestamp].zip`:

```bash
DOWNLOADS="${HOME}/Downloads"
DB_ZIP=$(ls -t "${DOWNLOADS}"/DB_Freemium*.zip 2>/dev/null | head -1)
if [ -z "$DB_ZIP" ]; then
  echo "ERROR: No DB_Freemium*.zip found in ~/Downloads/ — check the download completed."
else
  echo "Found: ${DB_ZIP}"
  mkdir -p "${AMELIO_DIR}/DB_Freemium"
  unzip -o "${DB_ZIP}" -d "${AMELIO_DIR}"
  rm "${DB_ZIP}"
  echo "Extracted to ${AMELIO_DIR}/DB_Freemium/"
fi
```

On Windows (PowerShell):
```powershell
$downloads = "$env:USERPROFILE\Downloads"
$dbZip = Get-ChildItem "$downloads\DB_Freemium*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $dbZip) {
  Write-Host "ERROR: No DB_Freemium*.zip found in Downloads — check the download completed."
} else {
  Write-Host "Found: $($dbZip.FullName)"
  New-Item -ItemType Directory -Force -Path "${AMELIO_DIR}\DB_Freemium"
  Expand-Archive -Path $dbZip.FullName -DestinationPath "${AMELIO_DIR}" -Force
  Remove-Item $dbZip.FullName
  Write-Host "Extracted to ${AMELIO_DIR}\DB_Freemium\"
}
```

Verify the dump is in place:
```bash
ls "${AMELIO_DIR}/DB_Freemium/Freemium/" | head -5
```
Expected: `.bson.gz` and `.metadata.json.gz` files. If the folder structure is different (e.g. `DB_Freemium/DB_Freemium/Freemium/`), adjust `DB_PATH` in the next step accordingly.

**Step 3 — Import into MongoDB:**

Use: `DB_PATH="${AMELIO_DIR}/DB_Freemium/Freemium"`
If the structure differs (e.g. `DB_Freemium/DB_Freemium/Freemium/`), adjust accordingly.

```bash
mongorestore --host localhost:27017 \
  --username ameliodb --password ameliodb \
  --authenticationDatabase admin \
  --db Freemium \
  --gzip \
  "${DB_PATH}/"
```

On Windows (PowerShell):
```powershell
mongorestore --host localhost:27017 `
  --username ameliodb --password ameliodb `
  --authenticationDatabase admin `
  --db Freemium `
  --gzip `
  "${DB_PATH}\"
```

Verify:
```bash
mongosh "mongodb://ameliodb:ameliodb@localhost:27017/Freemium?authSource=admin" --eval "db.getCollectionNames().length + ' collections imported'"
```
Expected: `121 collections imported` (or similar non-zero number).

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

On Windows (PowerShell):
```powershell
Copy-Item "${CFG_DIR}/performance-backend/appsettings.Development.json" "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/"
Copy-Item "${CFG_DIR}/performance-backend/appsettings.Testing.json" "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/"
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

> **Note**: These files are git-tracked. Your local changes will show in `git status`. **Do NOT commit them** — they contain machine-specific connection strings. Use `git stash` or `git checkout <file>` if you need to revert.

### 7c — NuGet setup

#### Part 1 — Set NUGET_PACKAGES environment variable (macOS ONLY)
On macOS, the repo `NuGet.config` hardcodes `$(UserProfile)\.nuget\packages` (Windows-only variable) as `globalPackagesFolder`. This resolves to an invalid path on macOS, causing NuGet to use a wrong cache directory.

**Do NOT modify the repo's `NuGet.config`** — it is git-tracked.

The fix is to set the `NUGET_PACKAGES` environment variable, which takes **highest priority** over any `NuGet.config` setting:

```bash
echo 'export NUGET_PACKAGES="${HOME}/.nuget/packages"' >> ~/.zprofile
export NUGET_PACKAGES="${HOME_DIR}/.nuget/packages"
echo "NUGET_PACKAGES set to: ${NUGET_PACKAGES}"
```

Verify NuGet resolves the correct cache path:
```bash
cd "${FS_DIR}/Amelio - Back-End" && dotnet nuget locals global-packages --list
```
Expected: `global-packages: /Users/<username>/.nuget/packages`

On Windows (PowerShell):
```powershell
# Skip Part 1 entirely — $(UserProfile) resolves natively on Windows.
```

#### Part 2 — Create user-level NuGet config (BOTH macOS and Windows)
This provides the ADO PAT credentials for the private `Amelio.MongoRepository` NuGet feed.

```bash
mkdir -p "${HOME_DIR}/.nuget/NuGet"
```
On Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.nuget\NuGet"
```

Read the template from `${CFG_DIR}/nuget/NuGet.Config.template`, replace:
- `<HOME_DIR>` with the actual home directory path (macOS: `/Users/username`, Windows: `C:\Users\username`)
- `<REPLACE_WITH_NUGET_PAT>` with the ADO PAT from Step 0d

Save to: `${HOME_DIR}/.nuget/NuGet/NuGet.Config`

> **CRITICAL**: Without this config, `dotnet restore` for Legacy Backend will fail with `401 Unauthorized` on the Amelio.MongoRepository feed. **The most common cause is a PAT missing the Packaging (Read) scope** — ensure the PAT used in Step 0d has both **Code (Read & Write)** and **Packaging (Read)** scopes.

Verify the generated file looks correct:
```bash
cat "${HOME_DIR}/.nuget/NuGet/NuGet.Config"
```
Expected: file contains `<packageSourceCredentials>` with your PAT and `<config>` with `globalPackagesFolder`.

### 7d — Legacy Frontend config

`.env.development` and `.env.local` are **git-tracked in the `Amelio - React` repo** — they are already present after `git clone`. No copy needed.

> **Note**: `.env.development` and `.env.local` are git-tracked. If you modify them locally (e.g. change API URLs), those changes will show in `git status`. **Do NOT commit them.** Use `git checkout .env.development .env.local` to revert if needed.

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

On Windows (PowerShell):
```powershell
Set-Location "${FS_DIR}/amelio-performance-fe"
if (Test-Path .env.sample) {
  Copy-Item .env.sample .env
} else {
  Copy-Item "${CFG_DIR}/performance-fe/.env.template" .env
}
```

Tell user:
> The `VITE_DEV_TOKEN` in `.env` needs a JWT token from the Legacy Frontend.
> You can get it later by logging into http://localhost:3011, opening DevTools > Network,
> and copying the Bearer token from any API request header.

---

## Step 8 — Install Dependencies & Build Projects

### 8a — Azure DevOps npm authentication (for @amelio packages)

> **🚫 NEVER modify the `.npmrc` files inside the cloned repos** — they are git-tracked. The repo `.npmrc` files already declare the correct registry URL. Credentials must go in the **user-level `~/.npmrc`** only.

Add ADO credentials to the global `~/.npmrc` (created if it doesn't exist):

```bash
cat > "${HOME}/.npmrc" << EOF
//pkgs.dev.azure.com/ameliodev/_packaging/amelio-performance-feed/npm/registry/:_authToken=${ADO_PAT}
EOF
echo "Global ~/.npmrc updated"
```

On Windows (PowerShell):
```powershell
Set-Content "$env:USERPROFILE\.npmrc" "//pkgs.dev.azure.com/ameliodev/_packaging/amelio-performance-feed/npm/registry/:_authToken=$env:ADO_PAT"
Write-Host "Global ~/.npmrc updated"
```

> **Why `~/.npmrc` and not the repo `.npmrc`?** npm automatically merges the user-level `~/.npmrc` with the project-level `.npmrc`. Credentials in `~/.npmrc` apply to all projects without polluting git history. The repo `.npmrc` only declares the registry URL — that is already committed and must not be modified.

> **`_authToken` format**: Use the raw PAT directly as `_authToken`. Do NOT use `_password` + `username` + B64 — that format is rejected by modern npm versions.

### 8b — UI Library (install + build — REQUIRED before Performance FE)
```bash
cd "${FS_DIR}/amelio-ui-library" && yarn install && yarn build
```
The `yarn build` creates the `dist/` folder that Performance FE depends on.

### 8c — Performance Frontend

> **Note**: This project uses `yarn` as its package manager but Yarn 1.x does not correctly resolve scoped ADO registries (`@amelio:registry`) from `.npmrc`. Use `npm install` instead — it reads `~/.npmrc` correctly and resolves `@amelio/ui-library` from the ADO feed.

```bash
cd "${FS_DIR}/amelio-performance-fe" && npm install
```

After install, remove the `package-lock.json` created by npm (this repo uses yarn.lock, not package-lock.json):
```bash
rm -f "${FS_DIR}/amelio-performance-fe/package-lock.json"
```

Verify no git-tracked file was modified:
```bash
git -C "${FS_DIR}/amelio-performance-fe" status --short
```
Expected: empty output.

### 8d — Performance Backend
```bash
cd "${FS_DIR}/amelio-performance-backend" && dotnet restore
```

### 8e — Legacy Frontend (uses npm, NOT yarn)
```bash
cd "${FS_DIR}/Amelio - React" && npm ci --legacy-peer-deps
```
**IMPORTANT**: This project uses `npm ci` (not `npm install`) with `--legacy-peer-deps` due to React 18 peer dependency conflicts. `npm ci` installs from the existing `package-lock.json` **without modifying it** — this prevents accidental diffs on a git-tracked file. Do NOT use `yarn`.

> **🚫 NEVER run `npm install` here** — it WILL modify `package-lock.json` (a git-tracked file), creating an unwanted diff. Always use `npm ci`.

After install, verify `package-lock.json` was NOT modified:
```bash
git -C "${FS_DIR}/Amelio - React" diff --name-only
```
Expected: empty output. If `package-lock.json` appears, restore it immediately:
```bash
git -C "${FS_DIR}/Amelio - React" checkout package-lock.json
```

### 8f — Legacy Backend
```bash
cd "${FS_DIR}/Amelio - Back-End" && dotnet restore
```

> **Known issue — 401 Unauthorized**: If `dotnet restore` fails with `401 Unauthorized` on the `Amelio.MongoRepository` feed, the PAT does not have **Packaging (Read)** scope. Generate a new PAT at https://dev.azure.com/ameliodev/_usersSettings/tokens with scopes **Code (Read & Write)** + **Packaging (Read)**, update `${HOME_DIR}/.nuget/NuGet/NuGet.Config` with the new PAT, and retry.

> **Known issue — NU1202 (package incompatible with net8.0)**: If `dotnet restore` fails with `NU1202: Amelio.MongoRepository 3.x.x n'est pas compatible avec net8.0`, the ADO feed only publishes a newer version targeting net10.0. The projects require `2.1.3` (net8.0) which is no longer on the feed. **Workaround**: copy the package from another developer's NuGet cache:
> ```bash
> # Ask a team member for their NuGet cache path, or check other users on this machine
> find /Users -name "amelio.mongorepository.2.1.3.nupkg" 2>/dev/null
> # Then copy to your cache:
> mkdir -p "${HOME_DIR}/.nuget/packages/amelio.mongorepository/2.1.3"
> cp -R "<SOURCE_PATH>/2.1.3/"* "${HOME_DIR}/.nuget/packages/amelio.mongorepository/2.1.3/"
> ```
> After copying, re-run `dotnet restore` — NuGet will use the local cache instead of downloading from the feed.

Verify NuGet restore succeeded (macOS):
```bash
find . -name "*.nupkg" | wc -l
```

On Windows (PowerShell):
```powershell
(Get-ChildItem -Recurse -Filter "*.nupkg" | Measure-Object).Count
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

On Windows (PowerShell):
```powershell
Write-Host "=== UI Library dist ==="; Get-ChildItem "${FS_DIR}/amelio-ui-library/dist/" -Name | Select-Object -First 5
Write-Host "=== Perf FE node_modules ==="; Get-ChildItem "${FS_DIR}/amelio-performance-fe/node_modules/" -Name | Select-Object -First 3
Write-Host "=== Legacy FE node_modules ==="; Get-ChildItem "${FS_DIR}/Amelio - React/node_modules/" -Name | Select-Object -First 3
Write-Host "=== Perf BE restore ==="; Get-ChildItem "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/bin/" -Name | Select-Object -First 3
Write-Host "=== Legacy BE restore ==="; Get-ChildItem "${FS_DIR}/Amelio - Back-End/OPIA.API.V2/bin/" -Name | Select-Object -First 3
```

---

## Step 9 — Extensions Installation

Ask the user with a multiple-choice question:
- **A**: Essential only (23 — ESLint, GitLens, C#, Tailwind, Docker, Vitest, MongoDB...)
- **B**: Essential + Visual (27 — adds Material Icons, Folder Color, Mermaid, Color Highlight)
- **C**: Essential + Visual + Extras (31 — adds PDF viewer, ADO Boards sidebar, LiveServer, Qodo AI tests)
- **D**: I want to pick my own extensions — just show me the list
- **E**: Skip — I'll install extensions later on my own

Extension files are in `${TEAM_DIR}/ide-settings/`:

> **macOS note**: `windsurf` is not automatically in PATH. Resolve the binary first:
> ```bash
> WINDSURF=$(which windsurf 2>/dev/null || echo "/Applications/Windsurf.app/Contents/Resources/app/bin/windsurf")
> ```

For **A/B/C**, install essentials:
```bash
WINDSURF=$(which windsurf 2>/dev/null || echo "/Applications/Windsurf.app/Contents/Resources/app/bin/windsurf")
FAILED=0; SUCCESS=0
while IFS= read -r ext; do
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  if "$WINDSURF" --install-extension "$ext" --force 2>&1 | grep -q "successfully installed\|already installed"; then
    SUCCESS=$((SUCCESS+1))
  else
    echo "FAILED: $ext"; FAILED=$((FAILED+1))
  fi
done < "${TEAM_DIR}/ide-settings/extensions-team.txt"
echo "Essentials: ${SUCCESS} succeeded, ${FAILED} failed"
```

For **B/C**, also install optional:
```bash
while IFS= read -r ext; do
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  if "$WINDSURF" --install-extension "$ext" --force 2>&1 | grep -q "successfully installed\|already installed"; then
    SUCCESS=$((SUCCESS+1))
  else
    echo "FAILED: $ext"; FAILED=$((FAILED+1))
  fi
done < "${TEAM_DIR}/ide-settings/extensions-optional.txt"
```

For **C**, also install extras (parse `ext-id | description`):
```bash
while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  ext_id=$(echo "$line" | cut -d'|' -f1 | xargs)
  if "$WINDSURF" --install-extension "$ext_id" --force 2>&1 | grep -q "successfully installed\|already installed"; then
    SUCCESS=$((SUCCESS+1))
  else
    echo "FAILED: $ext_id"; FAILED=$((FAILED+1))
  fi
done < "${TEAM_DIR}/ide-settings/extensions-extras.txt"
```

On Windows (PowerShell) — same logic for all tiers:
```powershell
# Essentials (A/B/C)
Get-Content "${TEAM_DIR}/ide-settings/extensions-team.txt" | Where-Object { $_ -and $_ -notmatch '^\s*#' } | ForEach-Object {
  windsurf --install-extension $_.Trim() --force 2>&1 | Out-Null
  if (-not $?) { Write-Host "FAILED: $_" }
}

# Optional (B/C)
Get-Content "${TEAM_DIR}/ide-settings/extensions-optional.txt" | Where-Object { $_ -and $_ -notmatch '^\s*#' } | ForEach-Object {
  windsurf --install-extension $_.Trim() --force 2>&1 | Out-Null
  if (-not $?) { Write-Host "FAILED: $_" }
}

# Extras (C) — parse "ext-id | description"
Get-Content "${TEAM_DIR}/ide-settings/extensions-extras.txt" | Where-Object { $_ -and $_ -notmatch '^\s*#' } | ForEach-Object {
  $extId = ($_ -split '\|')[0].Trim()
  windsurf --install-extension $extId --force 2>&1 | Out-Null
  if (-not $?) { Write-Host "FAILED: $extId" }
}
```

Report: X succeeded, Y failed. If any failed, propose manual install.

For **D** (manual pick), present the full list of available extensions from all 3 files as a numbered checklist:
1. Read all 3 extension files (`extensions-team.txt`, `extensions-optional.txt`, `extensions-extras.txt`)
2. Present each extension with its category (Essential / Visual / Extra) and a checkbox-style list
3. Ask the user to select which ones they want (by number or range, e.g. "1-15, 18, 22")
4. Install only the selected extensions using the same `windsurf --install-extension` command

For **E** (skip), tell the user:
> Extension files are available in `${TEAM_DIR}/ide-settings/` if you want to install them later.
> You can run `windsurf --install-extension <ext-id> --force` for each one, or re-run this step.

---

## Step 10 — Generate Personalized Workspace

Read the workspace template from `${TEAM_DIR}/windsurf/workspace/Template.code-workspace`.

### If `INSTALL_MODE` = `team-hub-parent`
Modifications to apply:
1. **Keep** the first folder entry `"👥 — 🏠 Amelio Team Hub"` and keep its `path` as `".."` — the workspace file is saved in `${AMELIO_DIR}/WorkSpace/`, so `".."` correctly resolves one level up to the team-hub root
2. **Replace** ALL `<AMELIO_DIR>` with the actual `${AMELIO_DIR}` (= `${TEAM_DIR}`) path:
   - macOS: e.g. `/Users/${USERNAME}/amelio-team-hub` (wherever the repo was cloned)
   - Windows: use forward slashes for VS Code

### If `INSTALL_MODE` = `separate`
Modifications to apply:
1. **Remove** the first folder entry `"👥 — 🏠 Amelio Team Hub"` (path `".."`), as it is only relevant when the team-hub is the parent directory
2. **Replace** ALL `<AMELIO_DIR>` with the actual `${AMELIO_DIR}` path chosen in Step 0:
   - macOS: `/Users/${USERNAME}/Amelio_primary` (or custom path)
   - Windows: `C:/Users/${USERNAME}/Amelio_primary` (use forward slashes for VS Code)

**Ask the user to choose a filename** for their personalized workspace. Suggest:
- **A**: `Amelio_${USERNAME}.code-workspace` (uses OS username, e.g. `Amelio_devtest.code-workspace`)
- **B**: `Amelio_[FirstName][LastName].code-workspace` (e.g. `Amelio_JonathanJeanson.code-workspace`) — recommended for team clarity
- **C**: `[FirstName][LastName].code-workspace` (e.g. `JonathanJeanson.code-workspace`)
- **D**: I want a different name (I will specify)

> **Note**: The template file is named `Template.code-workspace`. Do NOT use `Template_` or `Simple_` as a prefix for personal workspace files. Use `Amelio_` or just the employee name.

**IMPORTANT — NEVER overwrite an existing file.** Before saving, check if the target file already exists:
```bash
WORKSPACE_FILE="${AMELIO_DIR}/WorkSpace/${CHOSEN_NAME}.code-workspace"
if [ -f "$WORKSPACE_FILE" ]; then
  echo "ERROR: File already exists: $WORKSPACE_FILE"
  echo "Choose a different name to avoid overwriting."
else
  # generate and save
fi
```

If the file already exists, ask the user to choose a different name before proceeding.

Save as `${AMELIO_DIR}/WorkSpace/${CHOSEN_NAME}.code-workspace`.

Tell user:
> Your personalized workspace is ready! To open it:
> **File > Open Workspace from File** and select `${CHOSEN_NAME}.code-workspace`.
> ⚠️ This file is personal — do NOT commit it to git. Add it to `.gitignore` if needed.

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

These tools can be installed via CLI — no manual download required:

**Bruno** — API client (like Postman):
```bash
brew install --cask bruno
```
On Windows: `winget install --id Bruno.Bruno -e`

**DBeaver Community** — Universal database client (supports MongoDB, PostgreSQL, and 80+ databases):
```bash
brew install --cask dbeaver-community
```
On Windows: `winget install --id dbeaver.dbeaver -e`

> Once DBeaver is installed, it will auto-detect running databases. Connect to:
> - **MongoDB** (Legacy): `localhost:27017`, user `ameliodb`, password `ameliodb`, auth DB `admin`
> - **PostgreSQL dev_db** (Performance): `localhost:5432`, user `dev_user`, password `dev_password`, DB `dev_db`
> - **PostgreSQL test_db** (Performance): `localhost:5433`, user `dev_user`, password `dev_password`, DB `test_db`

Ask the user:
- **A**: Install Bruno and DBeaver now via CLI
- **B**: Install only Bruno
- **C**: Install only DBeaver
- **D**: Skip — I'll install them manually later

If A or B:
```bash
brew install --cask bruno
```
On Windows: `winget install --id Bruno.Bruno -e`

If A or C:
```bash
brew install --cask dbeaver-community
```
On Windows: `winget install --id dbeaver.dbeaver -e`

---

## Step 12 — Optional: Secondary Workspace

Ask the user:
- **A**: "I want a second workspace to work on two tasks in parallel"
- **B**: "Skip — one workspace is enough for now"

If A, create a second directory and clone the same 5 ADO repos:
```bash
mkdir -p "${HOME_DIR}/Amelio_secondary/REPOs"
ADO="https://${ADO_PAT}@dev.azure.com/ameliodev"
FS2="${HOME_DIR}/Amelio_secondary/REPOs"
git clone "${ADO}/Amelio%20-%20First%20Product/_git/Amelio%20-%20Back-End" "${FS2}/Amelio - Back-End"
git clone "${ADO}/Amelio%20-%20First%20Product/_git/Amelio%20-%20React" "${FS2}/Amelio - React"
git clone "${ADO}/Amelio-Performance%20Management/_git/amelio-performance-backend" "${FS2}/amelio-performance-backend"
git clone "${ADO}/Amelio-Performance%20Management/_git/amelio-performance-fe" "${FS2}/amelio-performance-fe"
git clone "${ADO}/Amelio-Development%20Packages/_git/amelio-ui-library" "${FS2}/amelio-ui-library"
```

On Windows (PowerShell):
```powershell
$FS2 = "${HOME_DIR}/Amelio_secondary/REPOs"
New-Item -ItemType Directory -Force -Path $FS2
$ADO = "https://${ADO_PAT}@dev.azure.com/ameliodev"
git clone "$ADO/Amelio%20-%20First%20Product/_git/Amelio%20-%20Back-End" "$FS2/Amelio - Back-End"
git clone "$ADO/Amelio%20-%20First%20Product/_git/Amelio%20-%20React" "$FS2/Amelio - React"
git clone "$ADO/Amelio-Performance%20Management/_git/amelio-performance-backend" "$FS2/amelio-performance-backend"
git clone "$ADO/Amelio-Performance%20Management/_git/amelio-performance-fe" "$FS2/amelio-performance-fe"
git clone "$ADO/Amelio-Development%20Packages/_git/amelio-ui-library" "$FS2/amelio-ui-library"
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
echo "=== 9. Workflows ===" && ls "${HOME_DIR}/.codeium/windsurf/global_workflows/"
echo "=== 10. Workspace ===" && ls "${AMELIO_DIR}/WorkSpace/" 2>&1
echo "=== 11. UI Library dist ===" && ls "${FS_DIR}/amelio-ui-library/dist/index.css" 2>&1
echo "=== 12. Config files ===" && ls "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/appsettings.Development.json" "${FS_DIR}/amelio-performance-fe/.env" "${FS_DIR}/Amelio - React/.env.development" 2>&1
```

On Windows (PowerShell):
```powershell
Write-Host "=== 1. Dependencies ==="; node -v; npm -v; yarn -v; dotnet --version; docker --version; gh --version; mongosh --version
Write-Host "=== 2. ADO Repos ==="; @("Amelio - Back-End","Amelio - React","amelio-performance-backend","amelio-performance-fe","amelio-ui-library") | ForEach-Object { Test-Path "${FS_DIR}/$_" }
Write-Host "=== 3. Docker Containers ==="; docker ps --format "{{.Names}}"
Write-Host "=== 4. MongoDB ==="; mongosh "mongodb://ameliodb:ameliodb@localhost:27017/Freemium?authSource=admin" --quiet --eval "db.getCollectionNames().length + ' collections'"
Write-Host "=== 5. PostgreSQL ==="; docker exec dev_db psql -U dev_user -d dev_db -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public'"
Write-Host "=== 6. Rules ==="; Get-ChildItem "${HOME_DIR}/.codeium/.windsurf/rules/" -Name
Write-Host "=== 7. Global Rules ==="; Test-Path "${HOME_DIR}/.codeium/windsurf/memories/global_rules.md"
Write-Host "=== 8. Skills ==="; Get-ChildItem "${HOME_DIR}/.codeium/windsurf/skills/" -Name
Write-Host "=== 9. Workflows ==="; Get-ChildItem "${HOME_DIR}/.codeium/windsurf/global_workflows/" -Name
Write-Host "=== 10. Workspace ==="; Get-ChildItem "${AMELIO_DIR}/WorkSpace/" -Name
Write-Host "=== 11. UI Library dist ==="; Test-Path "${FS_DIR}/amelio-ui-library/dist/index.css"
Write-Host "=== 12. Config files ==="; Test-Path "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/appsettings.Development.json"; Test-Path "${FS_DIR}/amelio-performance-fe/.env"; Test-Path "${FS_DIR}/Amelio - React/.env.development"
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
| 9 | Workflows deployed (global Windsurf location) | ? |
| 10 | Personalized workspace file | ? |
| 11 | UI Library built (dist/) | ? |
| 12 | Config files deployed (appsettings, .env) | ? |

If ALL pass, ask user:
- **A**: "Everything is perfect, onboarding is complete"
- **B**: "There are still things to fix"
- **C**: "I want to verify a specific point"

**CRITICAL: Task is NEVER done until the user explicitly says so. Always keep asking.**
