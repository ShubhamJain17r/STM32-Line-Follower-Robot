cmake_minimum_required(VERSION 3.16)

# ==============================================================================
# CMakeLists.txt for STM32-Projects (Layer 3 Applications)
# Target: STM32F446RE (ARM Cortex-M4F)
# ==============================================================================

project(STM32-Projects LANGUAGES C CXX ASM)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Hardware Defines
add_compile_definitions(STM32F446xx)

# Architecture & Optimization Flags
set(MCU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${MCU_FLAGS} -Wall -Wextra -Wpedantic -O2 -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${MCU_FLAGS} -Wall -Wextra -Wpedantic -O2 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fno-use-cxa-atexit")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${MCU_FLAGS}")

# Submodule Paths
set(STM32_LIBRARY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/STM32-Library")
set(STM32_COMPONENTS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/STM32-Components")

# Consumer Applications (Layer 3)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/apps/line_follower/CMakeLists.txt")
    add_subdirectory(apps/line_follower)
endif()

# Legacy / Standalone Projects
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/projects/line_follower_robot/CMakeLists.txt")
    add_subdirectory(projects/line_follower_robot)
endif()
