/***********************************************************************************************************************
 * File Name    : audio_sawtooth_signal.h
 * Description  : Sawtooth wave generator - 192 bytes per full period
 **********************************************************************************************************************/
#ifndef AUDIO_SAWTOOTH_SIGNAL_H
#define AUDIO_SAWTOOTH_SIGNAL_H

#include <stdint.h>

/*******************************************************************************
 * CONFIGURATION
 ******************************************************************************/

/** Enable/disable sawtooth generator (1 = enabled, 0 = disabled) */
#define SAWTOOTH_GENERATOR_ENABLE       (1)

/** Frame size in bytes (192 = 48 stereo samples at 16-bit) */
#define SAWTOOTH_FRAME_SIZE_BYTES       (192U)

/** Number of stereo sample pairs per frame */
#define SAWTOOTH_SAMPLES_PER_FRAME      (48U)

/** 
 * Increment per sample to span full 16-bit range in one period
 * Range: -32767 to +32767 = 65534 total
 * Increment = 65534 / (48 - 1) = 1394 (approximately)
 */
#define SAWTOOTH_INCREMENT              (1394)

/** Starting value (minimum of 16-bit signed) */
#define SAWTOOTH_START_VALUE            (-32767)

/*******************************************************************************
 * FUNCTION PROTOTYPES
 ******************************************************************************/

#if SAWTOOTH_GENERATOR_ENABLE

/**
 * @brief       Generate one frame (192 bytes) of stereo sawtooth wave
 * @param[out]  p_buffer    Output buffer (must be at least 192 bytes)
 * @retval      None
 */
void audio_sawtooth_generate_frame(uint8_t *p_buffer);

/**
 * @brief       Reset sawtooth generator to initial state
 * @retval      None
 */
void audio_sawtooth_reset(void);

#endif /* SAWTOOTH_GENERATOR_ENABLE */

#endif /* AUDIO_SAWTOOTH_SIGNAL_H */
