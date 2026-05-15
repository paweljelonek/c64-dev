#!/usr/bin/env bash
# =============================================================================
# Commodore 64 Development Environment — Uninstaller
# Removes everything installed by setup.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }

INSTALL_DIR="$HOME/.c64-dev"
BIN_DIR="$HOME/.local/bin"

# =============================================================================
# CONFIRM
# =============================================================================
echo ""
echo -e "${RED}============================================================${NC}"
echo -e "${RED}  C64 Dev — Uninstaller${NC}"
echo -e "${RED}============================================================${NC}"
echo ""
echo "  This will remove:"
echo "    - $INSTALL_DIR/"
echo "      (KickAssembler, DASM, C64Debugger, Exomizer, pucrunch,"
echo "       and any source builds: cc65, ACME, GoatTracker)"
echo "    - $BIN_DIR/: kickass  dasm  c64debugger  exomizer  pucrunch"
echo "      and source-built: acme  goattracker  cc65 toolchain"
echo "    - PATH entry added to shell rc by setup.sh"
echo ""
read -r -p "Continue? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
echo ""

# =============================================================================
# 1. REMOVE ~/.c64-dev/ (source builds and downloaded tools)
# =============================================================================
if [ -d "$INSTALL_DIR" ]; then
    info "Removing $INSTALL_DIR ..."
    rm -rf "$INSTALL_DIR"
    ok "Removed $INSTALL_DIR"
else
    info "$INSTALL_DIR not found, skipping."
fi

# =============================================================================
# 2. REMOVE BINARIES FROM ~/.local/bin/
# =============================================================================
info "Removing tool binaries from $BIN_DIR ..."
for bin in kickass dasm c64debugger exomizer pucrunch acme goattracker; do
    target="$BIN_DIR/$bin"
    if [ -f "$target" ] || [ -L "$target" ]; then
        rm -f "$target"
        ok "Removed $target"
    fi
done

# cc65 source-built: installs multiple binaries + share/cc65/ data
CC65_BINS=(cc65 cl65 ca65 ld65 ar65 od65 grc65 da65 co65 c1541 petcat)
SOURCE_CC65=0
for bin in "${CC65_BINS[@]}"; do
    [ -f "$BIN_DIR/$bin" ] && SOURCE_CC65=1 && break
done
if [ "$SOURCE_CC65" -eq 1 ]; then
    info "Removing source-built cc65 toolchain from $BIN_DIR ..."
    for bin in "${CC65_BINS[@]}"; do
        rm -f "$BIN_DIR/$bin"
    done
    rm -rf "$HOME/.local/share/cc65"
    ok "Removed cc65 toolchain from ~/.local"
fi

# =============================================================================
# 3. REMOVE PATH ENTRY ADDED BY setup.sh
# =============================================================================
info "Removing C64 PATH entry from shell rc files..."
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$RC" ] && grep -q '# C64 Development tools' "$RC"; then
        python3 - "$RC" <<'PYEOF'
import sys, re
f = sys.argv[1]
with open(f) as fh:
    txt = fh.read()
txt = re.sub(r'\n\n# C64 Development tools\nexport PATH="\$HOME/\.local/bin:\$PATH"', '\n', txt)
with open(f, 'w') as fh:
    fh.write(txt)
PYEOF
        ok "Removed PATH entry from $RC"
    fi
done

# =============================================================================
# 4. APT PACKAGES (OPTIONAL)
# =============================================================================
echo ""
echo "  The following apt packages may have been installed by setup.sh:"
echo "    acme  vice  xa65  cc65  goattracker  sidplayfp  default-jre"
echo "  (general packages like build-essential, git, cmake are not listed)"
echo ""
read -r -p "Remove these apt packages? [y/N] " REMOVE_APT
if [[ "$REMOVE_APT" =~ ^[Yy]$ ]]; then
    sudo apt-get remove -y acme vice xa65 cc65 goattracker sidplayfp default-jre 2>/dev/null || true
    sudo apt-get autoremove -y
    ok "Apt packages removed."
else
    info "Apt packages kept."
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  C64 Dev environment removed.${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
warn "Restart your terminal or reload your shell config to update PATH."
echo ""
