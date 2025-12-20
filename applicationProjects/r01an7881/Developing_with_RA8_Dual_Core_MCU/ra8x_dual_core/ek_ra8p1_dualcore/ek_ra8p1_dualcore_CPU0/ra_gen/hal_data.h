/* generated HAL header file - do not edit */
#ifndef HAL_DATA_H_
#define HAL_DATA_H_
#include <stdint.h>
#include "bsp_api.h"
#include "common_data.h"
#include "r_rtc.h"
#include "r_rtc_api.h"
#include "r_ipc.h"
#include "r_adc_b.h"
#include "r_adc_api.h"
FSP_HEADER
/* RTC Instance. */
extern const rtc_instance_t g_rtc;

/** Access the RTC instance using these structures when calling API functions directly (::p_api is not used). */
extern rtc_instance_ctrl_t g_rtc_ctrl;
extern const rtc_cfg_t g_rtc_cfg;

#ifndef rtc_callback
void rtc_callback(rtc_callback_args_t *p_args);
#endif
/** IPC Instance. */
extern const ipc_instance_t g_ipc1;

/** Access the IPC instance using these structures when calling API functions directly
 (::p_api is not used). */
extern ipc_instance_ctrl_t g_ipc1_ctrl;
extern const ipc_cfg_t g_ipc1_cfg;

#ifndef NULL
void NULL(ipc_callback_args_t *p_args);
#endif
/** IPC Instance. */
extern const ipc_instance_t g_ipc0;

/** Access the IPC instance using these structures when calling API functions directly
 (::p_api is not used). */
extern ipc_instance_ctrl_t g_ipc0_ctrl;
extern const ipc_cfg_t g_ipc0_cfg;

#ifndef ipc0_callback
void ipc0_callback(ipc_callback_args_t *p_args);
#endif
/** ADC on ADC_B instance. */
extern const adc_instance_t g_adc0;

/** Access the ADC_B instance using these structures when calling API functions directly (::p_api is not used). */
extern adc_b_instance_ctrl_t g_adc0_ctrl;
extern const adc_cfg_t g_adc0_cfg;
extern const adc_b_scan_cfg_t g_adc0_scan_cfg;

#ifndef NULL
void NULL(adc_callback_args_t *p_args);
#endif
void hal_entry(void);
void g_hal_init(void);
FSP_FOOTER
#endif /* HAL_DATA_H_ */
