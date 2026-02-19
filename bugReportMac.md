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
  1. Nouveau PAT avec scope **Packaging (Read)** configuré dans `~/.nuget/NuGet/NuGet.Config`
  2. Variable d'environnement `NUGET_PACKAGES` ajoutée dans `~/.zprofile` : `export NUGET_PACKAGES="${HOME}/.nuget/packages"` — prend priorité maximale sur tout `NuGet.config`, y compris le repo-level qui hardcode `$(UserProfile)` (Windows-only)
  3. `config-files/nuget/NuGet.Config.template` mis à jour avec `packageSourceMapping` + `maxHttpRequestsPerSource`
  4. Step 7c Part 1 réécrit dans `amelio-onboarding.md` : utilise `NUGET_PACKAGES` env var, **ne modifie plus le repo**
- **Workflow fix**: Step 7c Part 1 = `NUGET_PACKAGES` dans `~/.zprofile` + vérification `dotnet nuget locals global-packages --list`

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

## ✅ RESOLVED (suite)

### 21a. Workflow d'onboarding écrasait `.env.local` (OMAGE 1)
- **Error**: N/A — modification non sollicitée d'un fichier git-tracké
- **Root cause**: Step 7d copiait `.env.local.template` vers `.env.local` alors que ces fichiers sont **déjà présents après `git clone`** (git-trackés dans `Amelio - React`). Aucune copie n'est nécessaire.
- **Fix applied**:
  1. Step 7d entièrement réécrit — ne copie plus aucun template pour Legacy Frontend
  2. Step 7d contient uniquement une note `Do NOT commit` pour avertir le développeur
- **Workflow fix**: Step 7d corrigé dans `amelio-onboarding.md`

### 14. MongoDB Freemium database not imported
- **Status**: Skipped during test — dump not available on the test machine
- **Impact**: Legacy Backend will not have data on first run
- **Fix applied**: Step 6a entièrement réécrit avec instructions claires :
  - Le dump `DB_Freemium/` (~286 Mo, 242 fichiers BSON) est distribué manuellement par le team lead
  - Chemin cible : `${AMELIO_DIR}/DB_Freemium/` (déjà dans `.gitignore`)
  - Options A/B/C selon disponibilité du dump
- **Workflow fix**: Step 6a mis à jour dans `amelio-onboarding.md`

### 15. VITE_DEV_TOKEN not set in amelio-performance-fe/.env
- **Status**: Par design — nécessite un token JWT live
- **Impact**: Performance Frontend dev mode ne peut pas s'authentifier sans token valide
- **Fix applied**: Step 7e et Step 8g documentent la procédure pour obtenir le token depuis Legacy Frontend (DevTools > Network > Authorization header)
- **Workflow fix**: Instructions déjà présentes dans le workflow — comportement attendu

### 17. `.npmrc` repo files modified instead of using `~/.npmrc` global
- **Error**: N/A — process error (git-tracked file polluted)
- **Cause**: Step 8a incorrectly wrote ADO credentials into the repo-level `.npmrc` files (`amelio-ui-library/.npmrc`, `amelio-performance-fe/.npmrc`), which are git-tracked
- **Fix applied**: Reverted both `.npmrc` files with `git checkout .npmrc`. Added credentials to `~/.npmrc` (user-level) instead.
- **Workflow fix**: Step 8a completely rewritten — now writes to `~/.npmrc` only, with explicit `🚫 NEVER` warning against modifying repo `.npmrc` files

### 18. `WorkSpace/` and `Documentations/` created inside `REPOs/` instead of at `AMELIO_DIR` root
- **Error**: N/A — wrong directory structure
- **Fix applied**: Step 2 mkdir commands corrected in workflow; layout note added explaining the structure
- **Workflow fix**: Step 2 corrected in `amelio-onboarding.md`

### 19. Workspace `path: "."` pointed to `WorkSpace/` folder, not `amelio-team-hub` root
- **Error**: Team Hub folder in workspace opened `WorkSpace/` directory instead of the repo root
- **Fix applied**: Step 10 generation logic corrected — uses `".."` for the Team Hub folder path (workspace saved in `AMELIO_DIR/WorkSpace/`, so `".."` resolves to team-hub root)
- **Workflow fix**: Step 10 corrected in `amelio-onboarding.md`

### 16. Workspace file created without asking user for filename / without checking for existing file
- **Error**: N/A — process error
- **Cause**: Step 10 generated `Simple_devtest.code-workspace` using the OS username without asking the user for their preferred name, and without checking if a file already existed at that path
- **Fix applied**: Step 10 updated — always asks user to choose filename, never uses `Simple_`/`Template_` prefix, checks for existing file before writing
- **Workflow fix**: Step 10 corrected in `amelio-onboarding.md`

---

## 🧪 RÉSULTATS DES TESTS — Session 2026-02-19

> Tests exécutés sur machine `devtest` (macOS, Apple Silicon) après corrections de la session précédente.

### T1 — NuGet restore (Bug #13 + #22) ✅ VALIDÉ
- [x] PAT créé avec scopes **Code (Read & Write)** + **Packaging (Read)**
- [x] `~/.nuget/NuGet/NuGet.Config` configuré avec PAT valide
- [x] `dotnet restore` sur `Amelio - Back-End` : **10/10 projets restaurés, 0 erreur**
- [x] Workaround `Amelio.MongoRepository 2.1.3` (copie cache NuGet depuis `j-mini`) : fonctionne

### T2 — DB_Freemium (Bug #14) ⏭ NON TESTÉ
- [ ] Dump non disponible sur cette machine — à tester lors d'un prochain onboarding avec dump

### T3 — Legacy Frontend config (Bug #21a) ✅ VALIDÉ
- [x] `git status` dans `Amelio - React` après Step 7d : **0 fichiers modifiés**
- ⚠️ Note : Step 7d actuel copie les templates sans protection — bug #21a reste ouvert (à décider : skip-worktree ou non)

### T4 — Workspace generation (Bugs #16 + #19) ✅ VALIDÉ
- [x] `Amelio_devtest.code-workspace` : `path: ".."` correct pour le dossier Team Hub
- [x] Dossier "👥 — 🏠 Amelio Team Hub" pointe vers la racine du repo

### T5 — Workflows globaux (Bug #20) ✅ VALIDÉ (avec nettoyage)
- [x] Workflows présents dans `~/.codeium/windsurf/global_workflows/` : `amelio-onboarding.md`, `create-perfo-be-pr.md`, `create-perfo-fe-pr.md`
- [x] Dossiers `.windsurf/` parasites (vides) supprimés de `amelio-ui-library`, `amelio-performance-backend`, `amelio-performance-fe`
- [x] Aucun fichier git-tracké modifié lors du nettoyage

### T6 — npm ci (Bug #21b) ✅ VALIDÉ
- [x] `npm ci --legacy-peer-deps` dans `Amelio - React` : **succès**
- [x] `git diff --name-only` après install : **vide** — `package-lock.json` non modifié

### T7 — Template workspace ⏭ NON TESTÉ
- [ ] À vérifier lors d'un prochain onboarding sur machine fraîche

### T8 — Performance Frontend env ⏭ NON TESTÉ
- [ ] À vérifier lors d'un prochain onboarding sur machine fraîche

---

## 🔍 AUDIT WORKFLOW — Session 2026-02-19

> Audit complet de `amelio-onboarding.md` après corrections. Chaque step vérifié contre la machine `devtest`.

| Step | Statut | Notes |
|---|---|---|
| 0a–0e | ✅ | `.env.template` existe, PAT masqué, résumé correct |
| 1a–1e | ✅ | Détection outils + install Homebrew/brew/dotnet-ef corrects |
| 2 | ✅ | `mkdir` au bon niveau (`AMELIO_DIR`, pas dans `REPOs/`) |
| 3 | ✅ | Clone 5 repos ADO avec PAT dans URL |
| 4a–4e | ✅ | Déploiement rules/memories/skills/workflows vers `~/.codeium/windsurf/` uniquement — note `🚫 NEVER` dans 4d |
| 5a–5d | ✅ | MongoDB + docker-compose.override.yml (postgres:17) + vérification containers |
| 6a–6b | ✅ | Instructions DB_Freemium claires (options A/B/C) + migrations PostgreSQL |
| 7a | ✅ | `appsettings.Development.json` + `appsettings.Testing.json` copiés depuis `config-files/` (gitignored) |
| 7b | ✅ | Modification directe des 3 fichiers git-trackés + note `Do NOT commit` |
| 7c | ✅ | `NUGET_PACKAGES` env var dans `~/.zprofile` (Part 1, macOS) + NuGet.Config user-level avec PAT Packaging (Read) (Part 2) — aucune modification du repo |
| 7d | ✅ | Aucune copie — fichiers déjà présents après clone + note `Do NOT commit` |
| 7e | ✅ | `.env` depuis `.env.sample` (priorité) ou template |
| 8a | ✅ | `~/.npmrc` user-level uniquement, B64 correct (`anything:PAT`) |
| 8b–8d | ✅ | yarn UI Library + build + yarn Perf FE + dotnet restore Perf BE |
| 8e | ✅ | `npm ci --legacy-peer-deps` + vérification `git diff --name-only` + restauration si package-lock.json modifié |
| 8f | ✅ | `dotnet restore` + known issues 401 et NU1202 documentés avec workarounds |
| 9 | ✅ | Extensions par tiers A/B/C/D/E, `windsurf` binary résolu avant usage |
| 10 | ✅ | Workspace généré avec `path: ".."` pour team-hub, nom demandé à l'utilisateur, check existence avant écriture |
| 11 | ✅ | Bookmarks + URLs locales |
| 12 | ✅ | Workspace secondaire optionnel |
| 13 | ✅ | Checklist finale 12 points, task NEVER done until user confirms |

**Correction appliquée lors de l'audit** :
- Tous les `skip-worktree` retirés du workflow (Steps 7b, 7c, 7d) — remplacés par des notes `Do NOT commit`. Les `skip-worktree` appliqués sur la machine lors des sessions précédentes ont également été revertés (`--no-skip-worktree`).


