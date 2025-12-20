################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../ra/fsp/src/bsp/cmsis/Device/RENESAS/Source/startup.c \
../ra/fsp/src/bsp/cmsis/Device/RENESAS/Source/system.c 

C_DEPS += \
./ra/fsp/src/bsp/cmsis/Device/RENESAS/Source/startup.d \
./ra/fsp/src/bsp/cmsis/Device/RENESAS/Source/system.d 

CREF += \
ek_ra8p1_dualcore_CPU1.cref 

OBJS += \
./ra/fsp/src/bsp/cmsis/Device/RENESAS/Source/startup.o \
./ra/fsp/src/bsp/cmsis/Device/RENESAS/Source/system.o 

MAP += \
ek_ra8p1_dualcore_CPU1.map 


# Each subdirectory must supply rules for building sources it contributes
ra/fsp/src/bsp/cmsis/Device/RENESAS/Source/%.o: ../ra/fsp/src/bsp/cmsis/Device/RENESAS/Source/%.c
	@echo 'Building file: $<'
	$(file > $@.in,-mcpu=cortex-m33 -mthumb -mlittle-endian -mfloat-abi=hard -mfpu=fpv5-sp-d16 -O2 -ffunction-sections -fdata-sections -fno-strict-aliasing -fmessage-length=0 -funsigned-char -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wshadow -Waggregate-return -Wno-parentheses-equality -Wfloat-equal -g3 -std=c99 -fshort-enums -fno-unroll-loops -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU1\\src" -I"." -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU1\\ra\\fsp\\inc" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU1\\ra\\fsp\\inc\\api" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU1\\ra\\fsp\\inc\\instances" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU1\\ra\\arm\\CMSIS_6\\CMSIS\\Core\\Include" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU1\\ra_gen" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU1\\ra_cfg\\fsp_cfg\\bsp" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU1\\ra_cfg\\fsp_cfg" -D_RENESAS_RA_ -D_RA_CORE=CPU1 -D_RA_ORDINAL=2 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -x c "$<" -c -o "$@")
	@clang --target=arm-none-eabi @"$@.in"

