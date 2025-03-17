SCAD=openscad
BASEFILE=../TapeSpooler.scad

TARGETS=$(shell sed '/^module [a-z0-9_-]*\(\).*make..\?me.*$$/!d;s/module //;s/().*/.stl/' $(BASEFILE))

all: ${TARGETS}

.SECONDARY: $(shell echo "${TARGETS}" | sed 's/\.stl/.scad/g')

include $(wildcard *.deps)

%.scad: Makefile
	echo "Gerando arquivo: $@ (chamando $*())"
	printf 'use <$(BASEFILE)>\n$*();' > $@

%.stl: %.scad
	openscad --export-format binstl -m make -o $@ -d $@.deps $<
