out/ipaddr: src/ipaddr.nim
	nim --define:release --opt:size --out:$(abspath $@) compile $<
	@strip $(abspath $@)
