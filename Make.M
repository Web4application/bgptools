# =========================================================
# Web4 / System Orchestrator Build Engine
# =========================================================

SHELL := /bin/bash

CC ?= cc
PY ?= python3
NODE ?= node

TARGET := bin/masscan
SRC := $(wildcard src/*.c)
OBJ := $(patsubst src/%.c, tmp/%.o, $(SRC))

PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin

GITVER := $(shell git describe --tags 2>/dev/null)
ifeq ($(GITVER),)
GITVER := unknown
endif

SYS := $(shell $(CC) -dumpmachine 2>/dev/null)

# =========================================================
# PLATFORM LIBS
# =========================================================

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

# =========================================================
# GLOBAL FLAGS
# =========================================================

DEFINES =
CFLAGS = -g -O2 -Wall $(INCLUDES) $(DEFINES) $(FLAGS2)

# =========================================================
# DEFAULT
# =========================================================

all: build-native

# =========================================================
# CORE BUILD (C ENGINE)
# =========================================================

build-native: $(TARGET)

$(TARGET): $(OBJ)
	@mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

tmp/%.o: src/%.c src/*.h
	@mkdir -p tmp
	$(CC) $(CFLAGS) -c $< -o $@ -DGIT=\"$(GITVER)\"

# =========================================================
# WEB4 LAYER (JS / frontend build)
# =========================================================

web4-install:
	@echo "Installing Web4 frontend deps..."
	@if [ -f package.json ]; then npm install; fi

web4-dev:
	@echo "Starting Web4 dev server..."
	@if [ -f package.json ]; then npm run dev; fi

web4-build:
	@echo "Building Web4 frontend..."
	@if [ -f package.json ]; then npm run build; fi

# =========================================================
# FASTAPI LAYER
# =========================================================

api-install:
	$(PY) -m pip install -r requirements.txt

api-dev:
	uvicorn main:app --reload --host 0.0.0.0 --port 8000

api-run:
	$(PY) main.py

# =========================================================
# BLOCKCHAIN / CONTRACT LAYER (Fadaka-style hooks)
# =========================================================

contract-compile:
	@echo "Compiling smart contracts..."
	@if [ -f hardhat.config.js ]; then npx hardhat compile; fi

contract-deploy:
	@echo "Deploying contracts..."
	@if [ -f hardhat.config.js ]; then npx hardhat run scripts/deploy.js; fi

contract-test:
	@if [ -f hardhat.config.js ]; then npx hardhat test; fi

# =========================================================
# PEER / NETWORK LAYER (Go / TLS nodes etc)
# =========================================================

peer-build:
	@echo "Building peer node..."
	@if [ -f go.mod ]; then go build -o bin/peer ./...; fi

peer-run:
	@echo "Starting peer network..."
	@if [ -f bin/peer ]; then ./bin/peer; fi

# =========================================================
# FULL SYSTEM ORCHESTRATION
# =========================================================

dev:
	@echo "Starting FULL DEV STACK..."
	@$(MAKE) api-dev &
	@$(MAKE) web4-dev &
	@echo "Dev stack running."

build-all:
	@$(MAKE) build-native
	@$(MAKE) web4-build
	@$(MAKE) contract-compile
	@$(MAKE) peer-build

run-all:
	@$(MAKE) api-run &
	@./bin/masscan

# =========================================================
# UTILITIES
# =========================================================

clean:
	rm -rf tmp bin

install:
	install $(INSTALL_FLAGS) bin/masscan $(DESTDIR)$(BINDIR)/masscan

logs:
	@echo "No logging system attached yet — hook your FastAPI or Go logs here"

doctor:
	@echo "Checking environment..."
	@which $(CC) || echo "C compiler missing"
	@which $(PY) || echo "Python missing"
	@which node || echo "Node missing"
	@which go || echo "Go missing"

# =========================================================
# SHORTCUTS
# =========================================================

default: all
