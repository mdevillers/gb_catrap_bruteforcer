## catrap gb game password bruteforcer

This program iterates and tests the validity of each possible password combination. 

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
## output

To remove level duplicates launch the script <gen_password.sh>
```
bash ./gen_passwords.sh
<level> <password>
01 0803
02 0H07
03 0R0A
04 100F
05 180J
...
```

