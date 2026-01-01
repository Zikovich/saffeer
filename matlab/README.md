# Audio Loopback Test System for RA8P1 Board

## Overview

This system generates a sine wave in MATLAB/Simulink, sends it to your RA8P1 board via USB Audio, receives the processed audio back, and provides real-time visualization and latency measurement.

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   MATLAB    │ ──TX──▶ │   RA8P1     │ ──RX──▶ │   MATLAB    │
│ (Sine Wave) │ Audio   │   Board     │ Audio   │ (Analysis)  │
│             │ Out     │ (Processing)│ In      │             │
└─────────────┘         └─────────────┘         └─────────────┘
     │                                                │
     │  Headphones (3- USB Audio Demonstration)       │
     │  ────────────────────────────────────────▶     │
     │                                                │
     │  Microphone (3- USB Audio Demonstration)       │
     │  ◀────────────────────────────────────────     │
```

## Files Included

| File | Description |
|------|-------------|
| `build_simulink_model.m` | Creates the Simulink model automatically |
| `run_audio_loopback_test.m` | Standalone MATLAB script (no Simulink needed) |
| `create_audio_loopback_model.m` | Alternative model builder |
| `latency_function_code.m` | Code for the latency calculation block |

## Quick Start

### Option 1: Simulink Model (Recommended)

1. **Run the model builder:**
   ```matlab
   >> build_simulink_model
   ```

2. **Configure the MATLAB Function block:**
   - Double-click the `LatencyCalc` block in the model
   - Delete the default code
   - Copy the code from `latency_function_code.m` (opened automatically)
   - Save and close (Ctrl+S)

3. **Verify audio devices:**
   - Double-click `AudioOut` → Check device name matches your headphones
   - Double-click `AudioIn` → Check device name matches your microphone

4. **Run the model:**
   - Click the green "Run" button or press Ctrl+T

### Option 2: Standalone MATLAB Script

```matlab
>> run_audio_loopback_test
```

This runs without Simulink and includes all visualizations.

## Detailed Setup Steps

### Step 1: Verify Audio Devices

First, check that MATLAB can see your USB audio devices:

```matlab
% List output devices
devWriter = audioDeviceWriter;
disp(getAudioDevices(devWriter));
release(devWriter);

% List input devices  
devReader = audioDeviceReader;
disp(getAudioDevices(devReader));
release(devReader);
```

You should see:
- `Headphones (3- USB Audio Demonstration)` - for output
- `Microphone (3- USB Audio Demonstration)` - for input

### Step 2: Install Required Toolboxes

Required MATLAB toolboxes:
- Audio Toolbox
- DSP System Toolbox
- Signal Processing Toolbox
- Simulink (for Simulink-based approach)

Check with:
```matlab
ver('audio')
ver('dsp')
ver('signal')
ver('simulink')
```

### Step 3: Configure Audio Settings in Windows

1. Open Windows Sound Settings
2. Set "Headphones (3- USB Audio Demonstration)" as output device
3. Set "Microphone (3- USB Audio Demonstration)" as input device
4. Ensure sample rate is set to 48000 Hz

## Simulink Model Structure

```
┌──────────────┐
│  Sine Wave   │──┬──▶ [Audio Out] ──▶ (To RA8P1)
│  Generator   │  │
└──────────────┘  ├──▶ [Spectrum TX]
                  ├──▶ [Waveform Scope Ch1]
                  └──▶ [Latency Calc] ──┬──▶ [Latency Display]
                           ▲           └──▶ [Correlation Display]
┌──────────────┐           │
│  Audio In    │──┬────────┘
│  (From RA8P1)│  │
└──────────────┘  ├──▶ [Spectrum RX]
                  └──▶ [Waveform Scope Ch2]
```

## Configuration Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Sample Rate | 48000 Hz | Audio sample rate |
| Frame Size | 1024 | Samples per processing frame |
| Sine Frequency | 1000 Hz | Test tone frequency |
| Sine Amplitude | 0.5 | Test tone amplitude (0-1) |

To modify, edit the variables at the top of the scripts.

## Latency Measurement

The latency is measured using cross-correlation between TX and RX signals:

1. Both TX and RX signals are buffered (4096 samples)
2. Cross-correlation finds the delay that maximizes alignment
3. Delay is converted to milliseconds: `latency_ms = delay_samples / Fs * 1000`

**Expected latency components:**
- USB Audio buffering: ~2-5 ms
- Board processing: varies
- Total round-trip: typically 5-20 ms

## Troubleshooting

### "Audio device not found"
```matlab
% List all devices and find the correct name
info = audiodevinfo;
disp({info.output.Name}')
disp({info.input.Name}')
```

### "Buffer underrun/overrun"
- Increase buffer size in device settings
- Reduce other CPU load
- Try larger frame size (2048)

### No audio received
1. Check RA8P1 board is configured for USB audio passthrough
2. Verify Windows sound settings
3. Check board is receiving audio (use headphones to monitor)

### Latency shows negative or very large values
- Ensure both devices are synchronized
- Check that the received signal contains the test tone
- Verify board is actually processing/returning audio

## Advanced: Custom Test Signals

To use different test signals, modify the signal generation block:

```matlab
% Chirp signal (frequency sweep)
t = (0:frameSize-1)'/Fs;
txSignal = chirp(t, 100, frameSize/Fs, 10000);

% White noise
txSignal = 0.5 * randn(frameSize, 1);

% Square wave
txSignal = 0.5 * sign(sin(2*pi*sineFreq*t));
```

## Contact & Support

For issues with:
- This MATLAB code: Check MATLAB documentation
- RA8P1 board configuration: Refer to Renesas documentation
- USB Audio setup: Check Windows device manager

---
Generated for RA8P1 Audio Loopback Testing
