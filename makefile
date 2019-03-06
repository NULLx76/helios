
version = 0.0.1
arch ?= x86_64

LINKER = gcc
CC = gcc
ASM = gcc
NASM = nasm

TESTFILE = test.hel

#names
executable_fullname := helios-$(version)-$(arch)
executable := bin/$(executable_fullname)

#include paths
dirs = $(shell find src/ -type d -print)
includedirs :=  $(sort $(foreach dir, $(foreach dir1, $(dirs), $(shell dirname $(dir1))), $(wildcard $(dir)/include)))

LFLAGS =

#flags
CFLAGS= -g -O2

#automatically include any header in dirs called include
CFLAGS += $(foreach dir, $(includedirs), -I./$(dir))

#assembly
ASMFLAGS = 
ASMFLAGS += $(foreach dir, $(includedirs), -I./$(dir))

NASMFLAGS = 

#support for .S
assembly_source_files := $(foreach dir,$(dirs),$(wildcard $(dir)/*.S))
assembly_object_files := $(patsubst src/%.S, \
	build/%.o, $(assembly_source_files))

#support for .asm
nassembly_source_files := $(foreach dir,$(dirs),$(wildcard $(dir)/*.asm))
nassembly_object_files := $(patsubst src/%.asm, \
	build/%.o, $(nassembly_source_files))


c_source_files := $(foreach dir,$(dirs),$(wildcard $(dir)/*.c))
c_object_files := $(patsubst src/%.c, \
    build/%.o, $(c_source_files))
#qemu

.PHONY: all clean run

all: $(executable)


clean:
	@rm -r build
	@rm -r bin

run: $(executable)
	@echo starting
	@./$(executable) $(TESTFILE)

$(executable): $(assembly_object_files) $(c_object_files) $(nassembly_object_files)
	@echo linking...
	@mkdir -p bin
	@$(LINKER) $(LFLAGS) -o $(executable) $(assembly_object_files) $(nassembly_object_files) $(c_object_files)


# compile assembly files
build/%.o: src/%.S
	@mkdir -p $(shell dirname $@)
	@echo compiling $<
	@$(ASM) -c $(ASMFLAGS) $< -o $@

# compile assembly files
build/%.o: src/%.asm
	@mkdir -p $(shell dirname $@)
	@echo compiling $<
	@$(NASM) $(NASMFLAGS) $< -o $@

# compile c files
build/%.o: src/%.c
	@mkdir -p $(shell dirname $@)
	@echo compiling $<
	@$(CC) -c $(CFLAGS) $< -o $@