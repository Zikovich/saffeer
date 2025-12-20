/* generated HAL header file - do not edit */
#ifndef HAL_DATA_H_
#define HAL_DATA_H_
#include <stdint.h>
#include "bsp_api.h"
#include "common_data.h"
#include "r_ipc.h"
#include "r_dtc.h"
#include "r_transfer_api.h"
#include "r_sci_b_uart.h"
#include "r_uart_api.h"
FSP_HEADER
/** IPC Instance. */
extern const ipc_instance_t g_ipc1;

/** Access the IPC instance using these structures when calling API functions directly
 (::p_api is not used). */
extern ipc_instance_ctrl_t g_ipc1_ctrl;
extern const ipc_cfg_t g_ipc1_cfg;

#ifndef ipc1_callback
void ipc1_callback(ipc_callback_args_t *p_args);
#endif
/** IPC Instance. */
extern const ipc_instance_t g_ipc0;

/** Access the IPC instance using these structures when calling API functions directly
 (::p_api is not used). */
extern ipc_instance_ctrl_t g_ipc0_ctrl;
extern const ipc_cfg_t g_ipc0_cfg;

#ifndef NULL
void NULL(ipc_callback_args_t *p_args);
#endif
/* Transfer on DTC Instance. */
extern const transfer_instance_t g_transfer1;

/** Access the DTC instance using these structures when calling API functions directly (::p_api is not used). */
extern dtc_instance_ctrl_t g_transfer1_ctrl;
extern const transfer_cfg_t g_transfer1_cfg;
/* Transfer on DTC Instance. */
extern const transfer_instance_t g_transfer0;

/** Access the DTC instance using these structures when calling API functions directly (::p_api is not used). */
extern dtc_instance_ctrl_t g_transfer0_ctrl;
extern const transfer_cfg_t g_transfer0_cfg;
/** UART on SCI Instance. */
extern const uart_instance_t g_uart8;

/** Access the UART instance using these structures when calling API functions directly (::p_api is not used). */
extern sci_b_uart_instance_ctrl_t g_uart8_ctrl;
extern const uart_cfg_t g_uart8_cfg;
extern const sci_b_uart_extended_cfg_t g_uart8_cfg_extend;

#ifndef uart_callback
void uart_callback(uart_callback_args_t *p_args);
#endif
void hal_entry(void);
void g_hal_init(void);
FSP_FOOTER
#endif /* HAL_DATA_H_ */
