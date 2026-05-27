# =========================================================
# Make.M - Modular Build Layer
# Reusable system definitions for gmake
# =========================================================

# -------------------------
# Compiler detection
# -------------------------
CC ?= cc

ifeq ($(OS),Windows_NT)
	CC = gcc
endif

SYS := $(shell $(CC) -dumpmachine 2>/dev/null)

# Auto fallback compiler
ifeq ($(origin CC), default)
	ifneq (, $(shell which clang 2>/dev/null))
		CC = clang
	else ifneq (, $(shell which gcc 2>/dev/null))
		CC = gcc
	else
		CC = cc
	endif
endif

# -------------------------
# Core directories
# -------------------------
SRC_DIR := src
TMP_DIR := tmp
BIN_DIR := bin

# -------------------------
# Versioning
# -------------------------
GITVER := $(shell git describe --tags 2>/dev/null)
ifeq ($(GITVER),)
	GITVER := unknown
endif

# -------------------------
# Platform libs
# -------------------------
LIBS =
INCLUDES =
FLAGS2 =
INSTALL_FLAGS = -pDm755

ifneq (, $(findstring linux, $(SYS)))
	LIBS = -lm -lrt -ldl -lpthread
endif

ifneq (, $(findstring darwin, $(SYS)))
	LIBS = -lm
endif

ifneq (, $(findstring mingw, $(SYS)))
	LIBS = -lWs2_32 -lIPHLPAPI
	INCLUDES = -Ivs10/include
endif

# -------------------------
# Standard flags
# -------------------------
DEFINES =
CFLAGS = -g -O2 -Wall $(INCLUDES) $(DEFINES) $(FLAGS2)

# -------------------------
# Helpers (reusable macros)
# -------------------------

define compile_c
	@mkdir -p $(TMP_DIR)
	$(CC) $(CFLAGS) -c $< -o $@ -DGIT=\"$(GITVER)\"
endef

define link_bin
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)
endef

define clean_all
	rm -rf $(TMP_DIR) $(BIN_DIR)
endef

# -------------------------
# Targets (optional hooks)
# -------------------------
.PHONY: clean help

help:
	@echo "Make.M module loaded"
	@echo "Use: include Make.M in your main Makefile"

clean:
	$(call clean_all)
