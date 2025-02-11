#include "../include/linux/tty.h"
#include "../include/linux/kernel.h"
extern void x64_cpu_check();

void kernel_entry(){
    console_init();
    x64_cpu_check();
}