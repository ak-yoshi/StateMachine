# makefile

# define compiler
GCC := gcc
GPP := g++

# define suffix
SRC_SUFFIX := .c .cpp

# define flags
CFLAGS  := -std=c++20

# define source, object and dependency directory path
SRC_PATH := $(shell find src unit_test -type d)
OBJ_PATH := bin/obj
BIN_PATH := bin

# define include path
INCLUDE := -I$(subst :, -I, $(CPATH)) $(foreach dir, $(SRC_PATH), -I/$(dir))

# define path for source, object and dependency file
SRCS := $(foreach suffix, $(SRC_SUFFIX), $(filter %$(suffix), $(foreach dir, $(SRC_PATH), $(wildcard $(dir)/*))))
OBJS := $(addprefix $(OBJ_PATH)/, $(foreach suffix, $(SRC_SUFFIX), $(filter %.o, $(patsubst %$(suffix), %$(suffix).o, $(SRCS)))))
DEPS := $(addprefix $(OBJ_PATH)/, $(foreach suffix, $(SRC_SUFFIX), $(filter %.d, $(patsubst %$(suffix), %$(suffix).d, $(SRCS)))))
LNKS := $(addprefix $(OBJ_PATH)/, link.l)
TARGET := $(BIN_PATH)/out

# task
.PHONY: all clean
all: $(TARGET)

# link
$(TARGET):$(OBJS)
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(GPP) -o $@ $^

# compile .c -> .c.o
$(OBJ_PATH)/%.c.o:%.c
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(GCC) -o $@ -c $< $(CFLAGS) $(INCLUDE)

# compile .cpp -> .cpp.o
$(OBJ_PATH)/%.cpp.o:%.cpp
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(GPP) -o $@ -c $< $(CFLAGS) $(INCLUDE)

# make dependency .c -> .c.d
$(OBJ_PATH)/%.c.d: %.c
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	@$(GCC) -MM -MP $(INCLUDE) $< | sed -e '1s:\(.*\)\.o:$(@:%.d=%.o):' > $@

# make dependency .cpp -> .cpp.d
$(OBJ_PATH)/%.cpp.d: %.cpp
	@if [ ! -e `dirname $@` ]; then mkdir -p `dirname $@`; fi
	@$(GPP) -MM -MP $(INCLUDE) $< | sed -e '1s:\(.*\)\.o:$(@:%.d=%.o):' > $@

-include $(DEPS)

# echo
info:
	@echo "[Infomation]"
	@echo "TARGET = " $(TARGET)
	@echo "SRC_PATH = " $(SRC_PATH)
	@echo "SRCS = " $(SRCS)
	@echo "OBJS = " $(OBJS)
	@echo "DEPS = " $(DEPS)
	@echo "LNKS = " $(LNKS)

# clean
clean:
	rm -rf $(BIN_PATH)/* $(OBJ_PATH)/*