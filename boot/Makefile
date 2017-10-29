
NASM = nasm
BINDIR = bin
SRCDIR = src
EMU = qemu-system-i386.exe

SRCS = $(wildcard $(SRCDIR)/*.asm)

EXE = bootloader.bin
MAIN_ASM = bootloader.asm

$(BINDIR)/$(EXE): $(SRCS)
	$(NASM) -f bin $(SRCDIR)/$(MAIN_ASM) -o $@
	
.PHONY: boot
boot: $(BINDIR)/$(EXE)

.PHONY: run
run: boot
	$(EMU) -fda $(BINDIR)/$(EXE)