# c64-dev

> **Early version** - work in progress, expect breaking changes.

Development environment for Commodore 64 - 6510 assembler, VICE emulator, debugger and helper tools.

## Structure

```
c64-dev/
├── .env               - local configuration (git-ignored, copy from .env.dist)
├── .env.dist          - configuration template
├── .gitignore
├── LICENSE
├── setup-c64-dev.sh   - install all tools (Linux Mint / Ubuntu / Debian)
└── Makefile           - build and run projects
```

Projects live separately in `~/Projects/c64-projects/` - each as its own git repository.

## Quick start

### 1. Install tools

```bash
./setup-c64-dev.sh
```

Installs: ACME, cc65, DASM, KickAssembler, VICE, C64Debugger, GoatTracker, Exomizer, pucrunch.

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

```bash
make PROJECT=my-project           # assemble
make run PROJECT=my-project       # assemble and launch in VICE
make debug PROJECT=my-project     # launch with VICE monitor
make clean PROJECT=my-project     # remove build artifacts
make list                         # list available projects (directories only)
```

## Tools

| Tool         | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| acme         | [ACME Assembler](https://sourceforge.net/projects/acme-crossass/) (default) |
| cc65         | [cc65](https://cc65.github.io/) - C compiler for 6502/6510                  |
| dasm         | [DASM](https://dasm-assembler.github.io/) - Assembler                       |
| kickass      | [KickAssembler](http://www.theweb.dk/KickAssembler/) (requires Java)        |
| x64sc        | [VICE](https://vice-emu.sourceforge.io/) - C64 emulator                     |
| c64debugger  | [C64 Debugger](https://sourceforge.net/projects/c64-debugger/)              |
| goattracker  | [GoatTracker](https://sourceforge.net/projects/goattracker2/) - SID tracker |
| sidplayfp    | [sidplayfp](https://sourceforge.net/projects/sidplay-residfp/) - SID player |
| exomizer     | [Exomizer](https://bitbucket.org/magli143/exomizer) - data compressor       |
| pucrunch     | [pucrunch](https://github.com/mist64/pucrunch) - data compressor            |
| c1541        | D64 disk image tool (part of VICE)                                          |
| petcat       | PETSCII/ASCII converter (part of VICE)                                      |

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

## Author

**Paweł Jelonek** - pawel.jelonek [at] gmail [dot] com
