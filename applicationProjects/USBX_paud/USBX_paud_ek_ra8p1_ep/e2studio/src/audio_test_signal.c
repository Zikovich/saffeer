/***********************************************************************************************************************
 * File Name    : audio_test_signal.c
 * Description  : Implementation of stereo sine wave test signal generator
 *                Generates two independent sine waves for left and right channels
 *                with configurable frequency and amplitude for USB audio debugging
 **********************************************************************************************************************/
/***********************************************************************************************************************
 * Copyright (c) 2025
 * SPDX-License-Identifier: BSD-3-Clause
 **********************************************************************************************************************/

#include <stdlib.h>
#include "audio_test_signal.h"

#if TEST_SINE_GENERATOR_ENABLE

/*******************************************************************************
 * SINE LOOKUP TABLE
 * 
 * 256 entries representing one full cycle of a sine wave.
 * Values are in Q15 format: -32768 to +32767 representing -1.0 to +1.0
 * 
 * Using a lookup table is much faster than calling sin() at runtime,
 * which is critical for real-time audio generation in an interrupt context.
 * 
 * Table generated with: round(32767 * sin(2 * pi * i / 256)) for i = 0..255
 ******************************************************************************/
static const int16_t g_sine_table[AUDIO_TEST_SINE_TABLE_SIZE] = {
    /* 0-7 */
         0,    804,   1608,   2410,   3212,   4011,   4808,   5602,
    /* 8-15 */
      6393,   7179,   7962,   8739,   9512,  10278,  11039,  11793,
    /* 16-23 */
     12539,  13279,  14010,  14732,  15446,  16151,  16846,  17530,
    /* 24-31 */
     18204,  18868,  19519,  20159,  20787,  21403,  22005,  22594,
    /* 32-39 */
     23170,  23731,  24279,  24811,  25329,  25832,  26319,  26790,
    /* 40-47 */
     27245,  27683,  28105,  28510,  28898,  29268,  29621,  29956,
    /* 48-55 */
     30273,  30571,  30852,  31113,  31356,  31580,  31785,  31971,
    /* 56-63 */
     32137,  32285,  32412,  32521,  32609,  32678,  32728,  32757,
    /* 64-71: Peak at index 64 */
     32767,  32757,  32728,  32678,  32609,  32521,  32412,  32285,
    /* 72-79 */
     32137,  31971,  31785,  31580,  31356,  31113,  30852,  30571,
    /* 80-87 */
     30273,  29956,  29621,  29268,  28898,  28510,  28105,  27683,
    /* 88-95 */
     27245,  26790,  26319,  25832,  25329,  24811,  24279,  23731,
    /* 96-103 */
     23170,  22594,  22005,  21403,  20787,  20159,  19519,  18868,
    /* 104-111 */
     18204,  17530,  16846,  16151,  15446,  14732,  14010,  13279,
    /* 112-119 */
     12539,  11793,  11039,  10278,   9512,   8739,   7962,   7179,
    /* 120-127 */
      6393,   5602,   4808,   4011,   3212,   2410,   1608,    804,
    /* 128-135: Zero crossing going negative */
         0,   -804,  -1608,  -2410,  -3212,  -4011,  -4808,  -5602,
    /* 136-143 */
     -6393,  -7179,  -7962,  -8739,  -9512, -10278, -11039, -11793,
    /* 144-151 */
    -12539, -13279, -14010, -14732, -15446, -16151, -16846, -17530,
    /* 152-159 */
    -18204, -18868, -19519, -20159, -20787, -21403, -22005, -22594,
    /* 160-167 */
    -23170, -23731, -24279, -24811, -25329, -25832, -26319, -26790,
    /* 168-175 */
    -27245, -27683, -28105, -28510, -28898, -29268, -29621, -29956,
    /* 176-183 */
    -30273, -30571, -30852, -31113, -31356, -31580, -31785, -31971,
    /* 184-191 */
    -32137, -32285, -32412, -32521, -32609, -32678, -32728, -32757,
    /* 192-199: Negative peak at index 192 */
    -32767, -32757, -32728, -32678, -32609, -32521, -32412, -32285,
    /* 200-207 */
    -32137, -31971, -31785, -31580, -31356, -31113, -30852, -30571,
    /* 208-215 */
    -30273, -29956, -29621, -29268, -28898, -28510, -28105, -27683,
    /* 216-223 */
    -27245, -26790, -26319, -25832, -25329, -24811, -24279, -23731,
    /* 224-231 */
    -23170, -22594, -22005, -21403, -20787, -20159, -19519, -18868,
    /* 232-239 */
    -18204, -17530, -16846, -16151, -15446, -14732, -14010, -13279,
    /* 240-247 */
    -12539, -11793, -11039, -10278,  -9512,  -8739,  -7962,  -7179,
    /* 248-255: Approaching zero crossing */
     -6393,  -5602,  -4808,  -4011,  -3212,  -2410,  -1608,   -804
};


/*******************************************************************************
 * PHASE ACCUMULATORS
 * 
 * These track the current position in the sine wave cycle for each channel.
 * Using fixed-point math with 16 bits of fractional precision.
 * 
 * Format: [8 bits integer (table index)][16 bits fraction]
 * 
 * Phase increment formula:
 *   increment = (frequency * TABLE_SIZE * 65536) / sample_rate
 * 
 * Example for 500 Hz at 48 kHz:
 *   increment = (500 * 256 * 65536) / 48000 = 174763 (approximately)
 ******************************************************************************/
static uint32_t g_phase_accumulator_left  = 0;
static uint32_t g_phase_accumulator_right = 0;


/*******************************************************************************
 * PRE-CALCULATED PHASE INCREMENTS
 * 
 * These values determine how much the phase advances per sample.
 * Larger values = higher frequency.
 * 
 * Calculation done at compile time for efficiency.
 ******************************************************************************/
#define PHASE_INCREMENT_LEFT  65536UL
    //((uint32_t)((uint64_t)AUDIO_TEST_FREQ_LEFT_HZ * AUDIO_TEST_SINE_TABLE_SIZE * 65536UL / AUDIO_TEST_SAMPLE_RATE_HZ))

#define PHASE_INCREMENT_RIGHT \
    ((uint32_t)((uint64_t)AUDIO_TEST_FREQ_RIGHT_HZ * AUDIO_TEST_SINE_TABLE_SIZE * 65536UL / AUDIO_TEST_SAMPLE_RATE_HZ))


/*******************************************************************************************************************//**
 * @brief       Initialize/reset the sine wave generator
 **********************************************************************************************************************/
void audio_test_signal_reset(void)
{
    /* Reset both phase accumulators to zero */
    /* This ensures the sine waves start from 0 degrees (zero crossing, rising) */
    g_phase_accumulator_left  = 0;
    g_phase_accumulator_right = 0;
}


/*******************************************************************************************************************//**
 * @brief       Generate stereo sine wave test signal
 **********************************************************************************************************************/
void audio_test_signal_generate(uint8_t *p_buffer, uint32_t num_bytes)
{
    /* Safety check */
    if (p_buffer == NULL)
    {
        return;
    }

    /* Calculate number of stereo sample pairs to generate */
    /* Each stereo sample pair is 4 bytes: 2 bytes left + 2 bytes right */
    uint32_t num_sample_pairs = num_bytes / AUDIO_TEST_BYTES_PER_FRAME;

    /* Generate each stereo sample pair */
    for (uint32_t i = 0; i < num_sample_pairs; i++)
    {
        /*
         * Step 1: Get sine table index from phase accumulator
         * 
         * The phase accumulator format is:
         *   Bits 23-16: Table index (0-255)
         *   Bits 15-0:  Fractional part (for smooth frequency generation)
         * 
         * We extract the table index by shifting right 16 bits and masking.
         */
        uint8_t table_index_left  = (uint8_t)((g_phase_accumulator_left >> 16) & 0xFF);
        uint8_t table_index_right = (uint8_t)((g_phase_accumulator_right >> 16) & 0xFF);

        /*
         * Step 2: Look up sine values from table
         * 
         * The table contains values from -32767 to +32767 (Q15 format).
         */
        int16_t sine_value_left  = g_sine_table[table_index_left];
        int16_t sine_value_right = g_sine_table[table_index_right];

        /*
         * Step 3: Scale by amplitude
         * 
         * Multiply the sine value by the desired amplitude, then divide by
         * the maximum amplitude (32767) to normalize.
         * 
         * Using 32-bit intermediate calculation to avoid overflow:
         *   result = (sine_value * amplitude) / 32767
         * 
         * We use >> 15 instead of / 32768 because it's faster and the
         * difference is negligible (off by at most 1 LSB).
         */
        int32_t sample_left  = ((int32_t)sine_value_left);// * AUDIO_TEST_AMPLITUDE_LEFT) >> 15;
        int32_t sample_right = ((int32_t)sine_value_right);// * AUDIO_TEST_AMPLITUDE_RIGHT) >> 15;

        /*
         * Step 4: Clamp to 16-bit signed range
         * 
         * This shouldn't be necessary with proper amplitude settings,
         * but it's a safety measure to prevent audio clipping artifacts.
         */
        if (sample_left > 32767)
        {
            sample_left = 32767;
        }
        else if (sample_left < -32768)
        {
            sample_left = -32768;
        }

        if (sample_right > 32767)
        {
            sample_right = 32767;
        }
        else if (sample_right < -32768)
        {
            sample_right = -32768;
        }

        /*
         * Step 5: Write samples to buffer in little-endian format
         * 
         * USB Audio uses little-endian byte order for 16-bit samples.
         * For a 16-bit value like 0x1234:
         *   First byte (low):  0x34
         *   Second byte (high): 0x12
         * 
         * Buffer layout for interleaved stereo:
         *   [L_low, L_high, R_low, R_high, L_low, L_high, R_low, R_high, ...]
         */
        uint32_t buffer_offset = i * AUDIO_TEST_BYTES_PER_FRAME;

        /* Left channel - bytes 0 and 1 */
        p_buffer[buffer_offset + 0] = (uint8_t)(sample_left & 0xFF);          /* Low byte */
        p_buffer[buffer_offset + 1] = (uint8_t)((sample_left >> 8) & 0xFF);   /* High byte */

        /* Right channel - bytes 2 and 3 */
        p_buffer[buffer_offset + 2] = (uint8_t)(sample_right & 0xFF);         /* Low byte */
        p_buffer[buffer_offset + 3] = (uint8_t)((sample_right >> 8) & 0xFF);  /* High byte */

        /*
         * Step 6: Advance phase accumulators
         * 
         * Add the phase increment to move forward in the sine wave.
         * The accumulator naturally wraps around due to uint32_t overflow,
         * which gives us continuous oscillation.
         */
        g_phase_accumulator_left  += PHASE_INCREMENT_LEFT;
        g_phase_accumulator_right += PHASE_INCREMENT_RIGHT;

        /*
         * Mask to keep only 24 bits (8 integer + 16 fractional)
         * This prevents potential issues from very long running times
         * while maintaining the phase relationship.
         */
        g_phase_accumulator_left  &= 0x00FFFFFF;
        g_phase_accumulator_right &= 0x00FFFFFF;
    }
}


/*******************************************************************************************************************//**
 * @brief       Check if test signal generator is enabled
 **********************************************************************************************************************/
bool audio_test_signal_is_enabled(void)
{
    return true;  /* This function only exists when TEST_SINE_GENERATOR_ENABLE == 1 */
}


/*******************************************************************************************************************//**
 * @brief       Get left channel frequency setting
 **********************************************************************************************************************/
uint32_t audio_test_signal_get_freq_left(void)
{
    return AUDIO_TEST_FREQ_LEFT_HZ;
}


/*******************************************************************************************************************//**
 * @brief       Get right channel frequency setting
 **********************************************************************************************************************/
uint32_t audio_test_signal_get_freq_right(void)
{
    return AUDIO_TEST_FREQ_RIGHT_HZ;
}


/*******************************************************************************************************************//**
 * @brief       Get left channel amplitude setting
 **********************************************************************************************************************/
uint16_t audio_test_signal_get_amplitude_left(void)
{
    return AUDIO_TEST_AMPLITUDE_LEFT;
}


/*******************************************************************************************************************//**
 * @brief       Get right channel amplitude setting
 **********************************************************************************************************************/
uint16_t audio_test_signal_get_amplitude_right(void)
{
    return AUDIO_TEST_AMPLITUDE_RIGHT;
}


#endif /* TEST_SINE_GENERATOR_ENABLE */
