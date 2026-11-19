cmake_minimum_required(VERSION 3.16)

# ==============================================================================
# CMakeLists.txt for High-Speed Closed-Loop Line Follower Robot Firmware
# Target: STM32F446RE (ARM Cortex-M4F @ 180 MHz)
# ==============================================================================

set(APP_TARGET line_follower)

# Base paths
set(ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(COMP_DIR "${ROOT_DIR}/lib/STM32-Components")
set(ALGO_DIR "${ROOT_DIR}/lib/Embedded-Algorithms")

# Resolve Layer 1 directory
if(EXISTS "${ROOT_DIR}/lib/STM32-Library/Inc")
    set(LIB_DIR "${ROOT_DIR}/lib/STM32-Library")
elseif(EXISTS "${COMP_DIR}/lib/STM32-Library/Inc")
    set(LIB_DIR "${COMP_DIR}/lib/STM32-Library")
else()
    message(FATAL_ERROR "STM32-Library not found in lib/STM32-Library or lib/STM32-Components/lib/STM32-Library")
endif()

set(CMSIS_DIR "${LIB_DIR}/Drivers/CMSIS")

# Include directories
set(APP_INCLUDES
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    "${COMP_DIR}/include"
    "${LIB_DIR}/Inc"
    "${CMSIS_DIR}/Device/ST/STM32F4xx/Include"
    "${CMSIS_DIR}/Include"
)

if(EXISTS "${ALGO_DIR}/include")
    list(APPEND APP_INCLUDES "${ALGO_DIR}/include")
endif()

# Application Sources
file(GLOB_RECURSE APP_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c"
)

# Layer 1 Sources
set(LIB_SOURCES
    "${LIB_DIR}/Src/syscalls.c"
    "${LIB_DIR}/Src/sysmem.c"
    "${CMSIS_DIR}/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c"
    "${LIB_DIR}/Startup/startup_stm32f446retx.s"
    "${LIB_DIR}/Inc/stm32/common/systick/systick.cpp"
    "${LIB_DIR}/Inc/stm32/gpio/digital_input/digital_input.cpp"
    "${LIB_DIR}/Inc/stm32/gpio/digital_output/digital_output.cpp"
    "${LIB_DIR}/Inc/stm32/gpio/interrupt_input/interrupt_input.cpp"
    "${LIB_DIR}/Inc/stm32/exti/exti_manager.cpp"
    "${LIB_DIR}/Inc/stm32/exti/exti_irq.cpp"
    "${LIB_DIR}/Inc/stm32/timer/interrupt/timer_interrupt.cpp"
    "${LIB_DIR}/Inc/stm32/timer/interrupt/timer_irq.cpp"
    "${LIB_DIR}/Inc/stm32/uart/interrupt/uart_interrupt.cpp"
    "${LIB_DIR}/Inc/stm32/uart/interrupt/uart_irq.cpp"
    "${LIB_DIR}/Inc/stm32/spi/interrupt/spi_interrupt.cpp"
    "${LIB_DIR}/Inc/stm32/spi/interrupt/spi_irq.cpp"
    "${LIB_DIR}/Inc/stm32/i2c/interrupt/i2c_interrupt.cpp"
    "${LIB_DIR}/Inc/stm32/i2c/interrupt/i2c_irq.cpp"
    "${LIB_DIR}/Inc/stm32/adc/interrupt/adc_interrupt.cpp"
    "${LIB_DIR}/Inc/stm32/adc/interrupt/adc_irq.cpp"
    "${LIB_DIR}/Inc/stm32/dma/interrupt/dma_interrupt.cpp"
    "${LIB_DIR}/Inc/stm32/dma/interrupt/dma_irq.cpp"
)

add_executable(${APP_TARGET}.elf ${APP_SOURCES} ${LIB_SOURCES})

target_include_directories(${APP_TARGET}.elf PRIVATE ${APP_INCLUDES})

set(LDSCRIPT "${LIB_DIR}/STM32F446RETX_FLASH.ld")
target_link_options(${APP_TARGET}.elf PRIVATE
    -T${LDSCRIPT}
    -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/${APP_TARGET}.map,--cref
    -Wl,--gc-sections
    -specs=nano.specs
    -specs=nosys.specs
)

add_custom_command(TARGET ${APP_TARGET}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ${APP_TARGET}.elf ${APP_TARGET}.bin
    COMMAND ${CMAKE_OBJCOPY} -O ihex   ${APP_TARGET}.elf ${APP_TARGET}.hex
    COMMAND ${CMAKE_SIZE} --format=berkeley ${APP_TARGET}.elf
    COMMENT "Building raw flash binaries (.bin/.hex) and displaying memory footprint:"
)
