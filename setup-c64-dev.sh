#!/usr/bin/env bash
# =============================================================================
# Commodore 64 Development Environment Setup
# For: Linux Mint / Ubuntu / Debian
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
error() { echo -e "${RED}[ERR ]${NC} $*"; exit 1; }

INSTALL_DIR="$HOME/.c64-dev"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# =============================================================================
# 1. SYSTEM DEPENDENCIES
# =============================================================================
info "Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    unzip \
    libsdl2-dev \
    libpng-dev \
    libjpeg-dev \
    xa65 \
    cc65 \
    make \
    cmake \
    python3 \
    python3-pip \
    default-jre
ok "Dependencies installed."

# =============================================================================
# 2. VICE EMULATOR
# =============================================================================
info "Installing VICE emulator..."
if ! command -v x64sc &>/dev/null; then
    sudo apt-get install -y vice
    VICE_ROM_DIR="$HOME/.local/share/vice"
    if [ ! -d "$VICE_ROM_DIR/C64" ]; then
        warn "Note: Commodore 64 ROMs (kernal, basic, chargen) must be provided"
        warn "  manually due to licensing. Copy them to: $VICE_ROM_DIR/C64/"
        warn "  Required files: basic, chargen, kernal"
    fi
    ok "VICE installed: $(x64sc --version 2>&1 | head -1 || echo 'check manually')"
else
    ok "VICE already installed."
fi

# =============================================================================
# 3. CC65 — C COMPILER FOR 6502
# =============================================================================
info "Checking cc65..."
if command -v cc65 &>/dev/null; then
    ok "cc65 already installed: $(cc65 --version 2>&1)"
else
    info "Building cc65 from source..."
    cd "$INSTALL_DIR"
    git clone --depth 1 https://github.com/cc65/cc65.git cc65-src
    cd cc65-src
    make -j"$(nproc)"
    make install PREFIX="$HOME/.local"
    ok "cc65 installed."
    cd "$INSTALL_DIR"
fi

# =============================================================================
# 4. KICK ASSEMBLER
# =============================================================================
info "Installing KickAssembler..."
KICK_DIR="$INSTALL_DIR/KickAssembler"
KICK_JAR="$KICK_DIR/KickAss.jar"
if [ ! -f "$KICK_JAR" ]; then
    mkdir -p "$KICK_DIR"
    cd "$KICK_DIR"
    KICK_URL="http://www.theweb.dk/KickAssembler/KickAssembler.zip"
    info "Downloading KickAssembler from $KICK_URL ..."
    wget -q "$KICK_URL" -O KickAssembler.zip
    unzip -q KickAssembler.zip
    rm KickAssembler.zip
    cat > "$BIN_DIR/kickass" << 'EOF'
#!/usr/bin/env bash
java -jar "$HOME/.c64-dev/KickAssembler/KickAss.jar" "$@"
EOF
    chmod +x "$BIN_DIR/kickass"
    ok "KickAssembler installed."
else
    ok "KickAssembler already installed."
fi
cd "$INSTALL_DIR"

# =============================================================================
# 5. ACME ASSEMBLER
# =============================================================================
info "Installing ACME Assembler..."
if ! command -v acme &>/dev/null; then
    sudo apt-get install -y acme || {
        info "Building ACME from source..."
        cd "$INSTALL_DIR"
        git clone --depth 1 https://sourceforge.net/p/acme-crossass/code-0/HEAD/tree/ acme-src 2>/dev/null || \
        git clone --depth 1 https://github.com/meonwax/acme.git acme-src
        cd acme-src/src
        make -j"$(nproc)"
        cp acme "$BIN_DIR/"
        ok "ACME built."
        cd "$INSTALL_DIR"
    }
    ok "ACME installed."
else
    ok "ACME already installed."
fi

# =============================================================================
# 6. DASM ASSEMBLER
# =============================================================================
info "Installing DASM Assembler..."
DASM_BIN="$BIN_DIR/dasm"
if [ ! -f "$DASM_BIN" ]; then
    cd "$INSTALL_DIR"
    git clone --depth 1 https://github.com/dasm-assembler/dasm.git dasm-src
    cd dasm-src
    make -j"$(nproc)"
    cp src/dasm "$BIN_DIR/"
    ok "DASM installed."
    cd "$INSTALL_DIR"
else
    ok "DASM already installed."
fi

# =============================================================================
# 7. C64DEBUGGER
# =============================================================================
info "Installing C64Debugger..."
C64DBG_DIR="$INSTALL_DIR/C64Debugger"
if [ ! -d "$C64DBG_DIR" ]; then
    mkdir -p "$C64DBG_DIR"
    C64DBG_URL="https://sourceforge.net/projects/c64-debugger/files/latest/download"
    info "Downloading C64Debugger..."
    wget -q --show-progress "$C64DBG_URL" -O "$C64DBG_DIR/C64Debugger.zip" || \
        warn "Could not download C64Debugger automatically. Download manually from: https://sourceforge.net/projects/c64-debugger/"
    if [ -f "$C64DBG_DIR/C64Debugger.zip" ]; then
        unzip -q "$C64DBG_DIR/C64Debugger.zip" -d "$C64DBG_DIR"
        rm "$C64DBG_DIR/C64Debugger.zip"
        find "$C64DBG_DIR" -name "C64Debugger" -type f -exec chmod +x {} \;
        find "$C64DBG_DIR" -name "C64Debugger" -type f -exec ln -sf {} "$BIN_DIR/c64debugger" \;
        ok "C64Debugger installed."
    fi
else
    ok "C64Debugger already installed."
fi
cd "$INSTALL_DIR"

# =============================================================================
# 8. GOATTRACKER (SID MUSIC)
# =============================================================================
info "Installing GoatTracker..."
if ! command -v goattracker &>/dev/null; then
    sudo apt-get install -y goattracker 2>/dev/null || {
        cd "$INSTALL_DIR"
        git clone --depth 1 https://github.com/cadaver/goattracker2.git goattracker-src
        cd goattracker-src
        make -j"$(nproc)"
        cp goattracker "$BIN_DIR/"
        ok "GoatTracker built."
        cd "$INSTALL_DIR"
    }
    ok "GoatTracker installed."
else
    ok "GoatTracker already installed."
fi

# =============================================================================
# 9. SIDPLAYFP (SID PLAYBACK)
# =============================================================================
info "Installing sidplayfp..."
sudo apt-get install -y sidplayfp 2>/dev/null && ok "sidplayfp installed." || warn "sidplayfp not available in repo."

# =============================================================================
# 10. EXOMIZER (DATA COMPRESSOR)
# =============================================================================
info "Installing Exomizer..."
if ! command -v exomizer &>/dev/null; then
    cd "$INSTALL_DIR"
    git clone --depth 1 https://bitbucket.org/magli143/exomizer.git exomizer-src 2>/dev/null || \
    git clone --depth 1 https://github.com/exomizer/exomizer.git exomizer-src
    cd exomizer-src/src
    make -j"$(nproc)"
    cp exomizer "$BIN_DIR/"
    ok "Exomizer installed."
    cd "$INSTALL_DIR"
else
    ok "Exomizer already installed."
fi

# =============================================================================
# 11. PETCAT / C1541 (VICE DISK TOOLS)
# =============================================================================
info "Checking VICE tools (petcat, c1541)..."
if command -v petcat &>/dev/null; then
    ok "petcat available."
else
    warn "petcat not found — should be installed alongside VICE."
fi

# =============================================================================
# 12. PUCRUNCH (COMPRESSOR)
# =============================================================================
info "Installing pucrunch..."
PUCRUNCH_BIN="$BIN_DIR/pucrunch"
if [ ! -f "$PUCRUNCH_BIN" ]; then
    cd "$INSTALL_DIR"
    git clone --depth 1 https://github.com/mist64/pucrunch.git pucrunch-src
    cd pucrunch-src
    make -j"$(nproc)"
    cp pucrunch "$BIN_DIR/"
    ok "pucrunch installed."
    cd "$INSTALL_DIR"
else
    ok "pucrunch already installed."
fi

# =============================================================================
# 13. ADD ~/.local/bin TO PATH
# =============================================================================
SHELL_RC="$HOME/.bashrc"
[ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q 'c64-dev\|\.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# C64 Development tools' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    info "Added ~/.local/bin to PATH in $SHELL_RC"
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  C64 Dev environment ready!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  Installed tools:"
echo ""
echo "  ASSEMBLERS:"
echo "    xa        — $(command -v xa      && xa --version 2>&1 | head -1 || echo 'not available')"
echo "    acme      — $(command -v acme    && acme --version 2>&1 | head -1 || echo 'not available')"
echo "    dasm      — $(command -v dasm    && dasm 2>&1 | head -1 || echo 'not available')"
echo "    cc65      — $(command -v cc65    && cc65 --version 2>&1 || echo 'not available')"
echo "    kickass   — $(command -v kickass && echo 'available (Java)' || echo 'not available')"
echo ""
echo "  EMULATOR / DEBUGGER:"
echo "    x64sc        — VICE (C64 emulator)"
echo "    c64debugger  — C64 Debugger"
echo ""
echo "  MUSIC:"
echo "    goattracker  — SID tracker"
echo "    sidplayfp    — SID player"
echo ""
echo "  COMPRESSORS:"
echo "    exomizer  — data compressor for C64"
echo "    pucrunch  — data compressor for C64"
echo ""
echo "  DISK TOOLS:"
echo "    c1541     — D64 disk image tool"
echo "    petcat    — PETSCII/ASCII converter"
echo ""
echo -e "${YELLOW}  Restart your terminal or run: source $SHELL_RC${NC}"
echo ""
echo "  Useful links:"
echo "    https://cc65.github.io/doc/"
echo "    https://vice-emu.sourceforge.io/"
echo "    http://www.theweb.dk/KickAssembler/"
echo "    https://www.c64-wiki.com/wiki/Programming"
echo ""
