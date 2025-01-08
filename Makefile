BUILD := ./build
SOURCE := ./src
HD_IMG_NAME := "hd.img"

CFLAGS := -m32						# generate code for 32-bit ABI
CFLAGS += -masm=intel				# output assembly instructions using "intel" (default is "att")
CFLAGS += -fno-builtin				# disable GCC built-in functions (for performance purpose)
CFLAGS += -nostdinc					# do not search the standard system directories for header files
CFLAGS += -fno-pic					# generate non position independent code (pic) which is the code can be loaded and executed at any memory address, which is essential for shared libraries
CFLAGS += -fno-stack-protector		# disable the stack protector feature
CFLAGS := $(strip ${CFLAGS})
DEBUG := -g

LD_FLAGS := -m i386pe				# specify produce an ELF binary file for Intel x86 architecture (32-bit).
LD_FLAGS += -Ttext=0x900

OC_FLAGS := -O binary				# specify the output is raw binary data (flat binary) without metadata info in object file

# QEMU Options
QEMU_FLAGS := -m 32M				# set guest startup RAM size
QEMU_FLAGS += -hda ${HD_IMG_NAME}	# specify hard disk 0 image

QEMU_DEBUG_FLAGS := -S				# do not start CPU at startup (you must type 'c' in the monitor)
QEMU_DEBUG_FLAGS += -gdb tcp::6666	# accept a gdb connection on device


all: ${BUILD}/boot/boot.o ${BUILD}/boot/head.o ${BUILD}/kernel.bin
	$(shell rm -rf $(HD_IMG_NAME))
	bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat $(HD_IMG_NAME)
	dd if=${BUILD}/boot/boot.o of=hd.img bs=512 seek=0 count=1 conv=notrunc
	dd if=${BUILD}/boot/head.o of=hd.img bs=512 seek=1 count=2 conv=notrunc
	dd if=${BUILD}/kernel.bin of=hd.img bs=512 seek=3 count=30 conv=notrunc

${BUILD}/boot/%.o: ${SOURCE}/boot/%.asm
	$(shell mkdir -p ${BUILD}/boot)
	nasm $< -o $@

${BUILD}/kernel.bin: ${BUILD}/kernel.pe
	objcopy ${OC_FLAGS} $< $@

# compile C and ASM code to object file, and link them to PE file
${BUILD}/kernel.pe: ${BUILD}/init/main.o
	ld ${LD_FLAGS} $^ -o $@

${BUILD}/init/main.o: ${SOURCE}/init/main.c
	$(shell mkdir -p ${BUILD}/init)
	gcc ${CFLAGS} ${DEBUG} -c $< -o $@

clean:
	$(shell rm -rf ${BUILD})
    $(shell rm -f ${HD_IMG_NAME}*)

bochs: all
	bochsdbg -q -f bochsrc

qemu: all
	qemu-system-i386 ${QEMU_FLAGS}

dqemu: all
	qemu-system-i386 ${QEMU_FLAGS} ${QEMU_DEBUG_FLAGS}