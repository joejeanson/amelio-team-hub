#!/bin/bash
# ============================================================================
# Amelio Team - Windsurf Configuration Installer
# ============================================================================
# Deploys shared skills, workflows, rules, and workspace to Windsurf config.
# Safe to re-run: uses rsync/diff to update only changed files.
# Does NOT touch existing skills/workflows — only adds/updates shared ones.
# Personal memories (.pb files) are NEVER overwritten.
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/windsurf"
TARGET="$HOME/.codeium/windsurf"
RULES_TARGET="$HOME/.codeium/.windsurf/rules"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Amelio Team - Windsurf Installer                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Pre-checks ──────────────────────────────────────────────────────────────────
if [[ ! -d "$SOURCE" ]]; then
    echo -e "${RED}ERROR: Source directory not found: $SOURCE${NC}"
    exit 1
fi

if [[ ! -d "$TARGET" ]]; then
    echo -e "${YELLOW}Windsurf config directory not found at $TARGET${NC}"
    echo -e "${YELLOW}Creating it now...${NC}"
    mkdir -p "$TARGET"
fi

# ── Parse arguments ─────────────────────────────────────────────────────────────
MODE="check"
if [[ "${1:-}" == "--install" ]]; then
    MODE="install"
elif [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: ./setup.sh [--check|--install]"
    echo ""
    echo "  --check    (default) Show what would be installed/updated"
    echo "  --install  Install/update skills, workflows, rules, and workspace"
    echo ""
    exit 0
fi

MODE_UPPER=$(echo "$MODE" | tr '[:lower:]' '[:upper:]')
echo -e "Mode: ${GREEN}${MODE_UPPER}${NC}"
echo ""

# ── Helpers ─────────────────────────────────────────────────────────────────────
CHANGES=0

sync_folder() {
    local name="$1"
    local src="$2"
    local dst="$3"

    if [[ ! -d "$src" ]]; then
        echo -e "   ${RED}⚠ Source not found: $src${NC}"
        return
    fi

    local src_count
    src_count=$(find "$src" -type f -not -name '.DS_Store' | wc -l | tr -d ' ')

    if [[ "$MODE" == "install" ]]; then
        mkdir -p "$dst"
        rsync -a --delete --exclude='.DS_Store' --exclude='*.bak' "$src/" "$dst/"
        echo -e "   ${GREEN}├─ $name: synced $src_count files${NC}"
    else
        if [[ ! -d "$dst" ]]; then
            echo -e "   ${YELLOW}├─ $name: MISSING ($src_count files to install)${NC}"
            CHANGES=$((CHANGES + src_count))
        else
            local diff_count
            diff_count=$(rsync -a --delete --dry-run --itemize-changes --exclude='.DS_Store' --exclude='*.bak' "$src/" "$dst/" 2>/dev/null | grep -c '^' || true)
            if [[ "$diff_count" -gt 0 ]]; then
                echo -e "   ${YELLOW}├─ $name: $diff_count files to update${NC}"
                CHANGES=$((CHANGES + diff_count))
            else
                echo -e "   ${GREEN}├─ $name: OK ($src_count files)${NC}"
            fi
        fi
    fi
}

sync_file() {
    local name="$1"
    local src="$2"
    local dst="$3"

    if [[ ! -f "$src" ]]; then
        echo -e "   ${RED}⚠ Source not found: $src${NC}"
        return
    fi

    if [[ "$MODE" == "install" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo -e "   ${GREEN}├─ $name${NC}"
    else
        if [[ ! -f "$dst" ]]; then
            echo -e "   ${YELLOW}├─ $name: MISSING${NC}"
            CHANGES=$((CHANGES + 1))
        elif ! diff -q "$src" "$dst" > /dev/null 2>&1; then
            echo -e "   ${YELLOW}├─ $name: DIFFERENT${NC}"
            CHANGES=$((CHANGES + 1))
        else
            echo -e "   ${GREEN}├─ $name: OK${NC}"
        fi
    fi
}

# ── Skills (each folder individually — does NOT touch other local skills) ───
echo -e "${BLUE}📦 Skills${NC}"
for skill_dir in "$SOURCE"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    sync_folder "$skill_name" "$skill_dir" "$TARGET/skills/$skill_name"
done
echo ""

# ── Workflows (each file individually — does NOT touch other local workflows) 
echo -e "${BLUE}📦 Workflows${NC}"
for wf in "$SOURCE"/global_workflows/*.md; do
    wf_name=$(basename "$wf")
    sync_file "$wf_name" "$wf" "$TARGET/global_workflows/$wf_name"
done
echo ""

# ── Rules (conditional rules — .windsurf/rules/) ────────────────────────────
if [[ -d "$SOURCE/rules" ]]; then
    echo -e "${BLUE}📦 Rules${NC}"
    for rule in "$SOURCE"/rules/*.md; do
        rule_name=$(basename "$rule")
        sync_file "$rule_name" "$rule" "$RULES_TARGET/$rule_name"
    done
    echo ""
fi

# ── Global Rules (memories/global_rules.md — NO --delete, preserves .pb files) ─
if [[ -f "$SOURCE/memories/global_rules.md" ]]; then
    echo -e "${BLUE}📦 Global Rules${NC}"
    sync_file "global_rules.md" "$SOURCE/memories/global_rules.md" "$TARGET/memories/global_rules.md"
    echo ""
fi

# ── Workspace template ──────────────────────────────────────────────────────
WS_TEMPLATE="$SOURCE/workspace/Simple.code-workspace"
if [[ -f "$WS_TEMPLATE" ]]; then
    echo -e "${BLUE}📦 Workspace${NC}"
    WS_USER=$(whoami)

    # Detect install mode: if REPOs/ exists inside team-hub, it's parent mode
    if [[ -d "$SCRIPT_DIR/REPOs" ]]; then
        AMELIO_DIR="$SCRIPT_DIR"
        WS_OUTPUT="$SCRIPT_DIR/REPOs/WorkSpace/Simple_${WS_USER}.code-workspace"
        echo -e "   ${BLUE}├─ Mode: team-hub as parent${NC}"
    else
        if [[ "$(uname)" == "Darwin" ]]; then
            AMELIO_DIR="/Users/${WS_USER}/Amelio_primary"
        else
            AMELIO_DIR="/home/${WS_USER}/Amelio_primary"
        fi
        WS_OUTPUT="$AMELIO_DIR/REPOs/WorkSpace/Simple_${WS_USER}.code-workspace"
        echo -e "   ${BLUE}├─ Mode: separate Amelio_primary${NC}"
    fi

    if [[ "$MODE" == "install" ]]; then
        mkdir -p "$(dirname "$WS_OUTPUT")"
        sed "s|<AMELIO_DIR>|${AMELIO_DIR}|g" "$WS_TEMPLATE" > "$WS_OUTPUT"
        echo -e "   ${GREEN}├─ Generated: Simple_${WS_USER}.code-workspace${NC}"
    else
        if [[ -f "$WS_OUTPUT" ]]; then
            echo -e "   ${GREEN}├─ Simple_${WS_USER}.code-workspace: EXISTS${NC}"
        else
            echo -e "   ${YELLOW}├─ Simple_${WS_USER}.code-workspace: WILL BE GENERATED${NC}"
            CHANGES=$((CHANGES + 1))
        fi
    fi
    echo ""
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
if [[ "$MODE" == "install" ]]; then
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo ""
    echo -e "Deployed to: ${BLUE}$TARGET${NC}"
else
    if [[ $CHANGES -eq 0 ]]; then
        echo -e "${GREEN}✓ Everything is up to date${NC}"
    else
        echo -e "${YELLOW}⚠ $CHANGES changes detected${NC}"
        echo -e "${BLUE}Run with --install to apply changes${NC}"
    fi
fi
echo ""
