# generate a list of passwords without duplicates
./bruteforcer | sort -k 2 | awk '{print $2 " " $1}' | uniq -w 2

