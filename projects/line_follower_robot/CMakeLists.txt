cmake_minimum_required(VERSION 3.16)

# ==============================================================================
# CMakeLists.txt for Line Follower Robot (Layer 3 Project)
# Target: STM32F446RE (ARM Cortex-M4F)
# ==============================================================================

set(PROJECT_TARGET line_follower_robot)

# Submodule directories
set(LIB_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/../../lib/STM32-Library")
set(COMP_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/../../lib/STM32-Components")
set(CMSIS_DIR "${LIB_DIR}/Drivers/CMSIS")

# Include directories
set(PROJECT_INCLUDES
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    "${COMP_DIR}/include"
    "${LIB_DIR}/Inc"
    "${CMSIS_DIR}/Device/ST/STM32F4xx/Include"
    "${CMSIS_DIR}/Include"
)

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

add_executable(${PROJECT_TARGET}.elf ${APP_SOURCES} ${LIB_SOURCES})

target_include_directories(${PROJECT_TARGET}.elf PRIVATE ${PROJECT_INCLUDES})

set(LDSCRIPT "${LIB_DIR}/STM32F446RETX_FLASH.ld")
target_link_options(${PROJECT_TARGET}.elf PRIVATE
    -T${LDSCRIPT}
    -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_TARGET}.map,--cref
    -Wl,--gc-sections
    -specs=nano.specs
    -specs=nosys.specs
)
