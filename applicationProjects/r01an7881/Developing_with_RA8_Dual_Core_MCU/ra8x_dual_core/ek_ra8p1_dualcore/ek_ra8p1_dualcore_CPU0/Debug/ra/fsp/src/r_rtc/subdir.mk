################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../ra/fsp/src/r_rtc/r_rtc.c 

C_DEPS += \
./ra/fsp/src/r_rtc/r_rtc.d 

CREF += \
ek_ra8p1_dualcore_CPU0.cref 

OBJS += \
./ra/fsp/src/r_rtc/r_rtc.o 

MAP += \
ek_ra8p1_dualcore_CPU0.map 


# Each subdirectory must supply rules for building sources it contributes
ra/fsp/src/r_rtc/%.o: ../ra/fsp/src/r_rtc/%.c
	@echo 'Building file: $<'
	$(file > $@.in,-mcpu=cortex-m85 -mthumb -mlittle-endian -mfloat-abi=hard -O2 -ffunction-sections -fdata-sections -fno-strict-aliasing -fmessage-length=0 -funsigned-char -Wunused -Wuninitialized -Wall -Wextra -Wmissing-declarations -Wconversion -Wpointer-arith -Wshadow -Waggregate-return -Wno-parentheses-equality -Wfloat-equal -g3 -std=c99 -flax-vector-conversions -fshort-enums -fno-unroll-loops -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU0\\src" -I"." -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU0\\ra\\fsp\\inc" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU0\\ra\\fsp\\inc\\api" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU0\\ra\\fsp\\inc\\instances" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU0\\ra\\arm\\CMSIS_6\\CMSIS\\Core\\Include" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU0\\ra_gen" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU0\\ra_cfg\\fsp_cfg\\bsp" -I"C:\\Users\\zikot\\Documents\\ra-fsp-examples-master\\application_projects\\r01an7881\\Developing_with_RA8_Dual_Core_MCU\\ra8x_dual_core\\ek_ra8p1_dualcore\\ek_ra8p1_dualcore_CPU0\\ra_cfg\\fsp_cfg" -D_RENESAS_RA_ -D_RA_CORE=CPU0 -D_RA_ORDINAL=1 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -x c "$<" -c -o "$@")
	@clang --target=arm-none-eabi @"$@.in"

