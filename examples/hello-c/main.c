/*
 * Hello World — C for Commodore 64 (cc65)
 *
 * cc65's <conio.h> provides C64 console I/O:
 *   clrscr()   — clear screen (sends PETSCII CLR/HOME)
 *   cputs()    — print string; use \r\n for newlines on C64
 *   cprintf()  — formatted print (like printf but PETSCII-aware)
 *   cgetc()    — wait for a keypress
 *
 * Build: make DIR=examples/hello-c
 * Run:   make run DIR=examples/hello-c
 */
#include <conio.h>

int main(void)
{
    clrscr();
    cputs("HELLO, WORLD!\r\n");
    cputs("\r\nPRESS ANY KEY...\r\n");
    cgetc();
    return 0;
}
