filename=$(basename $1 .asm)

nasm -felf64 -O0 -g $filename.asm
ld -g -o $filename $filename.o
rm $filename.o

