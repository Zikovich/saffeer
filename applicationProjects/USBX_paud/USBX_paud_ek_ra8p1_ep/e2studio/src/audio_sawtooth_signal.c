/***********************************************************************************************************************
 * File Name    : audio_sawtooth_signal.c
 * Description  : Sawtooth wave generator - 192 bytes per full period with constant increment
 **********************************************************************************************************************/
#include "audio_sawtooth_signal.h"
#include <stdlib.h>

#if SAWTOOTH_GENERATOR_ENABLE

/*******************************************************************************
 * SAWTOOTH LOOKUP TABLE
 * 
 * Pre-calculated 48-sample sawtooth wave spanning full 16-bit range
 * Values go from -32767 to +32767 with constant increment of 1394
 * 
 * This table represents one complete period of the sawtooth wave.
 * For stereo output, the same value is used for both L and R channels.
 ******************************************************************************/
static const int16_t g_sawtooth_table[SAWTOOTH_SAMPLES_PER_FRAME] = {
    -32767,     /* Sample 0  */
    -31373,     /* Sample 1  */
    -29979,     /* Sample 2  */
    -28585,     /* Sample 3  */
    -27191,     /* Sample 4  */
    -25797,     /* Sample 5  */
    -24403,     /* Sample 6  */
    -23009,     /* Sample 7  */
    -21615,     /* Sample 8  */
    -20221,     /* Sample 9  */
    -18827,     /* Sample 10 */
    -17433,     /* Sample 11 */
    -16039,     /* Sample 12 */
    -14645,     /* Sample 13 */
    -13251,     /* Sample 14 */
    -11857,     /* Sample 15 */
    -10463,     /* Sample 16 */
     -9069,     /* Sample 17 */
     -7675,     /* Sample 18 */
     -6281,     /* Sample 19 */
     -4887,     /* Sample 20 */
     -3493,     /* Sample 21 */
     -2099,     /* Sample 22 */
      -705,     /* Sample 23 */
       689,     /* Sample 24 */
      2083,     /* Sample 25 */
      3477,     /* Sample 26 */
      4871,     /* Sample 27 */
      6265,     /* Sample 28 */
      7659,     /* Sample 29 */
      9053,     /* Sample 30 */
     10447,     /* Sample 31 */
     11841,     /* Sample 32 */
     13235,     /* Sample 33 */
     14629,     /* Sample 34 */
     16023,     /* Sample 35 */
     17417,     /* Sample 36 */
     18811,     /* Sample 37 */
     20205,     /* Sample 38 */
     21599,     /* Sample 39 */
     22993,     /* Sample 40 */
     24387,     /* Sample 41 */
     25781,     /* Sample 42 */
     27175,     /* Sample 43 */
     28569,     /* Sample 44 */
     29963,     /* Sample 45 */
     31357,     /* Sample 46 */
     32751      /* Sample 47 - near +32767 */
};

/** Current sample index (0-47) */
static uint8_t g_sawtooth_index = 0;


/*******************************************************************************************************************//**
 * @brief       Reset sawtooth generator to initial state
 **********************************************************************************************************************/
void audio_sawtooth_reset(void)
{
    g_sawtooth_index = 0;
}


/*******************************************************************************************************************//**
 * @brief       Generate one frame (192 bytes) of stereo sawtooth wave
 * @details     Outputs 48 stereo samples, completing exactly one sawtooth period.
 *              Both L and R channels receive the same value (mono signal on stereo output).
 *              Format: 16-bit signed little-endian, interleaved stereo.
 **********************************************************************************************************************/
void audio_sawtooth_generate_frame(uint8_t *p_buffer)
{
    if (p_buffer == NULL)
    {
        return;
    }

    /* Generate 48 stereo sample pairs (192 bytes total) */
    for (uint32_t i = 0; i < SAWTOOTH_SAMPLES_PER_FRAME; i++)
    {
        int16_t sample_value = g_sawtooth_table[g_sawtooth_index];

        /* Calculate buffer offset: 4 bytes per stereo sample */
        uint32_t offset = i * 4U;

        /* Left channel - little endian */
        p_buffer[offset + 0] = (uint8_t)(sample_value & 0xFF);
        p_buffer[offset + 1] = (uint8_t)((sample_value >> 8) & 0xFF);

        /* Right channel - same value for mono-on-stereo */
        p_buffer[offset + 2] = (uint8_t)(sample_value & 0xFF);
        p_buffer[offset + 3] = (uint8_t)((sample_value >> 8) & 0xFF);

        /* Advance index with wraparound */
        g_sawtooth_index++;
        if (g_sawtooth_index >= SAWTOOTH_SAMPLES_PER_FRAME)
        {
            g_sawtooth_index = 0;
        }
    }
}


#endif /* SAWTOOTH_GENERATOR_ENABLE */
