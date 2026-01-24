/***********************************************************************************************************************
 * File Name    : audio_test_signal.h
 * Description  : Header file for stereo sine wave test signal generator
 *                Used for debugging USB audio streaming by generating known test signals
 **********************************************************************************************************************/
/***********************************************************************************************************************
 * Copyright (c) 2025
 * SPDX-License-Identifier: BSD-3-Clause
 **********************************************************************************************************************/

#ifndef AUDIO_TEST_SIGNAL_H
#define AUDIO_TEST_SIGNAL_H

#include <stdint.h>
#include <stdbool.h>

/*******************************************************************************
 * TEST SIGNAL GENERATOR ENABLE/DISABLE
 * 
 * Set to 1 to enable internal sine wave generation (bypasses USB input)
 * Set to 0 for normal loopback operation (USB IN -> buffer -> USB OUT)
 * 
 * When enabled:
 *   - Left channel:  Lower frequency, higher amplitude
 *   - Right channel: Higher frequency, lower amplitude
 *   This helps identify channel swap or mixing issues during debugging
 ******************************************************************************/
#define TEST_SINE_GENERATOR_ENABLE      (1)


/*******************************************************************************
 * AUDIO FORMAT CONFIGURATION
 * These should match your USB Audio descriptor settings
 ******************************************************************************/

/** Audio sample rate in Hz */
#define AUDIO_TEST_SAMPLE_RATE_HZ       (48000U)

/** Number of audio channels (2 = stereo) */
#define AUDIO_TEST_NUM_CHANNELS         (2U)

/** Bytes per sample (2 = 16-bit audio) */
#define AUDIO_TEST_BYTES_PER_SAMPLE     (2U)

/** Bytes per stereo sample pair (Left + Right) */
#define AUDIO_TEST_BYTES_PER_FRAME      (AUDIO_TEST_NUM_CHANNELS * AUDIO_TEST_BYTES_PER_SAMPLE)


/*******************************************************************************
 * LEFT CHANNEL CONFIGURATION
 * Lower frequency sine wave at higher amplitude
 ******************************************************************************/

/** Left channel frequency in Hz */
#define AUDIO_TEST_FREQ_LEFT_HZ         (375U)

/** Left channel amplitude (0-32767, where 32767 = 100% = 0dBFS)
 *  26214 = ~80% amplitude = -1.9 dBFS */
#define AUDIO_TEST_AMPLITUDE_LEFT       (26214)


/*******************************************************************************
 * RIGHT CHANNEL CONFIGURATION  
 * Higher frequency sine wave at lower amplitude
 ******************************************************************************/

/** Right channel frequency in Hz */
#define AUDIO_TEST_FREQ_RIGHT_HZ        (750U)

/** Right channel amplitude (0-32767, where 32767 = 100% = 0dBFS)
 *  16383 = ~50% amplitude = -6.0 dBFS */
#define AUDIO_TEST_AMPLITUDE_RIGHT      (16383)


/*******************************************************************************
 * ADVANCED CONFIGURATION (usually no need to modify)
 ******************************************************************************/

/** Sine lookup table size (must be power of 2 for efficient wrapping) */
#define AUDIO_TEST_SINE_TABLE_SIZE      (256U)

/** Maximum amplitude value for 16-bit signed audio */
#define AUDIO_TEST_MAX_AMPLITUDE        (32767)


/*******************************************************************************
 * FUNCTION PROTOTYPES
 ******************************************************************************/

#if TEST_SINE_GENERATOR_ENABLE

/**
 * @brief       Initialize/reset the sine wave generator
 * @details     Resets phase accumulators to zero for both channels.
 *              Call this when starting a new audio stream to ensure
 *              the sine wave starts from a consistent phase.
 * @param       None
 * @retval      None
 */
void audio_test_signal_reset(void);

/**
 * @brief       Generate stereo sine wave test signal
 * @details     Fills the provided buffer with interleaved stereo audio samples.
 *              Left channel gets AUDIO_TEST_FREQ_LEFT_HZ at AUDIO_TEST_AMPLITUDE_LEFT.
 *              Right channel gets AUDIO_TEST_FREQ_RIGHT_HZ at AUDIO_TEST_AMPLITUDE_RIGHT.
 *              
 *              Audio format: 16-bit signed little-endian, interleaved stereo
 *              Buffer layout: [L0_lo, L0_hi, R0_lo, R0_hi, L1_lo, L1_hi, R1_lo, R1_hi, ...]
 *              
 * @param[out]  p_buffer    Pointer to output buffer (must not be NULL)
 * @param[in]   num_bytes   Number of bytes to generate (must be multiple of 4)
 * @retval      None
 * 
 * @note        The function maintains internal phase state between calls,
 *              so consecutive calls produce a continuous sine wave without
 *              discontinuities.
 */
void audio_test_signal_generate(uint8_t *p_buffer, uint32_t num_bytes);

/**
 * @brief       Check if test signal generator is enabled
 * @details     Returns the compile-time setting of TEST_SINE_GENERATOR_ENABLE.
 *              Useful for runtime status display.
 * @param       None
 * @retval      true if test generator is enabled, false otherwise
 */
bool audio_test_signal_is_enabled(void);

/**
 * @brief       Get left channel frequency setting
 * @param       None
 * @retval      Left channel frequency in Hz
 */
uint32_t audio_test_signal_get_freq_left(void);

/**
 * @brief       Get right channel frequency setting
 * @param       None
 * @retval      Right channel frequency in Hz
 */
uint32_t audio_test_signal_get_freq_right(void);

/**
 * @brief       Get left channel amplitude setting
 * @param       None
 * @retval      Left channel amplitude (0-32767)
 */
uint16_t audio_test_signal_get_amplitude_left(void);

/**
 * @brief       Get right channel amplitude setting
 * @param       None
 * @retval      Right channel amplitude (0-32767)
 */
uint16_t audio_test_signal_get_amplitude_right(void);

#endif /* TEST_SINE_GENERATOR_ENABLE */

#endif /* AUDIO_TEST_SIGNAL_H */
