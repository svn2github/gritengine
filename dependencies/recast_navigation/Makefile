# Usage: make [config=name], name: debug/release

ifndef config
  config=debug
endif
export config

PROJECT := RecastDetour

.PHONY: all clean $(PROJECT)

all: $(PROJECT)

RecastDetour: 
	@echo "==== Building RecastDetour ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f RecastDetour.make

clean:
	@${MAKE} --no-print-directory -C . -f RecastDetour.make clean
