# ==============================================================================
# Makefile for Autonomous High-Speed Closed-Loop Line Follower Robot
# Target MCU: STM32F446RE (ARM Cortex-M4F @ 180 MHz)
# ==============================================================================

FIRMWARE_DIR = firmware

.PHONY: all clean size flash flash-stlink test-submodules help

all:
	@$(MAKE) -C $(FIRMWARE_DIR) all

clean:
	@$(MAKE) -C $(FIRMWARE_DIR) clean

size:
	@$(MAKE) -C $(FIRMWARE_DIR) size

flash:
	@$(MAKE) -C $(FIRMWARE_DIR) flash

flash-stlink:
	@$(MAKE) -C $(FIRMWARE_DIR) flash-stlink

test-submodules:
	@echo "Testing Layer 1 (STM32-Library) build..."
	@$(MAKE) -C lib/STM32-Library all
	@echo "Testing Layer 2 (STM32-Components) build..."
	@$(MAKE) -C lib/STM32-Components EXAMPLE=examples/smoke_test LIB_DIR=../STM32-Library all
	@echo "All submodules built successfully!"

help:
	@echo "Autonomous Line Follower Robot Build System"
	@echo "------------------------------------------"
	@echo "make              : Build firmware binary"
	@echo "make clean        : Clean build directory"
	@echo "make size         : Print binary memory footprint"
	@echo "make flash        : Flash via OpenOCD"
	@echo "make flash-stlink : Flash via ST-Link utility"
	@echo "make test-submodules : Validate builds of linked submodules"
