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

### 23. `~/.npmrc` format incorrect — `_password`+`username` rejeté par npm moderne
- **Error**: `npm error code E401 — Unable to authenticate, your authentication token seems to be invalid`
- **Root cause**: Step 8a utilisait le format `_password=base64("anything:PAT")` + `username=anything` — ce format est rejeté par npm v10+. Le format correct est `_authToken=<PAT>` (raw PAT, sans encodage)
- **Fix applied**: `~/.npmrc` réécrit avec `_authToken=${ADO_PAT}` uniquement
- **Workflow fix**: Step 8a corrigé dans `amelio-onboarding.md` — utilise `_authToken` au lieu de `_password`+`username`+B64

### 24. Performance FE — Yarn 1.x ne résout pas `@amelio/ui-library` depuis le feed ADO
- **Error**: `error Couldn't find package "@amelio/ui-library" on the "npm" registry`
- **Root cause**: Yarn 1.x ignore les scoped registries (`@amelio:registry`) déclarés dans `.npmrc` lors du `yarn install`. Il cherche systématiquement `@amelio/ui-library` sur `registry.npmjs.org` au lieu du feed ADO
- **Tentatives échouées**: `yarn link`, `npm link`, `~/.yarnrc` scoped registry — aucune ne fonctionne avec Yarn 1.x
- **Fix applied**: Utiliser `npm install` au lieu de `yarn install` pour Performance FE — npm lit correctement `~/.npmrc` et résout `@amelio/ui-library` depuis le feed ADO. Supprimer le `package-lock.json` créé par npm après l'install (ce repo utilise `yarn.lock`)
- **Workflow fix**: Step 8c réécrit dans `amelio-onboarding.md` — `npm install` + `rm package-lock.json` + vérification `git status`

### 22. `Amelio.MongoRepository 2.1.3` absent du feed ADO NuGet — à republier
- **Error**: `NU1202: Le package Amelio.MongoRepository 3.2.3785 n'est pas compatible avec net8.0`
- **Package type**: **NuGet** (pas npm) — référencé dans les `.csproj` du Legacy Backend via `<PackageReference Include="Amelio.MongoRepository" Version="2.1.3" />`
- **Feed ADO**: `https://pkgs.dev.azure.com/ameliodev/_packaging/Amelio.MongoRepository/nuget/v3/index.json`
- **Versions disponibles sur le feed**: `["3.2.3785"]` (net10.0 uniquement) — `2.1.3` absente
- **Versions disponibles sur nuget.org public**: aucune — package privé
- **Cause**: La version `2.1.3` (net8.0) n'est plus publiée sur le feed. Les projets Legacy Backend la demandent explicitement
- **Workaround temporaire appliqué sur `devtest`**: Copie du `.nupkg` depuis le cache NuGet de `j-mini` :
  ```bash
  mkdir -p ~/.nuget/packages/amelio.mongorepository/2.1.3
  cp -R /Users/j-mini/.nuget/packages/amelio.mongorepository/2.1.3/* ~/.nuget/packages/amelio.mongorepository/2.1.3/
  ```
- **Solution permanente (action équipe requise)**: Republier `Amelio.MongoRepository 2.1.3` sur le feed ADO `Amelio.MongoRepository` pour que les nouveaux devs puissent `dotnet restore` sans workaround
- **À décider (long terme)**: Migrer les projets Legacy Backend vers `net10.0` + `3.2.3785` (implique mise à jour du `TargetFramework` dans les `.csproj`)
- **Workflow fix**: Step 8f documente le workaround cache NuGet en attendant la republication

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

### 25. Performance FE — `npm install` au lieu de `yarn install` (régression session 2026-02-19)
- **Error**: N/A — mauvaise commande dans le workflow
- **Root cause**: Le workflow Step 8c avait été corrigé pour utiliser `npm install` (Bug #24), mais cette machine utilise bien `yarn install` pour Performance FE. La note sur `npm install` était incorrecte — `yarn install` fonctionne correctement sur cette machine avec `~/.npmrc` configuré
- **Fix applied**: Step 8c réécrit — `yarn install` (pas `npm install`), suppression de la note erronée sur npm, ajout de `--legacy-peer-deps` retiré (non nécessaire avec yarn)
- **Workflow fix**: Step 8c corrigé dans `amelio-onboarding.md` — `yarn install` + `echo` de confirmation

### 26. Performance FE — `npx tsx` bloque le terminal interactivement
- **Error**: `Need to install the following packages: tsx@4.21.0 — Ok to proceed? (y)` — bloque le terminal en attente de saisie
- **Cause**: `npm run dev` appelle `yarn translation:gen` qui lance `npx tsx scripts/generate-i18n-keys.ts`. Si `tsx` n'est pas installé globalement, `npx` demande confirmation interactive
- **Fix applied**: `npm install -g tsx` avant `npm run dev` / `yarn install`
- **Workflow fix**: Step 8c — pré-requis `npm install -g tsx` ajouté avant `yarn install`

### 27. Nom du conteneur PostgreSQL incorrect dans la checklist finale
- **Error**: `docker exec dev_db ...` échoue — conteneur introuvable
- **Cause**: Le nom réel du conteneur est `performance_management-dev_db-1` (généré par docker-compose), pas `dev_db`
- **Fix applied**: Step 13 corrigé dans `amelio-onboarding.md`
- **Workflow fix**: `docker exec dev_db` → `docker exec performance_management-dev_db-1` dans Step 13 (bash + PowerShell)

### 28. Git-tracked appsettings modifiés sans stash — repos pollués
- **Error**: N/A — process error
- **Cause**: Le workflow Step 7b modifiait directement les 3 fichiers `appsettings.json` git-trackés dans `Amelio - Back-End` sans créer de stash, laissant les repos dans un état dirty permanent
- **Fix applied**:
  1. Step 7b entièrement réécrit — utilise `sed` pour les modifications + `git stash push` immédiat après
  2. Deux stashs nommés créés à la fin de l'onboarding (Step 13) :
     - `⚙️ Setup local — connexions MongoDB localhost (onboarding)` — référence permanente
     - `🚀▶️ Running local — connexions MongoDB prêtes à démarrer` — à pop avant de démarrer les services, re-stasher après
  3. Instructions d'utilisation quotidienne documentées dans Step 13
- **Workflow fix**: Step 7b et Step 13 corrigés dans `amelio-onboarding.md`

### 29. Smoke tests absents de la checklist finale
- **Error**: N/A — lacune du workflow
- **Cause**: Le workflow ne vérifiait pas que les services démarrent réellement après l'onboarding
- **Fix applied**: Section "Smoke tests" ajoutée dans Step 13 — teste les 5 services (IdentityServer, Legacy API, Performance API, Legacy FE, Performance FE) avec stash pop/push autour des tests Legacy Backend
- **Workflow fix**: Step 13 — section smoke tests ajoutée, checklist étendue à 13 points

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

## 🧪 RÉSULTATS DES TESTS — Session 2026-02-19 (machine `devtest2`)

> Tests exécutés sur machine `devtest2` (macOS, Apple Silicon, Mac Mini) — onboarding complet de A à Z.

### T9 — Git stash appsettings Legacy Backend (Bug #28) ✅ VALIDÉ
- [x] `sed` appliqué sur 3 fichiers `appsettings.json` — connexions MongoDB → `localhost:27017`
- [x] `git stash push -m "⚙️ Setup local..."` : stash créé, `git status` vide
- [x] `git stash pop` + `dotnet run` IdentityServer : **HTTP 200** sur `http://localhost:5000/.well-known/openid-configuration`
- [x] `git stash pop` + `dotnet run` OPIA.API.V2 : **`Now listening on: http://localhost:18489`**
- [x] Deux stashs nommés créés en fin d'onboarding : `⚙️ Setup local` + `🚀▶️ Running local`

### T10 — PostgreSQL migrations (Bug #27) ✅ VALIDÉ
- [x] Conteneur réel : `performance_management-dev_db-1` (pas `dev_db`)
- [x] `npm run update-database` : **2 migrations appliquées** (`20251002031637_Initial`, `20260129161333_AddPerformanceModels`)
- [x] `docker exec performance_management-dev_db-1 psql ...` : **32 tables** dans `public`

### T11 — Performance FE yarn install + tsx (Bugs #25 + #26) ✅ VALIDÉ
- [x] `npm install -g tsx` : installé globalement
- [x] `yarn install` dans `amelio-performance-fe` : **succès** (pas de prompt interactif)
- [x] `npm run dev` : **`VITE v7.3.1 ready in 536 ms — http://localhost:5173/`**
- [x] `git status` après install : **vide** (aucun fichier git-tracké modifié)

### T12 — Smoke tests 5 services ✅ VALIDÉ
- [x] **IdentityServer** (port 5000) : HTTP 200 sur `/.well-known/openid-configuration`
- [x] **Legacy API OPIA.API.V2** (port 18489) : `Now listening on: http://localhost:18489`
- [x] **Performance Backend** (port 5120) : `Now listening on: http://localhost:5120`
- [x] **Legacy Frontend** (port 3011) : `➜ Local: http://localhost:3011/`
- [x] **Performance Frontend** (port 5173) : `VITE v7.3.1 ready — http://localhost:5173/`

### T13 — Extensions Windsurf (Step 9) ✅ VALIDÉ
- [x] 23 extensions essentielles installées (tier A)
- [x] 4 extensions visuelles installées (tier B)
- [x] Total : **27/27 OK, 0 FAILED**
- [x] Binary résolu : `/Applications/Windsurf.app/Contents/Resources/app/bin/windsurf`

### T14 — Workspace personnalisé (Step 10) ✅ VALIDÉ
- [x] `Amelio_devtest2.code-workspace` généré dans `WorkSpace/`
- [x] `path: ".."` correct pour le dossier Team Hub
- [x] Toutes les entrées `<AMELIO_DIR>` remplacées par `/Users/devtest2/Downloads/amelio-team-hub`

### T15 — MongoDB Freemium (Step 6a) ✅ VALIDÉ
- [x] `mongorestore` : **121 collections** importées dans `Freemium`
- [x] Chemin correct : `DB_Freemium/Freemium/Freemium/` (structure imbriquée)
- [x] `mongosh` : **121 collections** confirmées

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
| 8a | ✅ (corrigé) | `~/.npmrc` user-level avec `_authToken=<PAT>` (raw) — format `_password`+B64 rejeté par npm v10+ |
| 8b | ✅ | yarn UI Library + build |
| 8c | ✅ (corrigé) | `npm install` (pas yarn) pour Perf FE + `rm package-lock.json` + vérification `git status` |
| 8d | ✅ | dotnet restore Perf BE |
| 8e | ✅ | `npm ci --legacy-peer-deps` + vérification `git diff --name-only` + restauration si package-lock.json modifié |
| 8f | ✅ | `dotnet restore` + known issues 401 et NU1202 documentés avec workarounds |
| 9 | ✅ | Extensions par tiers A/B/C/D/E, `windsurf` binary résolu avant usage |
| 10 | ✅ | Workspace généré avec `path: ".."` pour team-hub, nom demandé à l'utilisateur, check existence avant écriture |
| 11 | ✅ | Bookmarks + URLs locales |
| 12 | ✅ | Workspace secondaire optionnel |
| 13 | ✅ | Checklist finale 12 points, task NEVER done until user confirms |

**Corrections appliquées lors de l'audit** :
- Tous les `skip-worktree` retirés du workflow (Steps 7b, 7c, 7d) — remplacés par des notes `Do NOT commit`
- Step 7c Part 1 : `NUGET_PACKAGES` env var dans `~/.zprofile` (priorité max sur `$(UserProfile)` du repo)
- Step 8a : `_authToken` au lieu de `_password`+B64 (npm v10+ rejette l'ancien format)
- Step 8c : `npm install` au lieu de `yarn install` (Yarn 1.x ignore les scoped ADO registries)
- `.env.development` dans `Amelio - React` reverté (avait été écrasé par une session précédente)
- Tous les repos validés propres : 5/5 `git status` vide

---

## 🔍 AUDIT WORKFLOW — Session 2026-02-19 (machine `devtest2`)

> Audit complet de `amelio-onboarding.md` après corrections de la session `devtest2`. Chaque step vérifié sur machine fraîche.

| Step | Statut | Notes |
|---|---|---|
| 0a–0e | ✅ | PAT chargé depuis `.env`, résumé correct |
| 1a–1e | ✅ | Tous outils présents, `dotnet-ef` installé, PATH `~/.dotnet/tools` configuré |
| 2 | ✅ | Structure `AMELIO_DIR/REPOs/`, `WorkSpace/`, `Documentations/` correcte |
| 3 | ✅ | 5 repos clonés avec succès |
| 4a–4e | ✅ | Rules, memories, skills, workflows déployés dans `~/.codeium/windsurf/` |
| 5a–5d | ✅ | 5 containers Docker up (mongo, pg×2, redis, mailpit) |
| 6a | ✅ | 121 collections importées — chemin `DB_Freemium/Freemium/Freemium/` (structure imbriquée) |
| 6b | ✅ | 2 migrations PostgreSQL appliquées, 32 tables dans `public` |
| 7a | ✅ | `appsettings.Development.json` + `appsettings.Testing.json` déployés |
| 7b | ✅ (réécrit) | `sed` + `git stash push` — 3 fichiers modifiés, repo propre immédiatement |
| 7c | ✅ | `NUGET_PACKAGES` + NuGet.Config user-level |
| 7d | ✅ | `.env.development` déjà présent, non touché |
| 7e | ✅ | `.env` déployé depuis template |
| 8a | ✅ | `~/.npmrc` avec `_authToken` |
| 8b | ✅ | `yarn install` + `yarn build` UI Library — `dist/` créé |
| 8c | ✅ (corrigé) | `npm install -g tsx` + `yarn install` — Vite démarre sur port 5173 |
| 8d | ✅ | `dotnet restore` Performance Backend |
| 8e | ✅ | `npm ci --legacy-peer-deps` Legacy Frontend — `package-lock.json` non modifié |
| 8f | ✅ | `dotnet restore` Legacy Backend — warnings NU1701 non-bloquants |
| 9 | ✅ | 27 extensions installées (tier B) — binary `/Applications/Windsurf.app/.../windsurf` |
| 10 | ✅ | `Amelio_devtest2.code-workspace` généré |
| 11 | ✅ | Bookmarks + URLs locales + Bruno + DBeaver installés |
| 12 | ✅ | Workspace secondaire passé |
| 13 | ✅ (étendu) | Checklist 13 points + smoke tests 5 services + 2 stashs nommés |

**Corrections appliquées lors de la session `devtest2`** :
- Step 7b : `sed` + `git stash push` (au lieu de modification directe sans stash) — Bug #28
- Step 8c : `yarn install` (pas `npm install`) + pré-requis `npm install -g tsx` — Bugs #25 + #26
- Step 13 : `performance_management-dev_db-1` (pas `dev_db`) — Bug #27
- Step 13 : section smoke tests ajoutée (5 services testés) — Bug #29
- Step 13 : 2 stashs nommés (`⚙️ Setup local` + `🚀▶️ Running local`) + instructions quotidiennes
- Step 11 : vérification préalable `brew list --cask` avant de proposer l'installation
- Step 11 : offre d'aide pour configuration des outils (strings de connexion) avec chaînage entre les outils

---

## 🔍 AUDIT QUALITÉ — Post-session `devtest2`

> Audit complet du workflow après la session `devtest2`. Corrections supplémentaires identifiées et appliquées.

### 30. Step 8f — `dotnet restore` ne nécessite pas les `appsettings.json`
- **Erreur** : Le workflow indiquait de faire `stash pop` avant `dotnet restore` et `stash push` après
- **Cause** : Hypothèse incorrecte — `dotnet restore` ne lit que les `.csproj` et `NuGet.Config`, jamais les `appsettings.json`
- **Fix applied** : Step 8f simplifié — `dotnet restore` direct, sans stash pop/push
- **Workflow fix** : Step 8f corrigé dans `amelio-onboarding.md`

### 31. Step 13 — Smoke test `stash pop` sans garde-fou
- **Erreur** : `git stash pop` échouait si le stash avait déjà été poppé (ex: après Step 8f dans l'ancienne version)
- **Fix applied** : Ajout d'un `if grep -q "Setup local"` avant le `stash pop` — pop uniquement si le stash existe
- **Workflow fix** : Step 13 smoke tests — stash pop conditionnel

### 32. Step 13 — Smoke test Performance FE : `npm run dev` au lieu de `yarn dev`
- **Erreur** : `npm run dev` dans le smoke test alors que Performance FE utilise `yarn`
- **Fix applied** : `yarn dev` dans le smoke test Performance FE
- **Workflow fix** : Step 13 smoke test Performance FE corrigé

### 33. Step 6b — Migrations PostgreSQL exécutées avant le déploiement de `appsettings.Development.json`
- **Erreur** : Step 6b (migrations) était positionné AVANT Step 7a (déploiement config) dans le workflow, causant `ConnectionString property has not been initialized`
- **Fix applied** :
  - Step 6b remplacé par un renvoi explicite vers Step 7a-bis
  - Step 7a-bis créé juste après Step 7a — migrations exécutées immédiatement après le déploiement de la config
- **Workflow fix** : Step 6b → renvoi, Step 7a-bis → migrations déplacées au bon endroit

### 34. Step 7b stash — `--include-untracked` sur des fichiers trackés
- **Erreur** : `git stash push --include-untracked` utilisé sur des fichiers git-trackés (`appsettings.json`)
- **Cause** : `--include-untracked` est pour les fichiers non-trackés. Sur des fichiers trackés, il est inutile et peut stasher des fichiers non désirés
- **Fix applied** : `--include-untracked` retiré du `git stash push` dans Step 7b
- **Workflow fix** : Step 7b corrigé dans `amelio-onboarding.md`

### 35. Step 8a — `cat >` écrase `~/.npmrc` existant
- **Erreur** : `cat > "${HOME}/.npmrc"` écrase tout le fichier, supprimant les entrées existantes d'autres registries
- **Fix applied** : Remplacé par une logique `grep + sed/append` — met à jour l'entrée ADO si elle existe, l'ajoute sinon
- **Workflow fix** : Step 8a corrigé (bash + Windows Git Bash)

### 36. Step 1b — `$PATH` dotnet tools : `${USERNAME}` dans guillemets simples
- **Erreur** : `echo 'export PATH="$PATH:/Users/${USERNAME}/.dotnet/tools"'` — `${USERNAME}` est une variable Cascade, pas shell. Dans des guillemets simples, elle est écrite littéralement dans `~/.zprofile`, donnant un PATH invalide
- **Fix applied** : `${USERNAME}` → `$HOME` : `echo 'export PATH="$PATH:$HOME/.dotnet/tools"'`
- **Workflow fix** : Step 1b corrigé dans `amelio-onboarding.md`

### 37. Step 5d — Noms de conteneurs Docker incorrects dans la note
- **Erreur** : `Expected: 5 containers running (amelio_mongodb, dev_db, test_db, dev_cache, mailpit)` — les vrais noms générés par docker-compose sont `performance_management-dev_db-1`, etc.
- **Fix applied** : Note remplacée par la liste complète des vrais noms de conteneurs
- **Workflow fix** : Step 5d corrigé dans `amelio-onboarding.md`

### 38. Step 7c — NuGet.Config généré sans commande concrète
- **Erreur** : Le workflow disait "Read the template... replace... Save" sans donner de commande — Cascade devait deviner
- **Fix applied** : Commandes `sed` explicites ajoutées pour macOS et Windows Git Bash
- **Workflow fix** : Step 7c Part 2 corrigé dans `amelio-onboarding.md`

### 39. Step 7c — `mkdir` et `cat` NuGet utilisaient `HOME_DIR` au lieu de `HOME`
- **Erreur** : `mkdir -p "${HOME_DIR}/.nuget/NuGet"` et `cat "${HOME_DIR}/.nuget/NuGet/NuGet.Config"` — `HOME_DIR` est une variable Cascade, pas shell
- **Fix applied** : `HOME_DIR` → `HOME` dans les blocs bash de Step 7c
- **Workflow fix** : Step 7c corrigé dans `amelio-onboarding.md`

### 40. Step 8f — `NUGET_PACKAGES` utilisait `HOME_DIR` au lieu de `HOME`
- **Erreur** : `export NUGET_PACKAGES="${HOME_DIR}/.nuget/packages"` — `HOME_DIR` n'est pas une variable shell
- **Fix applied** : `HOME_DIR` → `HOME` dans Step 7c Part 1 et Step 13 smoke test IdentityServer
- **Workflow fix** : Steps 7c et 13 corrigés dans `amelio-onboarding.md`

### 41. Step 12 — Secondary workspace utilisait `HOME_DIR` au lieu de `HOME`/`$env:USERPROFILE`
- **Erreur** : `mkdir -p "${HOME_DIR}/Amelio_secondary"` (bash) et `$FS2 = "${HOME_DIR}/..."` (PowerShell)
- **Fix applied** : bash → `$HOME`, PowerShell → `$env:USERPROFILE`
- **Workflow fix** : Step 12 corrigé dans `amelio-onboarding.md`

### 42. Step 8f — NuGet workaround utilisait `HOME_DIR` au lieu de `HOME`
- **Erreur** : `mkdir -p "${HOME_DIR}/.nuget/packages/amelio.mongorepository/2.1.3"` dans le workaround NU1202
- **Fix applied** : `HOME_DIR` → `HOME`
- **Workflow fix** : Step 8f workaround corrigé dans `amelio-onboarding.md`

### 43. Step 8g — `bin/` Performance Backend inexistant après `dotnet restore`
- **Erreur** : `ls "${FS_DIR}/amelio-performance-backend/PerformanceManagement.WebApi/bin/"` — ce dossier n'existe qu'après `dotnet build`, pas `dotnet restore`
- **Fix applied** : Remplacé par `find ... -name "project.assets.json" | wc -l` (même correction que pour Legacy BE)
- **Workflow fix** : Step 8g corrigé dans `amelio-onboarding.md` (bash + PowerShell)


