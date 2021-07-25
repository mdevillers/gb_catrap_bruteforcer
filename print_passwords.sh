echo "<level> <password>"
./bruteforcer | sort -k 2 | awk '{print $2 " " $1}' | uniq -w 2
