## catrap gb game password bruteforcer

This program iterates and tests the validity of each possible password combination. 
More details [here](https://github.com/mdevillers/mdevillers.github.io/catrap.md)

## assemble (64-bit only)
```
bash ./assemble.sh bruteforcer.asm
```
or
```
nasm -felf64 -O0 -g bruteforcer.asm
ld -g -o bruteforcer bruteforcer.o
rm bruteforcer.o
```
