cmake_minimum_required(VERSION 3.16)

# ==============================================================================
# CMakeLists.txt for STM32-Line-Follower-Robot
# Target: STM32F446RE (ARM Cortex-M4F @ 180 MHz)
# ==============================================================================

project(STM32-Line-Follower-Robot LANGUAGES C CXX ASM)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Hardware Defines
add_compile_definitions(STM32F446xx COMPONENTS_DISABLE_DEPRECATION_WARNINGS)

# Architecture & Optimization Flags
set(MCU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${MCU_FLAGS} -Wall -Wextra -Wpedantic -O2 -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${MCU_FLAGS} -Wall -Wextra -Wpedantic -O2 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fno-use-cxa-atexit")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${MCU_FLAGS}")

# Primary Firmware Executable Target
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/firmware/CMakeLists.txt")
    add_subdirectory(firmware)
endif()
