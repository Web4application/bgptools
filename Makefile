# -----------------------------
# Cross-platform build system
# -----------------------------

CC ?= cc

# Detect OS
UNAME_S := $(shell uname -s 2>/dev/null)

# Default Windows override (MinGW / MSYS)
ifeq ($(OS),Windows_NT)
    CC = gcc
endif

# Auto-detect compiler if not set
ifeq ($(origin CC), default)
    ifneq (, $(shell which clang 2>/dev/null))
        CC = clang
    else ifneq (, $(shell which gcc 2>/dev/null))
        CC = gcc
    else
        CC = cc
    endif
endif

# -----------------------------
# Project metadata
# -----------------------------
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin

SYS := $(shell $(CC) -dumpmachine 2>/dev/null)
GITVER := $(shell git describe --tags 2>/dev/null)

ifeq ($(GITVER),)
    GITVER := unknown
endif

# -----------------------------
# Platform configuration
# -----------------------------

LIBS =
INCLUDES =
FLAGS2 =
INSTALL_DATA = -pDm755

# Linux
ifneq (, $(findstring linux, $(SYS)))
    ifneq (, $(findstring musl, $(SYS)))
        LIBS =
    else
        LIBS = -lm -lrt -ldl -lpthread
    endif
endif

# macOS
ifneq (, $(findstring darwin, $(SYS)))
    LIBS = -lm
    INCLUDES = -I.
    INSTALL_DATA = -pm755
endif

# MinGW / MSYS
ifneq (, $(findstring mingw, $(SYS)))
    INCLUDES = -Ivs10/include
    LIBS = -Lvs10/lib -lIPHLPAPI -lWs2_32
endif

# Cygwin
ifneq (, $(findstring cygwin, $(SYS)))
    INCLUDES = -I.
    LIBS =
endif

# BSD variants
ifneq (, $(findstring bsd, $(SYS)))
    LIBS = -lm -lpthread
    INCLUDES = -I.
endif

# -----------------------------
# Compiler flags
# -----------------------------
DEFINES =
CFLAGS = -g -ggdb $(FLAGS2) $(INCLUDES) $(DEFINES) -Wall -O2

# -----------------------------
# Build directories
# -----------------------------
SRC = $(wildcard src/*.c)
OBJ = $(patsubst src/%.c, tmp/%.o, $(SRC))

# Output
TARGET = bin/masscan

# -----------------------------
# Default target
# -----------------------------
all: $(TARGET)

# -----------------------------
# Link step
# -----------------------------
$(TARGET): $(OBJ)
	@mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(LIBS)

# -----------------------------
# Compile step
# -----------------------------
tmp/%.o: src/%.c src/*.h
	@mkdir -p tmp
	$(CC) $(CFLAGS) -c $< -o $@ -DGIT=\"$(GITVER)\"

# -----------------------------
# Cleanup
# -----------------------------
clean:
	rm -rf tmp/*.o bin/masscan

# -----------------------------
# Test
# -----------------------------
regress: $(TARGET)
	./bin/masscan --selftest

test: regress

# -----------------------------
# Install
# -----------------------------
install: $(TARGET)
	install $(INSTALL_DATA) bin/masscan $(DESTDIR)$(BINDIR)/masscan

# -----------------------------
# Aliases
# -----------------------------
default: all
