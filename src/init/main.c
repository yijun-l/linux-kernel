#include "../include/linux/tty.h"
#include "../include/linux/kernel.h"

void kernel_entry(){
    console_init();
    asm("xchg bx, bx");
    printf("==> %s\n","Yijun");
    printf("==> %d\n",83777629);
    printf("==> %c\n",'C');

    while(1);
}