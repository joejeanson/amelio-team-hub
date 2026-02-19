# Amelio Team Hub — Testing Guide

> Test the onboarding workflow from scratch to validate the full 13-step experience.

---

## Phase 1: macOS Fresh User Account (~30 min)

### 1a — Create a temporary macOS user

1. Open **System Settings → Users & Groups**
2. Click **Add User** (unlock with admin password if needed)
3. Create a **Standard** user:
   - Name: `TestDev`
   - Account name: `testdev`
   - Password: something simple (temporary)
4. Log out of your current session
5. Log in as `testdev`

### 1b — Install Windsurf IDE

1. Open Safari, download Windsurf from https://codeium.com/windsurf
2. Install to `/Applications/` (drag to Applications folder)
3. Open Windsurf once to complete initial setup
4. Sign in with your Codeium account (or create a test one)

### 1c — Clone the Team Hub

From the testdev account:
```bash
cd ~/Desktop
git clone https://github.com/joejeanson/amelio-team-hub.git
```

### 1d — Prepare DB_Freemium dump (optional but recommended)
```bash
# From MAIN account, copy the dump:
cp -R /Users/m--server/Amelio_primary/DB_Freemium/ /Users/Shared/DB_Freemium/
```

### 1e — Run the onboarding test

1. Open Windsurf
2. File → Open Workspace from File → select `~/Desktop/amelio-team-hub/windsurf/workspace/Simple.code-workspace`
3. The sidebar should show **"👥 — 🏠 Amelio Team Hub"** as the first folder
4. In the sidebar, navigate to `windsurf/global_workflows/amelio-onboarding.md`
5. **Drag that file into the Cascade chat panel**
6. Cascade should read the workflow and start the interactive onboarding

### 1f — Validation checklist (macOS)

| # | Step | Check | Expected | Status |
|---|------|-------|----------|--------|
| 1 | — | Workspace opens correctly | Amelio Team Hub visible in sidebar | ☐ |
| 2 | — | Drag .md into Cascade | Cascade reads and starts onboarding | ☐ |
| 3 | 0 | OS detection | Detects "Darwin", correct username | ☐ |
| 4 | 0 | Install path prompt | Asks where to install (default ~/Amelio_primary) | ☐ |
| 5 | 0 | ADO PAT prompt | Asks for PAT with scope info | ☐ |
| 6 | 0 | Summary + confirm | Shows recap, CFG_DIR detected | ☐ |
| 7 | 1 | Dependency check | Detects missing tools (node, yarn, dotnet, docker, etc.) | ☐ |
| 8 | 1 | Homebrew install | Installs brew if missing | ☐ |
| 9 | 1 | Tools install | Installs ALL missing tools via brew | ☐ |
| 10 | 1 | Docker Desktop | Prompts to open Docker, verifies it started | ☐ |
| 11 | 2 | Directory creation | Creates Amelio_primary/REPOs/... + DB_Freemium | ☐ |
| 12 | 3 | Clone repos | Clones 5 ADO repos successfully | ☐ |
| 13 | 4 | Deploy Windsurf config | Rules, skills, global_rules, global_workflows, repo workflows | ☐ |
| 14 | 5 | MongoDB container | `docker ps` shows amelio_mongodb running on 27017 | ☐ |
| 15 | 5 | Perf BE containers | `npm run start-docker` → dev_db, test_db, dev_cache, mailpit | ☐ |
| 16 | 6 | MongoDB import | mongorestore succeeds (or skipped if no dump) | ☐ |
| 17 | 6 | PostgreSQL migrations | `npm run update-database` succeeds | ☐ |
| 18 | 7 | Perf BE config files | appsettings.Development.json + Testing.json copied | ☐ |
| 19 | 7 | Legacy BE config | MongoDB connection strings → localhost, skip-worktree set | ☐ |
| 20 | 7 | NuGet setup (Mac) | NuGet.config modified, skip-worktree, ~/.nuget/NuGet/NuGet.Config created | ☐ |
| 21 | 7 | Legacy FE config | .env.development + .env.local copied, skip-worktree set | ☐ |
| 22 | 7 | Perf FE config | .env created from sample/template | ☐ |
| 23 | 8 | npm auth | vsts-npm-auth or .npmrc verified for @amelio packages | ☐ |
| 24 | 8 | UI Library | yarn install + yarn build succeeds, dist/ exists | ☐ |
| 25 | 8 | Perf FE | yarn install succeeds | ☐ |
| 26 | 8 | Perf BE | dotnet restore succeeds | ☐ |
| 27 | 8 | Legacy FE | **npm install --legacy-peer-deps** (NOT yarn) succeeds | ☐ |
| 28 | 8 | Legacy BE | dotnet restore succeeds, 0 .nupkg in repo | ☐ |
| 29 | 9 | Extensions | Installs chosen extension level | ☐ |
| 30 | 10 | Workspace | Generates Simple_testdev.code-workspace | ☐ |
| 31 | 11 | Bookmarks | Shows all URLs including Mailpit, Bruno, DBeaver | ☐ |
| 32 | 13 | Final validation | All 12 checks pass | ☐ |

### 1g — Cleanup

1. Log out of `testdev`
2. Log back into your main account
3. System Settings → Users & Groups → Delete `testdev` (with "Delete home folder")

---

## Phase 2: Windows 11 VM with UTM (~45 min)

### 2a — Install UTM

1. Download UTM from https://mac.getutm.app/ (free) or Mac App Store ($9.99)
2. Install and open UTM

### 2b — Create Windows 11 ARM VM

1. In UTM, click **+** → **Virtualize** → **Windows**
2. UTM will guide you to download the Windows 11 ARM ISO
   - Or download directly: https://www.microsoft.com/software-download/windows11arm64
3. Configure the VM:
   - **RAM**: 8 GB minimum (16 GB recommended)
   - **CPU**: 4 cores minimum
   - **Disk**: 64 GB minimum
   - **Network**: Shared Network (NAT)
4. Install Windows 11 (follow the setup wizard)
   - Use a local account (skip Microsoft account: "Sign-in options" → "Offline account")
   - Name: `TestDev`

### 2c — Install Windsurf in the VM

1. Open Edge in Windows
2. Download Windsurf from https://codeium.com/windsurf
3. Install and open Windsurf
4. Sign in with your Codeium account

### 2d — Clone the Team Hub

In the Windows VM, open PowerShell:
```powershell
cd ~\Desktop
git clone https://github.com/joejeanson/amelio-team-hub.git
```

> If git is not installed yet, download it from https://git-scm.com/download/win first.

### 2e — Run the onboarding test

1. Open Windsurf
2. File → Open Workspace from File → select `C:\Users\TestDev\Desktop\amelio-team-hub\windsurf\workspace\Simple.code-workspace`
3. Sidebar should show **"👥 — 🏠 Amelio Team Hub"**
4. Navigate to `windsurf/global_workflows/amelio-onboarding.md`
5. **Drag that file into the Cascade chat panel**

### 2f — Validation checklist (Windows)

| # | Step | Check | Expected | Status |
|---|------|-------|----------|--------|
| 1 | — | Workspace opens correctly | Amelio Team Hub visible in sidebar | ☐ |
| 2 | — | Drag .md into Cascade | Cascade reads and starts onboarding | ☐ |
| 3 | 0 | OS detection | Detects Windows, correct username | ☐ |
| 4 | 0 | Install path prompt | Default: C:\Users\TestDev\Amelio_primary | ☐ |
| 5 | 0 | ADO PAT prompt | Asks for Azure DevOps PAT | ☐ |
| 6 | 1 | Dependency check | Detects missing tools | ☐ |
| 7 | 1 | winget install | Uses winget for git, node, dotnet, docker | ☐ |
| 8 | 1 | Docker Desktop | Prompts to open Docker, verifies started | ☐ |
| 9 | 2 | Directory creation | Creates Amelio dir structure (PowerShell) | ☐ |
| 10 | 3 | Clone repos | Clones 5 ADO repos with PAT | ☐ |
| 11 | 4 | Deploy Windsurf config | Copies to correct Windows paths | ☐ |
| 12 | 5 | Docker containers | MongoDB + start-docker → 5 containers | ☐ |
| 13 | 6 | Database setup | Migrations succeed | ☐ |
| 14 | 7 | Config files | appsettings, .env deployed correctly | ☐ |
| 15 | 7 | NuGet setup | Windows uses $(UserProfile) natively — SKIP NuGet Mac step | ☐ |
| 16 | 8 | npm auth | vsts-npm-auth works on Windows | ☐ |
| 17 | 8 | UI Library | yarn install + build → dist/ exists | ☐ |
| 18 | 8 | Legacy FE | npm install --legacy-peer-deps succeeds | ☐ |
| 19 | 8 | All restores | dotnet restore for both backends | ☐ |
| 20 | 9 | Extensions | Installs extensions via windsurf CLI | ☐ |
| 21 | 10 | Workspace | Generates Simple_TestDev.code-workspace (forward slashes) | ☐ |
| 22 | 13 | Final validation | All 12 checks pass | ☐ |

### 2g — Windows-specific things to watch

- **Path separators**: `\` vs `/` — workflow must use forward slashes in workspace file
- **NuGet**: Windows uses `$(UserProfile)` natively — Step 7c should be SKIPPED
- **winget availability**: Windows 11 has winget built-in, but older versions may not
- **PowerShell vs CMD**: The workflow should use PowerShell commands on Windows
- **Home directory**: `C:\Users\TestDev\` vs `/Users/testdev/`
- **Windsurf config path**: Check if `~/.codeium/` maps correctly on Windows
- **Docker Desktop**: May need Windows Subsystem for Linux (WSL2) enabled
- **npm global path**: May need `npm config set prefix` on Windows

---

## Bug Report Template

When you find an issue during testing, note it in this format:

```
### BUG: [Short description]
- **Phase**: macOS / Windows
- **Step**: Step X — [name]
- **Expected**: [what should happen]
- **Actual**: [what happened]
- **Error**: [error message if any]
- **Fix needed in**: [workflow / config-files / workspace / README]
```

---

## After Testing

1. Fix all bugs found in Phase 1 (macOS)
2. Re-test the fixed workflow on macOS
3. Fix all bugs found in Phase 2 (Windows)
4. Re-test on Windows
5. Commit the final tested bundle
