#ifndef _STDARG_H
#define _STDARG_H

typedef char* va_list;

/* Move pointer p to the first variable argument */
#define va_start(p, count) (p = (va_list)&count + sizeof(char*))

/* Retrieve the next argument and advance the pointer */
#define va_arg(p, t) (*(t*)((p += sizeof(char*)) - sizeof(char*)))

/* Reset pointer p */
#define va_end(p) (p = 0)

#endif
