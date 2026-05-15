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

RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[1;33m
CYAN   := \033[0;36m
BOLD   := \033[1m
NC     := \033[0m

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

.PHONY: all run debug clean list help _require_dir
.DEFAULT_GOAL := help

_require_dir:
	@test -n "$(PROJ_DIR)" || (printf "$(RED)ERROR:$(NC) Specify PROJECT=name or DIR=path\n" && exit 1)

all: _require_dir
	@if [ -f "$(PROJ_DIR)/main.c" ]; then \
		printf "$(CYAN)>>>$(NC) Compiling C: $(BOLD)$(PROJ_DIR)/main.c$(NC)\n"; \
		$(CC65) -t c64 -O -Ln $(LBL) -o $(PRG) $(PROJ_DIR)/main.c; \
	elif [ -f "$(PROJ_DIR)/main.asm" ]; then \
		printf "$(CYAN)>>>$(NC) Assembling: $(BOLD)$(PROJ_DIR)/main.asm$(NC)\n"; \
		$(ACME) -f cbm --cpu 6510 --report $(REP) --symbollist $(SYM) -o $(PRG) $(PROJ_DIR)/main.asm; \
		awk 'NF>=3 && $$2=="=" { val=$$3; gsub(/\$$/, "", val); printf "al C:%s .%s\n", val, $$1 }' $(SYM) > $(LBL); \
	else \
		printf "$(RED)ERROR:$(NC) No source found in $(PROJ_DIR) (expected main.c or main.asm)\n" && exit 1; \
	fi
	@printf "$(GREEN)>>>$(NC) Built: $(BOLD)$(PRG)$(NC) ($$(wc -c < $(PRG)) bytes)\n"

run: _require_dir all
	$(VICE) -autostart $(PRG) &

debug: _require_dir all
	$(VICE) -autostart $(PRG) -moncommands $(LBL) &

clean: _require_dir
	rm -f $(PROJ_DIR)/*.prg $(PROJ_DIR)/*.map $(PROJ_DIR)/*.rep \
	      $(PROJ_DIR)/*.o $(PROJ_DIR)/*.s $(PROJ_DIR)/*.lbl $(PROJ_DIR)/*.sym

list:
	@if [ -z "$(C64_PROJECTS)" ]; then \
		printf "$(BOLD)=== Projects ===$(NC)\n"; \
		printf "  $(YELLOW)C64_PROJECTS is not set.$(NC)\n"; \
		printf "  Copy $(BOLD).env.dist$(NC) to $(BOLD).env$(NC) and set the path:\n"; \
		printf "    cp .env.dist .env\n"; \
		printf "    # edit .env: C64_PROJECTS=/path/to/your/projects\n"; \
	elif [ ! -d "$(C64_PROJECTS)" ]; then \
		printf "$(BOLD)=== Projects ($(C64_PROJECTS)) ===$(NC)\n"; \
		printf "  $(YELLOW)Directory not found.$(NC)\n"; \
		printf "  Create it: mkdir -p $(C64_PROJECTS)\n"; \
	else \
		printf "$(BOLD)=== Projects ($(C64_PROJECTS)) ===$(NC)\n"; \
		ls -1d $(C64_PROJECTS)/*/ 2>/dev/null | xargs -I{} basename {} || printf "  $(YELLOW)(no projects yet)$(NC)\n"; \
	fi
	@printf "\n"
	@printf "$(BOLD)=== Examples (./examples/) ===$(NC)\n"
	@for d in examples/*/; do \
		name=$$(basename "$$d"); \
		src=""; \
		[ -f "$$d/main.asm" ] && src="asm"; \
		[ -f "$$d/main.c"   ] && src="c";   \
		printf "  $(CYAN)%-16s$(NC)  [$(GREEN)%-3s$(NC)]  →  make run DIR=$$d\n" "$$name" "$$src"; \
	done

help:
	@printf "$(BOLD)C64 development environment$(NC) — ACME Assembler + cc65 C Compiler\n"
	@printf "\n"
	@printf "$(BOLD)Usage:$(NC)\n"
	@printf "  $(CYAN)make PROJECT=name$(NC)          build project from C64_PROJECTS dir\n"
	@printf "  $(CYAN)make DIR=path$(NC)              build project in given directory\n"
	@printf "  $(CYAN)make run PROJECT=name$(NC)      build and launch in VICE\n"
	@printf "  $(CYAN)make run DIR=path$(NC)          build directory and launch in VICE\n"
	@printf "  $(CYAN)make debug PROJECT=name$(NC)    build and launch with VICE monitor + symbols\n"
	@printf "  $(CYAN)make debug DIR=path$(NC)        build and launch with VICE monitor + symbols\n"
	@printf "  $(CYAN)make clean PROJECT=name$(NC)    remove build artifacts\n"
	@printf "  $(CYAN)make clean DIR=path$(NC)        remove build artifacts from directory\n"
	@printf "  $(CYAN)make list$(NC)                  show available projects and examples\n"
	@printf "\n"
	@printf "$(BOLD)Source detection (auto):$(NC)\n"
	@printf "  main.c   → compiled with cc65 (cl65 -t c64)\n"
	@printf "  main.asm → assembled with ACME\n"
