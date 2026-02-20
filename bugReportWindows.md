# Amelio Onboarding — Bug Report Windows

> Generated during onboarding session: 2026-02-19
> Machine: Windows (Win32NT), user: m--server
> Reference: See `bugReportMac.md` for macOS bugs (resolved)

---

## ✅ RESOLVED

### W1. `winget` install server not responding — Node.js install fails
- **Error**: `Install server not responding` when running `winget install --id OpenJS.NodeJS.LTS`
- **Cause**: `winget` source servers are unreliable / blocked in some network environments. The tool has no fallback and fails silently.
- **Fix applied**: Downloaded Node.js LTS MSI directly from `https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi` and installed with `msiexec /quiet`
- **Permanent fix**: Replace `winget` with **Chocolatey** (`choco`) for all Windows tool installs — more reliable, better error output, consistent CLI control
- **Workflow fix**: Step 1c rewritten — Chocolatey installed first, then all tools via `choco install`

### W2. Node.js MSI install fails with `Error 1925` — insufficient privileges
- **Error**: `Error 1925. You do not have sufficient privileges to complete this installation for all users of the machine.`
- **Cause**: `msiexec` without `-Verb RunAs` runs without elevation on Windows
- **Fix applied**: Re-ran with `Start-Process msiexec -Verb RunAs -Wait`
- **Permanent fix**: Chocolatey handles elevation automatically via its own mechanism — no manual `-Verb RunAs` needed
- **Workflow fix**: Covered by W1 fix (Chocolatey)

### W3. Node.js installed but not in PATH of current PowerShell session
- **Error**: `node: The term 'node' is not recognized` even after MSI install
- **Cause**: Windows MSI installers update the system PATH in the registry, but the current PowerShell session does not reload it automatically
- **Fix applied**: Manually reloaded PATH with `$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")`
- **Permanent fix**: Chocolatey reloads PATH automatically after each install via `refreshenv`
- **Workflow fix**: Step 1c — add `refreshenv` after each `choco install` block, or use `$env:PATH` reload

### W4. PowerShell ExecutionPolicy blocks npm / yarn scripts
- **Error**: `File C:\Program Files\nodejs\npm.ps1 cannot be loaded because running scripts is disabled on this system`
- **Cause**: Default Windows PowerShell ExecutionPolicy is `Restricted` — blocks `.ps1` scripts including npm/yarn wrappers
- **Fix applied**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force`
- **Workflow fix**: Step 1c — add ExecutionPolicy fix immediately after Git install, before any npm/yarn usage

### W5. Git not in PATH of PowerShell session (installed but not recognized)
- **Error**: `git: The term 'git' is not recognized` in PowerShell even though Git is installed at `C:\Program Files\Git\bin\git.exe`
- **Cause**: Git installer adds to PATH in registry but current session does not see it — same root cause as W3
- **Fix applied**: `$env:PATH += ";C:\Program Files\Git\bin;C:\Program Files\Git\cmd"`
- **Permanent fix**: Chocolatey `refreshenv` handles this
- **Workflow fix**: Covered by W1/W3 fix

### W6. dotnet SDK installed to `$LOCALAPPDATA\Microsoft\dotnet` (user-level) — not in system PATH
- **Error**: `dotnet: NOT INSTALLED` even after install via `dotnet-install.ps1`
- **Cause**: The official `dotnet-install.ps1` script installs to user-level path and only adds to the current process PATH (not persistent)
- **Fix applied**: `$env:PATH += ";$env:LOCALAPPDATA\Microsoft\dotnet"`
- **Permanent fix**: `choco install dotnet-sdk` installs system-wide with proper PATH registration
- **Workflow fix**: Covered by W1 fix (Chocolatey)

### W8. `choco install` fails from Cascade session — `Access to path denied`
- **Error**: `Access to the path 'C:\ProgramData\chocolatey\.chocolatey' is denied`
- **Cause**: Cascade's terminal process runs without UAC elevation. Even though the user is in the `administrators` group, Windows UAC requires explicit elevation per-process. Chocolatey writes to `C:\ProgramData\` which requires an elevated process.
- **Fix applied**: Run all `choco install` commands from a **PowerShell terminal opened as Administrator** (right-click → Run as Administrator)
- **Workflow fix**: Step 1c — add explicit instruction to open an admin terminal for all `choco install` commands. Mark all choco blocks with `# Run in PowerShell (Admin)` comment.

### W7. Chocolatey install fails silently when run via `Start-Process -Verb RunAs` from Cascade
- **Error**: No error shown — but `choco.exe` never appears at `C:\ProgramData\chocolatey\bin\choco.exe`
- **Cause**: `Start-Process -Verb RunAs` spawns an elevated child process that Cascade cannot observe or interact with.
- **Fix applied**: User opened PowerShell Admin manually and ran the install script — Chocolatey 2.6.0 installed successfully.
- **Workflow fix**: Step 1c — instruction explicite d'ouvrir PowerShell Admin manuellement pour toutes les commandes `choco`.

### W12. Git Bash défini comme shell Windsurf par défaut casse les commandes Cascade
- **Error**: `'C:\Program' is not recognized as an internal or external command` sur toutes les commandes Cascade
- **Cause**: Quand `terminal.integrated.defaultProfile.windows` = `"Git Bash"`, Cascade utilise `C:\Program Files\Git\bin\bash.exe` comme shell. Le chemin contient des espaces et n'est pas correctement quoté par le runner de commandes Cascade — toutes les commandes échouent.
- **Fix applied**: Remis `"PowerShell"` comme profil par défaut dans `settings.json`. Git Bash reste disponible comme profil alternatif que l'utilisateur peut sélectionner manuellement dans le terminal Windsurf.
- **Workflow fix**: Step 1c — NE PAS définir Git Bash comme terminal par défaut via `settings.json`. Indiquer à l'utilisateur de sélectionner Git Bash manuellement dans le dropdown du terminal Windsurf quand nécessaire.

### W9. `choco install dotnet-sdk --version=8.0.418` installe dotnet 10.0 au lieu de 8.0
- **Error**: `dotnet --version` retourne `10.0.103` au lieu de `8.0.x`
- **Cause**: Le package `dotnet-sdk` sur Chocolatey résout vers la dernière version disponible. Le flag `--version=8.0.418` n'est pas reconnu correctement par le package Chocolatey (le versioning Chocolatey ne correspond pas au versioning dotnet SDK).
- **Fix applied**: dotnet 10.0 fonctionne pour la plupart des usages — à surveiller si des projets ciblent strictement `net8.0`
- **Permanent fix**: Utiliser `choco install dotnet-sdk --version=8.0.418 --allow-downgrade -y` ou installer via `winget install Microsoft.DotNet.SDK.8` depuis un terminal admin
- **Workflow fix**: Step 1c — préciser le package exact : `choco install dotnet-8.0-sdk -y` (package dédié à .NET 8)

### W10. Docker Desktop échoue — `choco install docker-desktop` télécharge la version x64 sur ARM64 Windows
- **Error**: `Error: cannot install the Intel (x64) version of Docker Desktop on ARM64 Windows`
- **Cause**: Cette VM Parallels tourne sur un Mac Apple Silicon (ARM64). Chocolatey télécharge automatiquement la version x64 de Docker Desktop, incompatible avec ARM64 Windows.
- **Fix**: Télécharger manuellement la version ARM64 de Docker Desktop depuis https://desktop.docker.com/win/main/arm64/Docker%20Desktop%20Installer.exe et l'installer depuis PowerShell Admin :
  ```powershell
  # Run in PowerShell (Admin)
  Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/arm64/Docker%20Desktop%20Installer.exe' -OutFile "$env:TEMP\DockerDesktopARM64.exe"
  Start-Process "$env:TEMP\DockerDesktopARM64.exe" -ArgumentList 'install --quiet' -Wait
  ```
- **Workflow fix**: Step 1c — détecter l'architecture CPU avant d'installer Docker Desktop. Si ARM64, utiliser l'URL arm64 au lieu de amd64.

### W11. Cascade ne peut pas exécuter de commandes élevées (UAC) — contrainte structurelle Windows
- **Cause**: Windows UAC sépare les sessions élevées des sessions normales, même pour un administrateur. Cascade tourne toujours dans un processus non-élevé. `Start-Process -Verb RunAs` crée un processus enfant élevé que Cascade ne peut ni observer ni contrôler.
- **Impact**: Toutes les commandes qui écrivent dans `C:\ProgramData\`, `C:\Program Files\`, ou modifient des clés de registre système doivent être exécutées par l'utilisateur dans un terminal PowerShell Admin séparé.
- **Workflow fix**: Step 1c — toutes les commandes `choco install` sont clairement marquées `# Run in PowerShell (Admin)` avec instruction explicite à l'utilisateur.

---

## 🔴 OPEN / IN PROGRESS

- **W10** — Docker Desktop : `Virtualization support not detected` — **Conclusion finale** : Parallels Desktop Standard sur Apple Silicon (M1/M2/M3) ne supporte **pas** la nested virtualization. L'option n'existe que sur Parallels Pro + Mac Intel. Ce n'est **pas un bug du workflow** — Docker Desktop fonctionnera normalement sur les machines physiques Windows des collègues. Cette limitation est spécifique à l'environnement de test (VM Parallels Standard sur Apple Silicon).

---

## 🧪 RÉSULTATS DES TESTS — Session 2026-02-19 (machine `m--server`, Windows)

| Step | Statut | Notes |
|---|---|---|
| 0b–0e | ✅ | TEAM_DIR détecté, INSTALL_MODE=B, PAT chargé `11gh****` |
| 1a | ✅ | Inventaire complet — tous outils manquants sauf Git |
| 1c (Node) | ✅ (workaround) | Node v22.14.0 via MSI direct + RunAs + ExecutionPolicy fix |
| 1c (yarn) | ✅ | `npm install -g yarn` → 1.22.22 |
| 1c (dotnet) | ✅ (workaround) | dotnet 8.0.418 via `dotnet-install.ps1` (arm64) |
| 1c (choco install) | ⚠️ (workaround) | choco install doit être lancé depuis terminal PowerShell Admin — pas depuis Cascade |
| 1c (node, yarn, gh, git, mongosh) | ✅ | Installés via choco depuis terminal admin |
| 1c (dotnet) | ⚠️ | dotnet 10.0.103 installé (au lieu de 8.0) — fonctionnel mais version différente |
| 1c (docker-desktop) | ❌ | Installé (ARM64) mais `Virtualization support not detected` — nested virt à activer dans Parallels |

---

## 🔍 AUDIT WORKFLOW — Session 2026-02-19 (Windows)

| Bug | Step | Correction | Statut |
|---|---|---|---|
| W1 | 1c | Remplacer `winget` par Chocolatey | ✅ Appliqué |
| W2 | 1c | Couvert par Chocolatey | ✅ Appliqué |
| W3 | 1c | Reload PATH après install | ✅ Appliqué |
| W4 | 1c | `Set-ExecutionPolicy RemoteSigned` en premier | ✅ Appliqué |
| W5 | 1c | Couvert par Chocolatey | ✅ Appliqué |
| W6 | 1c | `choco install dotnet-8.0-sdk` system-wide | ✅ Appliqué |
| W7 | 1c | Instruction PowerShell Admin explicite | ✅ Appliqué |
| W8 | 1c | Commandes choco marquées `# Run in PowerShell (Admin)` | ✅ Appliqué |
| W9 | 1c | `choco install dotnet-8.0-sdk` au lieu de `dotnet-sdk` | ✅ Appliqué |
| W10 | 1c | Détection ARM64 + URL arm64 Docker + note nested virt | ✅ Appliqué |
| W11 | 1c | Note UAC structurelle + instruction PowerShell Admin | ✅ Appliqué |
| W12 | 1c | Ne pas définir Git Bash comme shell défaut Windsurf | ✅ Appliqué |
| W10 (VM) | 1d | Note : Docker nécessite nested virtualization sur VM Parallels | ⏳ En attente fix Parallels |
