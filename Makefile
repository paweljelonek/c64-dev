# =============================================================================
# Makefile for C64 — ACME Assembler
# Usage:
#   make PROJECT=name          — assemble project
#   make run PROJECT=name      — assemble and launch in VICE
#   make debug PROJECT=name    — launch with VICE monitor
#   make clean PROJECT=name    — remove build artifacts
#   make list                  — show available projects
# =============================================================================

ACME = acme
VICE = flatpak run --command=x64sc net.sf.VICE

-include .env

PROJ_DIR = $(C64_PROJECTS)/$(PROJECT)
SRC      = $(PROJ_DIR)/main.asm
PRG      = $(PROJ_DIR)/main.prg
REP      = $(PROJ_DIR)/main.rep

.PHONY: all run debug clean list

_require_project:
	@test -n "$(PROJECT)" || (echo "ERROR: PROJECT is required. Usage: make PROJECT=name" && exit 1)

all: _require_project $(PRG)

$(PRG): $(SRC)
	@test -f $(SRC) || (echo "ERROR: $(SRC) not found" && exit 1)
	$(ACME) -f cbm --cpu 6510 --report $(REP) -o $@ $<
	@echo ">>> Built: $@ ($$(wc -c < $@) bytes)"

run: _require_project $(PRG)
	$(VICE) -autostart $(PRG) &

debug: _require_project $(PRG)
	$(VICE) -autostart $(PRG) -moncommands /dev/stdin &

clean: _require_project
	rm -f $(PROJ_DIR)/*.prg $(PROJ_DIR)/*.map $(PROJ_DIR)/*.rep

list:
	@echo "Available projects ($(C64_PROJECTS)):"
	@ls -1d $(C64_PROJECTS)/*/ 2>/dev/null | xargs -I{} basename {} || echo "  (directory not found)"
