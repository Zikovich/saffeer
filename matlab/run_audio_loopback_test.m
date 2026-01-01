%% Real-Time Audio Loopback Test System
% Standalone MATLAB implementation for audio streaming with RA8P1 board
%
% Features:
%   - Sine wave generation to board via USB Audio
%   - Audio capture from board via USB Audio
%   - Real-time waveform display
%   - Real-time spectrogram display
%   - Real-time latency measurement
%
% Usage: Simply run this script in MATLAB

clear; clc; close all;

%% ========== CONFIGURATION ==========
% Audio Parameters
Fs = 48000;                    % Sample rate (Hz)
frameSize = 1024;              % Samples per frame
numChannels = 1;               % Mono

% Test Signal Parameters
sineFreq = 1000;               % Sine wave frequency (Hz)
sineAmplitude = 0.5;           % Amplitude (0 to 1)

% Device Names - UPDATE THESE TO MATCH YOUR SYSTEM
outputDevice = 'Headphones (3- USB Audio Demonstration)';
inputDevice = 'Microphone (3- USB Audio Demonstration)';

% Display Parameters
displayDuration = 60;          % How long to run (seconds)
spectrogramWindow = 256;       % Spectrogram window size
spectrogramOverlap = 200;      % Spectrogram overlap

%% ========== LIST AVAILABLE AUDIO DEVICES ==========
fprintf('=== Available Audio Devices ===\n');
fprintf('\nOutput Devices:\n');
devWriter = audioDeviceWriter;
outputDevices = getAudioDevices(devWriter);
for i = 1:length(outputDevices)
    fprintf('  [%d] %s\n', i, outputDevices{i});
end

fprintf('\nInput Devices:\n');
devReader = audioDeviceReader;
inputDevices = getAudioDevices(devReader);
for i = 1:length(inputDevices)
    fprintf('  [%d] %s\n', i, inputDevices{i});
end
fprintf('\n');

release(devWriter);
release(devReader);

%% ========== INITIALIZE AUDIO OBJECTS ==========
fprintf('Initializing audio devices...\n');

% Audio Device Writer (Output to RA8P1)
try
    deviceWriter = audioDeviceWriter(...
        'Device', outputDevice, ...
        'SampleRate', Fs, ...
        'BufferSize', frameSize);
    fprintf('  Output device initialized: %s\n', outputDevice);
catch ME
    warning('Could not initialize output device. Using default.');
    deviceWriter = audioDeviceWriter('SampleRate', Fs, 'BufferSize', frameSize);
    outputDevice = 'Default';
end

% Audio Device Reader (Input from RA8P1)
try
    deviceReader = audioDeviceReader(...
        'Device', inputDevice, ...
        'SampleRate', Fs, ...
        'SamplesPerFrame', frameSize, ...
        'NumChannels', numChannels);
    fprintf('  Input device initialized: %s\n', inputDevice);
catch ME
    warning('Could not initialize input device. Using default.');
    deviceReader = audioDeviceReader(...
        'SampleRate', Fs, ...
        'SamplesPerFrame', frameSize, ...
        'NumChannels', numChannels);
    inputDevice = 'Default';
end

%% ========== CREATE VISUALIZATION FIGURE ==========
fig = figure('Name', 'Audio Loopback Test - RA8P1', ...
    'NumberTitle', 'off', ...
    'Position', [100, 100, 1400, 800], ...
    'Color', [0.15 0.15 0.15], ...
    'CloseRequestFcn', @(~,~) setappdata(gcf, 'stopRequested', true));

setappdata(fig, 'stopRequested', false);

% Create subplot layout
% Row 1: Waveforms (TX and RX)
% Row 2: Spectrograms (TX and RX)
% Row 3: Latency info and controls

% --- TX Waveform ---
ax_tx_wave = subplot(3, 3, 1);
h_tx_wave = plot(zeros(frameSize, 1), 'c', 'LineWidth', 1);
ylim([-1 1]);
xlim([1 frameSize]);
title('TX Signal (to Board)', 'Color', 'w');
xlabel('Samples'); ylabel('Amplitude');
ax_tx_wave.Color = [0.1 0.1 0.1];
ax_tx_wave.XColor = 'w'; ax_tx_wave.YColor = 'w';
grid on;

% --- RX Waveform ---
ax_rx_wave = subplot(3, 3, 2);
h_rx_wave = plot(zeros(frameSize, 1), 'g', 'LineWidth', 1);
ylim([-1 1]);
xlim([1 frameSize]);
title('RX Signal (from Board)', 'Color', 'w');
xlabel('Samples'); ylabel('Amplitude');
ax_rx_wave.Color = [0.1 0.1 0.1];
ax_rx_wave.XColor = 'w'; ax_rx_wave.YColor = 'w';
grid on;

% --- Combined Waveform ---
ax_combined = subplot(3, 3, 3);
h_tx_combined = plot(zeros(frameSize, 1), 'c', 'LineWidth', 1); hold on;
h_rx_combined = plot(zeros(frameSize, 1), 'g', 'LineWidth', 1);
ylim([-1 1]);
xlim([1 frameSize]);
title('TX vs RX Overlay', 'Color', 'w');
xlabel('Samples'); ylabel('Amplitude');
legend('TX', 'RX', 'TextColor', 'w', 'Location', 'northeast');
ax_combined.Color = [0.1 0.1 0.1];
ax_combined.XColor = 'w'; ax_combined.YColor = 'w';
grid on;

% --- TX Spectrogram ---
ax_tx_spec = subplot(3, 3, 4);
spectrogramHistory = 100;  % Number of time frames to show
tx_spectrogram_data = zeros(spectrogramWindow/2+1, spectrogramHistory);
h_tx_spec = imagesc((1:spectrogramHistory) * frameSize/Fs, ...
    (0:spectrogramWindow/2) * Fs/spectrogramWindow / 1000, ...
    20*log10(tx_spectrogram_data + eps));
colormap(ax_tx_spec, 'jet');
caxis([-80 0]);
axis xy;
title('TX Spectrogram', 'Color', 'w');
xlabel('Time (s)'); ylabel('Frequency (kHz)');
ax_tx_spec.Color = [0.1 0.1 0.1];
ax_tx_spec.XColor = 'w'; ax_tx_spec.YColor = 'w';
colorbar('Color', 'w');

% --- RX Spectrogram ---
ax_rx_spec = subplot(3, 3, 5);
rx_spectrogram_data = zeros(spectrogramWindow/2+1, spectrogramHistory);
h_rx_spec = imagesc((1:spectrogramHistory) * frameSize/Fs, ...
    (0:spectrogramWindow/2) * Fs/spectrogramWindow / 1000, ...
    20*log10(rx_spectrogram_data + eps));
colormap(ax_rx_spec, 'jet');
caxis([-80 0]);
axis xy;
title('RX Spectrogram', 'Color', 'w');
xlabel('Time (s)'); ylabel('Frequency (kHz)');
ax_rx_spec.Color = [0.1 0.1 0.1];
ax_rx_spec.XColor = 'w'; ax_rx_spec.YColor = 'w';
colorbar('Color', 'w');

% --- Spectrum Comparison ---
ax_spectrum = subplot(3, 3, 6);
freqAxis = (0:frameSize/2) * Fs / frameSize / 1000;
h_tx_spectrum = plot(freqAxis, zeros(frameSize/2+1, 1), 'c', 'LineWidth', 1.5); hold on;
h_rx_spectrum = plot(freqAxis, zeros(frameSize/2+1, 1), 'g', 'LineWidth', 1.5);
ylim([-100 0]);
xlim([0 Fs/2/1000]);
title('Spectrum Comparison', 'Color', 'w');
xlabel('Frequency (kHz)'); ylabel('Magnitude (dB)');
legend('TX', 'RX', 'TextColor', 'w', 'Location', 'northeast');
ax_spectrum.Color = [0.1 0.1 0.1];
ax_spectrum.XColor = 'w'; ax_spectrum.YColor = 'w';
grid on;

% --- Latency Display Panel ---
ax_latency = subplot(3, 3, 7:9);
axis off;
ax_latency.Color = [0.15 0.15 0.15];

% Create text displays
h_latency_text = text(0.05, 0.8, 'Latency: -- ms', ...
    'FontSize', 24, 'Color', 'y', 'FontWeight', 'bold');
h_correlation_text = text(0.05, 0.5, 'Correlation: --', ...
    'FontSize', 18, 'Color', 'w');
h_status_text = text(0.05, 0.2, 'Status: Initializing...', ...
    'FontSize', 14, 'Color', [0.5 0.5 0.5]);
h_info_text = text(0.5, 0.8, sprintf('Output: %s\nInput: %s\nFs: %d Hz | Frame: %d | Freq: %d Hz', ...
    outputDevice, inputDevice, Fs, frameSize, sineFreq), ...
    'FontSize', 12, 'Color', [0.7 0.7 0.7], 'VerticalAlignment', 'top');

title('Latency Measurement', 'Color', 'w', 'FontSize', 16);

%% ========== LATENCY MEASUREMENT SETUP ==========
% Buffer for cross-correlation based latency measurement
latencyBufferSize = 8192;  % Samples for correlation
txBuffer = zeros(latencyBufferSize, 1);
rxBuffer = zeros(latencyBufferSize, 1);

% Moving average for stable latency reading
latencyHistory = zeros(20, 1);
latencyIdx = 1;

%% ========== MAIN PROCESSING LOOP ==========
fprintf('\n=== Starting Audio Loopback Test ===\n');
fprintf('Press Ctrl+C or close the figure to stop.\n\n');

% Pre-compute sine wave lookup table for efficiency
t = (0:frameSize-1)' / Fs;
phaseIncrement = 2 * pi * sineFreq / Fs;
phase = 0;

frameCount = 0;
startTime = tic;

try
    while ~getappdata(fig, 'stopRequested') && ishandle(fig)
        frameCount = frameCount + 1;
        
        %% Generate TX Signal (Sine Wave)
        txSignal = sineAmplitude * sin(phase + phaseIncrement * (0:frameSize-1)');
        phase = phase + phaseIncrement * frameSize;
        phase = mod(phase, 2*pi);  % Prevent phase accumulation
        
        %% Send to Board
        deviceWriter(txSignal);
        
        %% Receive from Board
        [rxSignal, numOverrun] = deviceReader();
        rxSignal = rxSignal(:, 1);  % Take first channel if stereo
        
        if numOverrun > 0
            set(h_status_text, 'String', sprintf('Status: Running (Overrun: %d)', numOverrun), 'Color', 'r');
        else
            set(h_status_text, 'String', 'Status: Running', 'Color', 'g');
        end
        
        %% Update Latency Buffers
        txBuffer = [txBuffer(frameSize+1:end); txSignal];
        rxBuffer = [rxBuffer(frameSize+1:end); rxSignal];
        
        %% Calculate Latency (every 10 frames to reduce CPU load)
        if mod(frameCount, 10) == 0
            % Cross-correlation
            [xcorrResult, lags] = xcorr(rxBuffer, txBuffer, latencyBufferSize/2);
            [maxCorr, maxIdx] = max(abs(xcorrResult));
            delaySamples = lags(maxIdx);
            
            % Convert to milliseconds
            latencyMs = (delaySamples / Fs) * 1000;
            
            % Normalize correlation
            normCorr = maxCorr / (norm(txBuffer) * norm(rxBuffer) + eps);
            
            % Moving average filter
            latencyHistory(latencyIdx) = latencyMs;
            latencyIdx = mod(latencyIdx, length(latencyHistory)) + 1;
            avgLatency = mean(latencyHistory(latencyHistory ~= 0));
            
            % Update display
            set(h_latency_text, 'String', sprintf('Latency: %.2f ms (avg: %.2f ms)', latencyMs, avgLatency));
            set(h_correlation_text, 'String', sprintf('Correlation: %.4f | Delay: %d samples', normCorr, delaySamples));
        end
        
        %% Update Waveform Displays (every 5 frames)
        if mod(frameCount, 5) == 0
            set(h_tx_wave, 'YData', txSignal);
            set(h_rx_wave, 'YData', rxSignal);
            set(h_tx_combined, 'YData', txSignal);
            set(h_rx_combined, 'YData', rxSignal);
        end
        
        %% Update Spectrum Displays (every 10 frames)
        if mod(frameCount, 10) == 0
            % FFT
            txFFT = abs(fft(txSignal .* hanning(frameSize)));
            rxFFT = abs(fft(rxSignal .* hanning(frameSize)));
            
            txFFT_dB = 20*log10(txFFT(1:frameSize/2+1) + eps);
            rxFFT_dB = 20*log10(rxFFT(1:frameSize/2+1) + eps);
            
            set(h_tx_spectrum, 'YData', txFFT_dB);
            set(h_rx_spectrum, 'YData', rxFFT_dB);
        end
        
        %% Update Spectrograms (every 3 frames)
        if mod(frameCount, 3) == 0
            % Compute short-time FFT
            txSTFT = abs(fft(txSignal(1:spectrogramWindow) .* hanning(spectrogramWindow)));
            rxSTFT = abs(fft(rxSignal(1:spectrogramWindow) .* hanning(spectrogramWindow)));
            
            % Shift and update spectrogram data
            tx_spectrogram_data = [tx_spectrogram_data(:, 2:end), txSTFT(1:spectrogramWindow/2+1)];
            rx_spectrogram_data = [rx_spectrogram_data(:, 2:end), rxSTFT(1:spectrogramWindow/2+1)];
            
            set(h_tx_spec, 'CData', 20*log10(tx_spectrogram_data + eps));
            set(h_rx_spec, 'CData', 20*log10(rx_spectrogram_data + eps));
        end
        
        %% Update Figure
        drawnow limitrate;
        
        %% Check timeout
        if toc(startTime) > displayDuration
            fprintf('Test duration complete.\n');
            break;
        end
    end
    
catch ME
    fprintf('Error: %s\n', ME.message);
end

%% ========== CLEANUP ==========
fprintf('\nCleaning up...\n');
release(deviceWriter);
release(deviceReader);

if ishandle(fig)
    close(fig);
end

fprintf('Audio loopback test complete.\n');
fprintf('Total frames processed: %d\n', frameCount);
fprintf('Total time: %.2f seconds\n', toc(startTime));
