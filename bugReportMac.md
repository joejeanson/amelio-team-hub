# Amelio Onboarding — Bug Report

> Generated during onboarding session: 2026-02-18
> Machine: macOS Darwin, user: devtest

---

## ✅ RESOLVED

### 1. Homebrew not in PATH after install (Apple Silicon)
- **Error**: `brew: command not found` after install
- **Cause**: Homebrew installs to `/opt/homebrew` on Apple Silicon but does not auto-add to PATH
- **Fix**: Run `eval "$(/opt/homebrew/bin/brew shellenv zsh)"` and add to `~/.zprofile`
- **Workflow fix**: Added Step 1b Step 2 to add Homebrew to PATH

### 2. yarn symlink conflict after brew install
- **Error**: `brew link --overwrite yarn` required after `brew install yarn`
- **Cause**: An older yarn binary already existed at `/opt/homebrew/bin/yarn`
- **Fix**: `brew link --overwrite yarn`
- **Workflow fix**: Added note in Step 1b

### 3. dotnet-ef not installed
- **Error**: `dotnet-ef: command not found` when running `npm run update-database`
- **Cause**: `dotnet-ef` is a global tool that must be installed separately
- **Fix**: `dotnet tool install --global dotnet-ef`
- **Workflow fix**: Added Step 1b Step 5

### 4. dotnet tools not in PATH
- **Error**: `dotnet-ef` not found even after install
- **Cause**: `~/.dotnet/tools` not in PATH
- **Fix**: `export PATH="$PATH:/Users/devtest/.dotnet/tools"`
- **Workflow fix**: Added Step 1b Step 4

### 5. postgres:18 volume mount incompatibility
- **Error**: `dev_db` container exits immediately with volume path error
- **Cause**: `postgres:18` expects `/var/lib/postgresql` (not `/var/lib/postgresql/data`)
- **Fix**: Created `docker-compose.override.yml` pinning `dev_db` to `postgres:17`
- **File**: `amelio-performance-backend/docker-compose.override.yml` (in .gitignore)
- **Workflow fix**: Added Step 5b with override file creation instructions

### 6. npm auth B64 format incorrect
- **Error**: `401 Unauthorized` on ADO npm registry
- **Cause**: `_password` in `.npmrc` must be `base64("username:PAT")` — NOT `base64(":PAT")`
- **Fix**: `B64=$(echo -n "anything:${ADO_PAT}" | base64)`
- **Workflow fix**: Updated Step 8a with correct B64 formula and critical note

### 7. yarn cannot resolve @amelio/ui-library from ADO feed
- **Error**: `Couldn't find package "@amelio/ui-library" on the "npm" registry`
- **Cause**: Yarn 1.x does not properly use scoped registry from `.npmrc` for ADO feeds
- **Fix**: Used `npm link` to link the locally built `amelio-ui-library` repo
- **Workflow fix**: Added Option 2 fallback in Step 8c

### 8. git commit fails — no identity configured
- **Error**: `Author identity unknown — fatal: no email was given`
- **Fix**: `git config --global user.name "Jonathan Jeanson"` + `git config --global user.email "joejeanson@live.ca"`
- **Workflow fix**: Added Step 1b Step 6

### 9. dotnet restore fails before appsettings.Development.json exists
- **Error**: `ConnectionString property has not been initialized` during `npm run update-database`
- **Cause**: Migrations ran before Step 7a (config files deployment)
- **Fix**: Always run Step 7 (config deployment) before Step 6b (migrations)
- **Workflow note**: Step ordering is correct — do not run migrations before configs

### 10. `brew install --cask docker` fails when Docker Desktop already installed
- **Error**: `Error: It seems there is already an App at '/Applications/Docker.app'`
- **Cause**: Docker Desktop was already installed; brew tried to reinstall it
- **Fix**: Detected existing install, ran `open /Applications/Docker.app` directly instead
- **Workflow fix**: Step 1d now asks user to choose between already running / auto-install / CLI-only

### 11. `windsurf` command not found in PATH
- **Error**: `zsh: command not found: windsurf` when running `windsurf --install-extension`
- **Cause**: Windsurf IDE does not automatically add its CLI binary to the shell PATH on macOS
- **Binary location**: `/Applications/Windsurf.app/Contents/Resources/app/bin/windsurf`
- **Fix**: Used full path: `WINDSURF=$(which windsurf 2>/dev/null || echo "/Applications/Windsurf.app/Contents/Resources/app/bin/windsurf")`
- **Workflow fix**: Added PATH resolution note and updated all install loops in Step 9

### 12. PAT pasted directly in chat instead of using .env file
- **Error**: N/A — security concern
- **Cause**: The workflow Step 0d instructs to use a `.env` file, but the user pasted the PAT directly in chat
- **Impact**: PAT is visible in chat history — should be rotated after onboarding
- **Resolution**: After onboarding, rotate the PAT at https://dev.azure.com/ameliodev/_usersSettings/tokens
- **Workflow note**: Step 0d already warns against this — ensure future users follow the `.env` approach

### 13. Legacy Backend dotnet restore — 401 Unauthorized on NuGet feed
- **Error**: `NU1301: Response status code does not indicate success: 401 (Unauthorized)`
- **Feed**: `https://pkgs.dev.azure.com/ameliodev/_packaging/Amelio.MongoRepository/nuget/v3/index.json`
- **Root cause (initial)**: PAT missing **Packaging (Read)** scope
- **Root cause (workspace reload — `nuget-restore-error-after-open-new-workspace.log`)**: The user-level `~/.nuget/NuGet/NuGet.Config` was missing the `<packageSourceMapping>` section. Without it, NuGet cannot correctly route `Amelio.*` / `OPIA.*` packages to the private ADO feed when workspace inputs change — even with valid credentials. The repo-level `NuGet.config` has the mapping but the user-level config overrides/conflicts with it.
- **Impact**: `dotnet restore` fails for: `OPIA.API.V2`, `OPIA.Business.V2`, `OPIA.Repository.V2`, `OPIA.Scheduler.V2`, `OPIA.Web.V2`, `OPIA.Uitlity.V2`, `DatabaseMigrator.V2`, `Tests/OPIA.API.V2.Tests`
- **Full error logs**: `nuget-restore-error.log` (initial) and `nuget-restore-error-after-open-new-workspace.log` (workspace reload)
- **Fix applied**:
  1. Added `<packageSourceMapping>` + `maxHttpRequestsPerSource` to `~/.nuget/NuGet/NuGet.Config` on this machine
  2. Updated `config-files/nuget/NuGet.Config.template` with the same additions
  3. Updated Step 7c in `amelio-onboarding.md` with explicit instructions and verification step
- **Workflow fix**: Step 7c now includes `packageSourceMapping` in template and a `cat` verification command

### 20. Workflows déployés dans les repos au lieu des globales Windsurf
- **Error**: N/A — erreur d'architecture
- **Cause**: Une ancienne version du workflow d'onboarding déployait les fichiers `.windsurf/workflows/` directement dans les repos ADO au lieu du chemin global Windsurf
- **Chemin global correct (macOS)**: `~/.codeium/windsurf/global_workflows/`
- **Fix applied**:
  1. Les workflows sont déjà correctement présents dans `~/.codeium/windsurf/global_workflows/` (`amelio-onboarding.md`, `create-perfo-be-pr.md`, `create-perfo-fe-pr.md`)
  2. Aucun `.windsurf/` parasite trouvé dans les repos ADO (déjà nettoyé)
  3. Ajout d'une note `🚫 NEVER` explicite dans Step 4d du workflow d'onboarding pour prévenir toute future régression
- **Workflow fix**: Step 4d contient maintenant un avertissement explicite interdisant le déploiement dans les repos

### 21b. Workflow d'onboarding a modifié `package-lock.json` (OMAGE 2)
- **Error**: N/A — modification non sollicitée d'un fichier git-tracké
- **Root cause**: Step 8e utilisait `npm install` au lieu de `npm ci`, ce qui modifie `package-lock.json` (fichier git-tracké)
- **Fix applied**:
  - Step 8e — note `🚫 NEVER run npm install` ajoutée + commande de vérification `git diff --name-only` après install + commande de restauration si `package-lock.json` apparaît
- **Workflow fix**: Step 8e corrigé dans `amelio-onboarding.md`

### 22. `Amelio.MongoRepository 2.1.3` retiré du feed ADO — seul `3.2.3785` (net10.0) disponible
- **Error**: `NU1202: Le package Amelio.MongoRepository 3.2.3785 n'est pas compatible avec net8.0`
- **Feed**: `https://pkgs.dev.azure.com/ameliodev/_packaging/Amelio.MongoRepository/nuget/v3/index.json`
- **Cause**: Le feed ADO ne contient plus que la version `3.2.3785` qui cible `net10.0`. Les projets Legacy Backend demandent `2.1.3` (net8.0) qui n'est plus publiée sur le feed
- **Versions disponibles sur le feed**: `["3.2.3785"]` — `2.1.3` absente
- **Fix applied (workaround)**: Le `.nupkg` `2.1.3` était présent dans le cache NuGet de l'utilisateur `j-mini` sur la même machine. Copié vers le cache `devtest` :
  ```bash
  mkdir -p ~/.nuget/packages/amelio.mongorepository/2.1.3
  cp -R /Users/j-mini/.nuget/packages/amelio.mongorepository/2.1.3/* ~/.nuget/packages/amelio.mongorepository/2.1.3/
  ```
- **Résultat**: `dotnet restore` réussit — NuGet utilise le cache local `2.1.3` au lieu de télécharger `3.2.3785` du feed
- **Workaround pour nouveaux devs**: Copier le dossier `~/.nuget/packages/amelio.mongorepository/2.1.3/` depuis une machine existante (ex: `j-mini`) vers la nouvelle machine
- **À investiguer (long terme)**:
  - La version `2.1.3` a-t-elle été intentionnellement retirée du feed ?
  - Faut-il republier `2.1.3` sur le feed pour que les nouveaux devs puissent restore sans workaround ?
  - Ou migrer les projets Legacy Backend vers `net10.0` + `3.2.3785` ?
- **Workflow fix**: Ajouter une étape dans Step 8f pour détecter et appliquer ce workaround si nécessaire

---

## ❌ UNRESOLVED

### 21a. Workflow d'onboarding écrase `.env.local` sans protection git (OMAGE 1)
- **Error**: N/A — modification non sollicitée d'un fichier git-tracké
- **Root cause**: Step 7d copie `.env.local.template` vers `.env.local` sans vérifier si le fichier existe déjà et sans protéger le fichier avec `skip-worktree`. Si `.env.local` contient déjà des secrets/configs locales (ex: tokens), ils sont silencieusement écrasés. De plus, toute modification ultérieure de `.env.local` apparaît comme un diff git-tracké risquant d'être committé accidentellement.
- **Impact**: Perte de configs locales existantes + risque de commit accidentel de secrets
- **À investiguer**:
  - Faut-il ajouter une copie conditionnelle (`[ ! -f ]`) dans Step 7d ?
  - Faut-il appliquer `git update-index --skip-worktree .env.local` après la copie ?
  - Ou faut-il ajouter `.env.local` au `.gitignore` du repo `Amelio - React` ?
- **Workaround actuel**: Vérifier manuellement `git status` après Step 7d et appliquer `git update-index --skip-worktree .env.local` si nécessaire

### 14. MongoDB Freemium database not imported
- **Status**: Skipped — dump not available on this machine
- **Impact**: Legacy Backend will not have data on first run
- **Resolution**: Obtain the `DB_Freemium/Freemium/` dump folder and run:
  ```bash
  mongorestore --host localhost:27017 \
    --username ameliodb --password ameliodb \
    --authenticationDatabase admin \
    --db Freemium \
    "<PATH_TO_DB_FREEMIUM>/Freemium/"
  ```
- **Note**: The dump should be made available in `amelio-team-hub` or shared via a secure channel

### 15. VITE_DEV_TOKEN not set in amelio-performance-fe/.env
- **Status**: Placeholder only — requires a live JWT token
- **Impact**: Performance Frontend dev mode will not authenticate against Legacy Backend
- **Resolution**: Start Legacy Frontend (http://localhost:3011), log in, open DevTools > Network, copy the Bearer token from any API request header, paste into `.env` as `VITE_DEV_TOKEN`

### 17. `.npmrc` repo files modified instead of using `~/.npmrc` global
- **Error**: N/A — process error (git-tracked file polluted)
- **Cause**: Step 8a incorrectly wrote ADO credentials into the repo-level `.npmrc` files (`amelio-ui-library/.npmrc`, `amelio-performance-fe/.npmrc`), which are git-tracked
- **Why it worked in another environment**: npm/yarn automatically merges `~/.npmrc` (user-level) with the project `.npmrc`. The other environment likely had credentials already in `~/.npmrc` from a previous setup (e.g. `vsts-npm-auth` on Windows, or a prior manual setup). The repo `.npmrc` only needs to declare the registry URL — credentials must never be added there.
- **Fix applied**: Reverted both `.npmrc` files with `git checkout .npmrc`. Added credentials to `~/.npmrc` (user-level) instead.
- **Workflow fix**: Step 8a completely rewritten — now writes to `~/.npmrc` only, with explicit warning never to modify repo `.npmrc` files

### 18. `WorkSpace/` and `Documentations/` created inside `REPOs/` instead of at `AMELIO_DIR` root
- **Error**: N/A — wrong directory structure
- **Cause**: Step 2 mkdir commands placed `WorkSpace/` and `Documentations/` inside `REPOs/`, but they should be at the root of `AMELIO_DIR` alongside `windsurf/`, `config-files/`, etc.
- **Fix applied**: Moved both directories: `mv REPOs/WorkSpace WorkSpace` and `mv REPOs/Documentations Documentations`
- **Workspace fix**: Updated `Amelio_devtest.code-workspace` Documentations path from `REPOs/Documentations` to `Documentations`
- **Workflow fix**: Step 2 mkdir commands corrected; added layout note explaining the structure

### 19. Workspace `path: "."` pointed to `WorkSpace/` folder, not `amelio-team-hub` root
- **Error**: Team Hub folder in workspace opened `WorkSpace/` directory instead of the repo root
- **Cause**: The workspace file was initially saved in `REPOs/WorkSpace/` and used `path: "."` which resolved to that folder. After moving to `amelio-team-hub/WorkSpace/`, the correct relative path is `".."` (one level up).
- **Fix applied**: Changed `"path": "."` to `"path": ".."` — workspace is in `amelio-team-hub/WorkSpace/`, so `".."` correctly points to `amelio-team-hub/` root ✅
- **Workflow fix**: Step 10 generation logic must use `".."` for the Team Hub folder path when workspace is saved in `AMELIO_DIR/WorkSpace/`

### 16. Workspace file created without asking user for filename / without checking for existing file
- **Error**: N/A — process error
- **Cause**: Step 10 generated `Simple_devtest.code-workspace` using the OS username without asking the user for their preferred name, and without checking if a file already existed at that path
- **Bad naming**: The prefix `Simple_` comes from the template filename and is not appropriate for personal workspace files
- **Impact**: Could silently overwrite a previously customized workspace file
- **Fix applied**: File renamed to `Amelio_devtest.code-workspace`. Workflow Step 10 updated to:
  1. Always ask the user to choose a filename with meaningful options (`Amelio_username`, `Amelio_FirstLastName`, etc.)
  2. Never use `Simple_` as a prefix for personal workspace files
  3. Check for existing file before writing — error if file already exists
- **Workflow fix**: Step 10 now includes filename selection question, naming convention note, and existence check


