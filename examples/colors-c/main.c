/*
 * VIC-II Color Cycling — C for Commodore 64 (cc65)
 *
 * Demonstrates direct hardware register access via cc65's <c64.h>:
 *   VIC.bordercolor  — maps to $D020 (border color, 0-15)
 *   VIC.bgcolor0     — maps to $D021 (background color 0, 0-15)
 *
 * Color constants (0-15): COLOR_BLACK, COLOR_WHITE, COLOR_RED,
 *   COLOR_CYAN, COLOR_PURPLE, COLOR_GREEN, COLOR_BLUE, COLOR_YELLOW,
 *   COLOR_ORANGE, COLOR_BROWN, COLOR_LIGHTRED, COLOR_GRAY1,
 *   COLOR_GRAY2, COLOR_LIGHTGREEN, COLOR_LIGHTBLUE, COLOR_GRAY3
 *
 * Build: make DIR=examples/colors-c
 * Run:   make run DIR=examples/colors-c
 */
#include <conio.h>
#include <c64.h>

#define DELAY 4000

int main(void)
{
    unsigned char color = 0;
    unsigned int  i;

    clrscr();
    cputs("VIC-II COLOR CYCLING\r\n");
    cputs("PRESS ANY KEY TO STOP\r\n");

    while (!kbhit()) {
        VIC.bordercolor = color;
        VIC.bgcolor0    = color;
        color = (color + 1) & 15;   /* wrap around after 15 */

        for (i = 0; i < DELAY; i++)
            ;
    }

    VIC.bordercolor = COLOR_BLUE;
    VIC.bgcolor0    = COLOR_BLACK;

    clrscr();
    cputs("DONE.\r\n");
    return 0;
}
