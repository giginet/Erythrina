REPO_ROOT := $(shell git rev-parse --show-toplevel)
PRODUCT := Erythrina.pdx
SRC += $(REPO_ROOT)/Sources/CPlaydate/playdate.c
include $(REPO_ROOT)/swift.mk

# MARK: - Build Game Swift Object
build/game_device.o: Sources/*.swift
	$(SWIFT_EXEC) $(SWIFT_FLAGS) $(SWIFT_FLAGS_DEVICE) -c $^ -o $@
$(OBJDIR)/pdex.elf: build/game_device.o
OBJS += build/game_device.o

build/game_simulator.o: Sources/*.swift
	$(SWIFT_EXEC) $(SWIFT_FLAGS) $(SWIFT_FLAGS_SIMULATOR) -c $^ -o $@
$(OBJDIR)/pdex.${DYLIB_EXT}: build/game_simulator.o
SIMCOMPILER += build/game_simulator.o
