out/ipaddr: src/main.c
	gcc -std=c99 $< -o $@
	strip $@
