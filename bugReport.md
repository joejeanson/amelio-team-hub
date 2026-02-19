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

---

## ❌ UNRESOLVED

### 10. Legacy Backend dotnet restore — 401 Unauthorized on NuGet feed
- **Error**: `NU1301: Response status code does not indicate success: 401 (Unauthorized)`
- **Feed**: `https://pkgs.dev.azure.com/ameliodev/_packaging/Amelio.MongoRepository/nuget/v3/index.json`
- **Cause**: The ADO PAT used during this session does not have **Packaging (Read)** scope for the NuGet feed
- **Impact**: `dotnet restore` fails for: `OPIA.API.V2`, `OPIA.Business.V2`, `OPIA.Repository.V2`, `OPIA.Scheduler.V2`, `OPIA.Web.V2`, `OPIA.Uitlity.V2`, `DatabaseMigrator.V2`, `Tests/OPIA.API.V2.Tests`
- **Full error log**: See `nuget-restore-error.log` at the root of this repo
- **Resolution**: Generate a new PAT at https://dev.azure.com/ameliodev/_usersSettings/tokens with scopes **Code (Read & Write)** + **Packaging (Read)**, then update `~/.nuget/NuGet/NuGet.Config`

### 11. MongoDB Freemium database not imported
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

### 12. VITE_DEV_TOKEN not set in amelio-performance-fe/.env
- **Status**: Placeholder only — requires a live JWT token
- **Impact**: Performance Frontend dev mode will not authenticate against Legacy Backend
- **Resolution**: Start Legacy Frontend (http://localhost:3011), log in, open DevTools > Network, copy the Bearer token from any API request header, paste into `.env` as `VITE_DEV_TOKEN`

