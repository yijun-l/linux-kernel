#include "../include/stdarg.h"
#include "../include/linux/tty.h"

/* conver an integer to a string */
static void itos(int num, char* buf)
{
    int i = 0;
    int is_negative = 0;

    /* handle negative numbers */
    if(num < 0){
        is_negative = 1;
        num = -num;
    }

    /* convert each digit in reverse order */
    while(num > 0){
        *(buf + i++) = num % 10 + '0';
        num /= 10;
    }

    /* add the negative sign if necessary */
    if(is_negative){
        *(buf + i++) = '-';
    }

    /* Null-terminate the string */
    *(buf + i) = '\0';

    /* reverse the string to get the correct order */
    int len = i;
    for(int j = 0; j < len/2; j++){
        char tmp = *(buf + j);
        *(buf + j) = *(buf + i - j - 1);
        *(buf + i - j - 1) = tmp;
    }
}

/* Convert an integer to a hexadecimal string */
static void hex_itos(unsigned int num, char* buf) {
    int i = 0;

    /* Special case for zero */
    if (num == 0) {
        buf[i++] = '0';
        buf[i] = '\0';
        return;
    }

    /* Convert each digit in reverse order */
    while (num > 0) {
        int digit = num % 16;
        buf[i++] = (digit < 10) ? (digit + '0') : (digit - 10 + 'A');
        num /= 16;
    }

    /* Null-terminate the string */
    buf[i] = '\0';

    /* Reverse the string to get the correct order */
    int len = i;
    for (int j = 0; j < len / 2; j++) {
        char tmp = buf[j];
        buf[j] = buf[len - j - 1];
        buf[len - j - 1] = tmp;
    }
}

static int vsprintf(char *buf, const char *fmt, va_list args)
{
    char* str;
    char format_buf[128] = " ";
    char *tmp = format_buf;

    for(str=buf ; *fmt ; ++fmt){
        if(*fmt != '%'){
            *str++ = *fmt;
            continue;
        }
        fmt++;      /* skip first '%' */
        switch(*fmt){
            case 'c':
                *str++ = va_arg(args, char);
                break;
            case 'd':
                itos(va_arg(args, int), tmp);
                while(*tmp){
                    *str++ = *tmp++;
                }
                break;
            case 's':
                tmp = va_arg(args, char*);
                while(*tmp){
                    *str++ = *tmp++;
                }
                break;
            case 'x':
                hex_itos(va_arg(args, int), tmp);
                while(*tmp){
                    *str++ = *tmp++;
                }
                break;
            default:
                break;
        }
    }
    return str - buf;
}

/* write to buffer */
int sprintf(char* buf, const char *fmt, ...)
{
    va_list args;
    int i;

    va_start(args, fmt);
    i = vsprintf(buf, fmt, args);
    va_end(args);

    return i;
}

/* write to console */
int printf(const char *fmt, ...)
{
    va_list args;
    int i;
    char buf[2000] = " ";
    va_start(args, fmt);
    i = vsprintf(buf, fmt, args);
    console_write(buf);
    va_end(args);

    return i;
}