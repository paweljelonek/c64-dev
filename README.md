# c64-dev

> ⚠️ **Early version** - work in progress, expect breaking changes.


Development environment for Commodore 64 - 6510 assembler, VICE emulator, debugger and helper tools.

> 🐧 **Linux only** - tested on Ubuntu, Linux Mint and Debian-based distributions.


## Structure

```
c64-dev/
├── .env               - local configuration (git-ignored, copy from .env.dist)
├── .env.dist          - configuration template
├── .gitignore
├── LICENSE
├── setup-c64-dev.sh   - install all tools (Linux Mint / Ubuntu / Debian)
├── Makefile           - build and run projects
└── examples/
    ├── hello-asm/     - Hello World in 6510 assembly (ACME)
    ├── raster-asm/    - Raster color bars effect in assembly
    ├── hello-c/       - Hello World in C (cc65)
    └── colors-c/      - VIC-II color cycling in C (cc65)
```

Projects live separately in `~/Projects/c64-projects/` - each as its own git repository.

## Quick start

### 1. Install tools

```bash
./setup-c64-dev.sh
```

Installs: ACME, cc65, DASM, KickAssembler, VICE, C64Debugger, GoatTracker, Exomizer, pucrunch.

Tools are installed in three locations:

| Location        | What                                                        |
|-----------------|-------------------------------------------------------------|
| system (apt)    | `acme`, `cc65`, `vice`, `xa65`, `goattracker`, `sidplayfp` |
| `~/.c64-dev/`   | source builds and archives (KickAssembler, DASM, etc.)      |
| `~/.local/bin/` | compiled binaries and wrappers                              |

### 2. Configure

Copy `.env.dist` to `.env` and adjust the path:

```bash
cp .env.dist .env
```

```env
C64_PROJECTS=/home/you/Projects/c64-projects
```

### 3. New project

```bash
mkdir ~/Projects/c64-projects/my-project
cd ~/Projects/c64-projects/my-project
git init
echo -e "*.prg\n*.rep\n*.map" > .gitignore
# create main.asm and start coding
```

### 4. Build and run

The Makefile supports two ways to specify what to build:

**`PROJECT=name`** - builds a project from `C64_PROJECTS` directory (set in `.env`):

```bash
make PROJECT=my-project           # build (auto-detects main.asm or main.c)
make run PROJECT=my-project       # build and launch in VICE
make debug PROJECT=my-project     # launch with VICE monitor
make clean PROJECT=my-project     # remove build artifacts
make list                         # list projects and examples
```

**`DIR=path`** - builds a project in any directory, e.g. the bundled examples:

```bash
make DIR=examples/hello-asm       # build assembly example
make run DIR=examples/hello-c     # build and run C example
make clean DIR=examples/colors-c  # clean example build artifacts
```

Source type is detected automatically: `main.c` → cc65, `main.asm` → ACME.

## Tools

| Tool         | Description                              | Website                                                                                              |
|--------------|------------------------------------------|------------------------------------------------------------------------------------------------------|
| acme         | ACME Assembler (default)                 | https://sourceforge.net/projects/acme-crossass/                                                      |
| cc65         | C compiler for 6502/6510                 | https://cc65.github.io/                                                                              |
| dasm         | Assembler                                | https://dasm-assembler.github.io/                                                                    |
| kickass      | KickAssembler (requires Java)            | http://www.theweb.dk/KickAssembler/                                                                  |
| x64sc        | VICE - C64 emulator                      | https://vice-emu.sourceforge.io/                                                                     |
| c64debugger  | C64 Debugger                             | https://sourceforge.net/projects/c64-debugger/                                                       |
| goattracker  | GoatTracker - SID tracker                | https://sourceforge.net/projects/goattracker2/                                                       |
| sidplayfp    | SID player                               | https://sourceforge.net/projects/sidplay-residfp/                                                    |
| exomizer     | Data compressor                          | https://bitbucket.org/magli143/exomizer                                                              |
| pucrunch     | Data compressor                          | https://github.com/mist64/pucrunch                                                                   |
| c1541        | D64 disk image tool (part of VICE)       |                                                                                                      |
| petcat       | PETSCII/ASCII converter (part of VICE)   |                                                                                                      |

## Contributing

Feel free to use this, copy it, hack it, break it, fix it - do whatever you want with it. I hope it saves you some time getting started on C64.

If you run into a bug, have an idea for improvement, or just want to share what you built with it - drop me a line. All feedback welcome.

pawel.jelonek [at] gmail [dot] com

## Links

- [C64 Wiki - Programming](https://www.c64-wiki.com/wiki/Programming)
- [6510 Instruction Set](https://www.c64-wiki.com/wiki/6510_Instruction_Set)
- [C64 Memory Map](https://www.c64-wiki.com/wiki/Memory_Map)
- [HVSC - SID music collection](https://www.hvsc.c64.org/)

## License

MIT - see [LICENSE](LICENSE)

