echo "Building kernel..."
$HOME/Desktop/Projects/os/toolchain/i686-elf/bin/i686-elf-gcc -ffreestanding -m32 -g -c "kernel.cpp" -o "kernel.o"
nasm "kernel_entry.asm" -f elf -o "kernel_entry.o"

echo "Linking kernel..."
$HOME/Desktop/Projects/os/toolchain/i686-elf/bin/i686-elf-ld -o "kernel.bin" -Ttext 0x1000 "kernel_entry.o" "kernel.o" --oformat binary

echo "Building bootloader..."
nasm "bootloader.asm" -f bin -o "bootloader.bin"

echo "Linking bootloader with kernel..."
cat "bootloader.bin" "kernel.bin" > "petOS.bin"

echo "Starting QEMU..."
qemu-system-x86_64 -drive format=raw,file="petOS.bin",index=0,if=floppy -m 128M
