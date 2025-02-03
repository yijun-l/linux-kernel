# Function

A **function** (or **routine**) is a core programming concept. It is a reusable block of code designed to perform a specific task. 

Functions help organize code into logical units, improve readability, and reduce redundancy by allowing the same code to be executed multiple times with different inputs.

## Procedure 

When a function is called, the program follows a series of steps to execute it. 

Below is an example of how a function is accessed and executed in assembly language:

1. **Enter the Function**

    The function is called using a `call` instruction.

    ```asm
    call [subroutine]
    ```


2. **Create a Stack Frame**

    A stack frame is created to store local variables and function parameters.

    ```asm
    push ebp        ; Save the base pointer
    mov ebp, esp    ; Set the base pointer to the current stack pointer
    ```

3. **Save Context**

    Registers used by the function are saved to preserve the caller's context.

    ```asm
    push ebx        ; Save EBX
    push esi        ; Save ESI
    push edi        ; Save EDI
    ```

4. **Execute Function Logic**

    The function performs its intended task using the provided parameters and local variables.

5. **Restore Context**

    The saved registers are restored to their original values.


    ```asm
    pop edi         ; Restore EDI
    pop esi         ; Restore ESI
    pop ebx         ; Restore EBX
    ```

6. **Release the Stack Frame**

    The stack frame is released, and control is returned to the caller.

    ```asm
    leave           ; Equivalent to: mov esp, ebp; pop ebp
    ret             ; Return to the caller
    ```

## Calling convention

Calling conventions define the low-level rules for how functions receive parameters, return results, and manage the stack. 

These conventions ensure compatibility between different parts of a program and across programming languages.

### 32-bit Architecture (x86-32)

#### cdecl (Default for GCC)

- Parameters are pushed onto the stack from right to left.
- The caller is responsible for cleaning up the stack after the function call.
- The return value is stored in the EAX register.

#### stdcall (Default for Windows)

- Parameters are pushed onto the stack from right to left.
- The callee is responsible for cleaning up the stack.

#### fastcall

- The first two arguments (if they fit in registers) are passed in ECX and EDX.
- Remaining arguments are passed on the stack.

### 64-bit Architecture （x86-64）

#### System V AMD64 (Default for Unix-like Systems)

- The first six integer or pointer arguments are passed in registers: RDI, RSI, RDX, RCX, R8, R9.
- Additional arguments are passed on the stack.
- The return value is stored in the RAX register.

#### Microsoft x64 (Default for Windows)

- The first four arguments are passed in registers: RCX, RDX, R8, R9.
- Remaining arguments are passed on the stack.

## Variadic function

A variadic function in C is a function that can accept a variable number of arguments.

A common example of a variadic function is `printf` (`man 3 printf`), which takes a format string followed by a variable number of additional arguments.

### Variadic Function Macros for x86-32

In x86-32 architecture, variadic functions are implemented using macros that manipulate argument pointers, typically defined in `stdarg.h`.

```c
typedef char* va_list;

/* Move pointer p to the first variable argument */
#define va_start(p, count) (p = (va_list)&count + sizeof(char*))

/* Retrieve the next argument and advance the pointer */
#define va_arg(p, t) (*(t*)((p += sizeof(char*)) - sizeof(char*)))

/* Reset pointer p */
#define va_end(p) (p = 0)
```

### Implementing a printf()

The following implementation demonstrates how a simple `printf()` can be built using variadic functions:

```c
static int vsprintf(char *buf, const char *fmt, va_list args)
{
    char* str;
    char *tmp;

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
            default:
                break;
        }
    }
    return str - buf;
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
```