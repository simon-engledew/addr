PLATFORM := $(shell uname -s | tr A-Z a-z)

out/$(PLATFORM)/addr: src/main.c
	mkdir -p $(dir $@)
	gcc -std=c99 $< -o $@
	strip $@

ifeq (darwin,$(PLATFORM))
out/linux/addr: src/main.c
	docker run -v "$(abspath .):/workspace" -w /workspace --rm $$(docker build -q docker) make $@
endif

out/addr-%-amd64.tgz: out/%/addr
	(cd $(dir $<); tar cvzpf $(abspath $@) $(notdir $<))
