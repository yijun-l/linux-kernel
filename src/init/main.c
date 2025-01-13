#include "../include/linux/tty.h"

void kernel_entry(){
    console_init();
    while(1);
}