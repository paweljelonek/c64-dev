# =============================================================================
# Makefile for C64 — ACME Assembler + cc65 C Compiler
# Usage:
#   make PROJECT=name          — build project from C64_PROJECTS dir
#   make DIR=path              — build project in given directory
#   make run PROJECT=name      — build and launch in VICE
#   make run DIR=path          — build directory and launch in VICE
#   make debug PROJECT=name    — build and launch with VICE monitor + symbols
#   make debug DIR=path        — build and launch with VICE monitor + symbols
#   make clean PROJECT=name    — remove build artifacts
#   make clean DIR=path        — remove build artifacts from directory
#   make list                  — show available projects and examples
#
# Source detection (auto):
#   main.c   → compiled with cc65 (cl65 -t c64)
#   main.asm → assembled with ACME
# =============================================================================

ACME     = acme
CC65     = cl65
VICE     = flatpak run --command=x64sc net.sf.VICE

-include .env

# cc65 needs CC65_HOME to find platform headers and libraries.
# Defaults to the path used by 'make install PREFIX=~/.local' from source.
CC65_HOME ?= $(HOME)/.local/share/cc65
export CC65_HOME

ifdef DIR
  PROJ_DIR = $(DIR)
else ifdef PROJECT
  PROJ_DIR = $(C64_PROJECTS)/$(PROJECT)
endif

PRG = $(PROJ_DIR)/main.prg
REP = $(PROJ_DIR)/main.rep
LBL = $(PROJ_DIR)/main.lbl
SYM = $(PROJ_DIR)/main.sym

.PHONY: all run debug clean list _require_dir
.DEFAULT_GOAL := all

_require_dir:
	@test -n "$(PROJ_DIR)" || (echo "ERROR: Specify PROJECT=name or DIR=path" && exit 1)

all: _require_dir
	@if [ -f "$(PROJ_DIR)/main.c" ]; then \
		echo ">>> Compiling C: $(PROJ_DIR)/main.c"; \
		$(CC65) -t c64 -O -Ln $(LBL) -o $(PRG) $(PROJ_DIR)/main.c; \
	elif [ -f "$(PROJ_DIR)/main.asm" ]; then \
		echo ">>> Assembling: $(PROJ_DIR)/main.asm"; \
		$(ACME) -f cbm --cpu 6510 --report $(REP) --symbollist $(SYM) -o $(PRG) $(PROJ_DIR)/main.asm; \
		awk 'NF>=3 && $$2=="=" { val=$$3; gsub(/\$$/, "", val); printf "al C:%s .%s\n", val, $$1 }' $(SYM) > $(LBL); \
	else \
		echo "ERROR: No source found in $(PROJ_DIR) (expected main.c or main.asm)" && exit 1; \
	fi
	@echo ">>> Built: $(PRG) ($$(wc -c < $(PRG)) bytes)"

run: _require_dir all
	$(VICE) -autostart $(PRG) &

debug: _require_dir all
	$(VICE) -autostart $(PRG) -moncommands $(LBL) &

clean: _require_dir
	rm -f $(PROJ_DIR)/*.prg $(PROJ_DIR)/*.map $(PROJ_DIR)/*.rep \
	      $(PROJ_DIR)/*.o $(PROJ_DIR)/*.s $(PROJ_DIR)/*.lbl $(PROJ_DIR)/*.sym

list:
	@echo "=== Projects ($(C64_PROJECTS)) ==="
	@ls -1d $(C64_PROJECTS)/*/ 2>/dev/null | xargs -I{} basename {} || echo "  (directory not found)"
	@echo ""
	@echo "=== Examples (./examples/) ==="
	@for d in examples/*/; do \
		name=$$(basename "$$d"); \
		src=""; \
		[ -f "$$d/main.asm" ] && src="asm"; \
		[ -f "$$d/main.c"   ] && src="c";   \
		echo "  $$name  [$$src]  →  make run DIR=$$d"; \
	done
