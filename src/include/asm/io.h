#ifndef _ASM_IO_H
#define _ASM_IO_H

#include "../linux/types.h"

/* Get a value from a specific port, "IN AL, DX" */
u8 inb(u16 port);

/* Push a value to a specific port, "OUT DX, AL" */
void outb(u16 port, u8 data);

#endif