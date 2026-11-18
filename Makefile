# ==============================================================================
# Makefile for STM32-Projects (Layer 3 Applications & Embedded Robotics)
# Target MCU: STM32F446RE (ARM Cortex-M4F)
# ==============================================================================

PROJECT ?= projects/line_follower_robot

# Toolchain configuration (override via environment or CLI: make ARM_TOOLCHAIN_DIR=...)
ifneq ($(ARM_TOOLCHAIN_DIR),)
    PREFIX = $(ARM_TOOLCHAIN_DIR)/arm-none-eabi-
else ifneq ($(wildcard /home/shubham/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/7-2017q4/bin/arm-none-eabi-gcc),)
    PREFIX = /home/shubham/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/7-2017q4/bin/arm-none-eabi-
else
    PREFIX = arm-none-eabi-
endif

export PREFIX

.PHONY: all clean size flash flash-stlink help test-submodules

all:
	@if [ -d "$(PROJECT)" ]; then \
		echo "======================================================================"; \
		echo "Building Project: $(PROJECT)"; \
		echo "======================================================================"; \
		$(MAKE) -C $(PROJECT) all; \
	else \
		echo "Project directory '$(PROJECT)' not found on current branch."; \
		echo "Switch to the project branch (e.g. git checkout project/line-follower-robot) or specify PROJECT=<path>."; \
		exit 1; \
	fi

clean:
	@if [ -d "$(PROJECT)" ]; then \
		echo "Cleaning project build artifacts in $(PROJECT)..."; \
		$(MAKE) -C $(PROJECT) clean; \
	else \
		echo "Project directory '$(PROJECT)' not found."; \
	fi

size:
	@if [ -d "$(PROJECT)" ]; then \
		$(MAKE) -C $(PROJECT) size; \
	else \
		echo "Project directory '$(PROJECT)' not found."; \
	fi

flash:
	@if [ -d "$(PROJECT)" ]; then \
		$(MAKE) -C $(PROJECT) flash; \
	else \
		echo "Project directory '$(PROJECT)' not found."; \
	fi

flash-stlink:
	@if [ -d "$(PROJECT)" ]; then \
		$(MAKE) -C $(PROJECT) flash-stlink; \
	else \
		echo "Project directory '$(PROJECT)' not found."; \
	fi

test-submodules:
	@echo "Testing Layer 1 (STM32-Library) build..."
	@$(MAKE) -C lib/STM32-Library all
	@echo "Testing Layer 2 (STM32-Components) build..."
	@$(MAKE) -C lib/STM32-Components EXAMPLE=examples/smoke_test LIB_DIR=../STM32-Library all
	@echo "All submodules built successfully!"

help:
	@echo "STM32-Projects Unified Build System"
	@echo "-----------------------------------"
	@echo "make                             : Build default project ($(PROJECT))"
	@echo "make PROJECT=projects/<name>     : Build specific project"
	@echo "make clean                       : Clean build directory for current project"
	@echo "make size                        : Print binary memory footprint"
	@echo "make flash                       : Program MCU via OpenOCD"
	@echo "make flash-stlink                : Program MCU via ST-Link utility"
	@echo "make test-submodules             : Validate builds of linked submodules"
