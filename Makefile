.PHONY: all build run buildFolder
SRC=$(wildcard ./src/boot/*.asm)

all: buildFolder build run

buildFolder:
	@mkdir -p build

build: buildFolder
	nasm -f bin $(SRC) -o build/bootloader.bin

run: buildFolder build
	qemu-system-i386 -drive file=build/bootloader.bin,format=raw -audiodev pa,id=audio0 -machine pcspk-audiodev=audio0
