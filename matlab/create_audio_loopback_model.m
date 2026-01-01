%% Audio Loopback Test System for RA8P1 Board
% This script creates a Simulink model for real-time audio streaming,
% visualization, and latency measurement
%
% Setup:
%   - Output: Headphones (3- USB Audio Demonstration) -> RA8P1 Board Input
%   - Input:  Microphone (3- USB Audio Demonstration) <- RA8P1 Board Output
%
% Author: Audio Test System Generator
% Date: 2025

clear; clc; close all;

%% Configuration Parameters
config.sampleRate = 48000;          % Sample rate in Hz
config.samplesPerFrame = 1024;      % Frame size
config.numChannels = 1;             % Mono audio
config.sineFrequency = 1000;        % Test tone frequency in Hz
config.sineAmplitude = 0.5;         % Amplitude (0-1)

% Device names (update these to match your system)
config.outputDevice = 'Headphones (3- USB Audio Demonstration)';
config.inputDevice = 'Microphone (3- USB Audio Demonstration)';

% Save configuration for the model
save('audio_config.mat', 'config');

%% Create the Simulink Model
modelName = 'AudioLoopbackTest';

% Close existing model if open
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Create new model
new_system(modelName);
open_system(modelName);

% Set model parameters
set_param(modelName, 'StopTime', 'inf');
set_param(modelName, 'SolverType', 'Fixed-step');
set_param(modelName, 'Solver', 'FixedStepDiscrete');
set_param(modelName, 'FixedStep', num2str(config.samplesPerFrame/config.sampleRate));

%% Add Blocks

% --- Sine Wave Generator ---
add_block('simulink/Sources/Sine Wave', [modelName '/Sine_Generator']);
set_param([modelName '/Sine_Generator'], ...
    'SineType', 'Sample based', ...
    'Amplitude', num2str(config.sineAmplitude), ...
    'Frequency', num2str(config.sineFrequency), ...
    'SampleTime', num2str(1/config.sampleRate), ...
    'SamplesPerFrame', num2str(config.samplesPerFrame), ...
    'OutputDataTypeStr', 'double');

% --- Audio Device Writer (Output to Board) ---
add_block('audio/Sources and Sinks/Audio Device Writer', [modelName '/Audio_Output']);
set_param([modelName '/Audio_Output'], ...
    'Device', config.outputDevice, ...
    'SampleRate', num2str(config.sampleRate), ...
    'QueueDuration', '0.5');

% --- Audio Device Reader (Input from Board) ---
add_block('audio/Sources and Sinks/Audio Device Reader', [modelName '/Audio_Input']);
set_param([modelName '/Audio_Input'], ...
    'Device', config.inputDevice, ...
    'SampleRate', num2str(config.sampleRate), ...
    'SamplesPerFrame', num2str(config.samplesPerFrame), ...
    'OutputDataType', 'double', ...
    'NumChannels', num2str(config.numChannels), ...
    'QueueDuration', '0.5');

% --- Terminator for unused output ---
add_block('simulink/Sinks/Terminator', [modelName '/Terminator']);

% --- Mux for combining signals ---
add_block('simulink/Signal Routing/Mux', [modelName '/Mux_Signals']);
set_param([modelName '/Mux_Signals'], 'Inputs', '2');

% --- Time Scope for Waveform Display ---
add_block('simulink/Sinks/Scope', [modelName '/Waveform_Scope']);
scopeConfig = get_param([modelName '/Waveform_Scope'], 'ScopeConfiguration');
scopeConfig.NumInputPorts = '2';
scopeConfig.LayoutDimensions = [2, 1];
scopeConfig.TimeSpan = '0.05';
set_param([modelName '/Waveform_Scope'], 'ScopeConfiguration', scopeConfig);

% --- Spectrum Analyzer for Transmitted Signal ---
add_block('dsp/Sinks/Spectrum Analyzer', [modelName '/Spectrum_TX']);
set_param([modelName '/Spectrum_TX'], ...
    'SampleRate', num2str(config.sampleRate), ...
    'PlotAsTwoSidedSpectrum', 'off', ...
    'FrequencyScale', 'Linear', ...
    'Title', 'Transmitted Signal Spectrum', ...
    'YLimits', '[-100 0]');

% --- Spectrum Analyzer for Received Signal ---
add_block('dsp/Sinks/Spectrum Analyzer', [modelName '/Spectrum_RX']);
set_param([modelName '/Spectrum_RX'], ...
    'SampleRate', num2str(config.sampleRate), ...
    'PlotAsTwoSidedSpectrum', 'off', ...
    'FrequencyScale', 'Linear', ...
    'Title', 'Received Signal Spectrum', ...
    'YLimits', '[-100 0]');

% --- MATLAB Function for Latency Measurement ---
add_block('simulink/User-Defined Functions/MATLAB Function', [modelName '/Latency_Calculator']);

% Set the MATLAB Function code
latencyCode = sprintf([...
    'function [latency_ms, correlation] = fcn(tx_signal, rx_signal, Fs)\n' ...
    '%%#codegen\n' ...
    'persistent buffer_tx buffer_rx\n' ...
    'bufferSize = 4096;\n' ...
    'frameSize = length(tx_signal);\n' ...
    '\n' ...
    'if isempty(buffer_tx)\n' ...
    '    buffer_tx = zeros(bufferSize, 1);\n' ...
    '    buffer_rx = zeros(bufferSize, 1);\n' ...
    'end\n' ...
    '\n' ...
    '%% Update buffers\n' ...
    'buffer_tx = [buffer_tx(frameSize+1:end); tx_signal(:)];\n' ...
    'buffer_rx = [buffer_rx(frameSize+1:end); rx_signal(:)];\n' ...
    '\n' ...
    '%% Cross-correlation to find delay\n' ...
    '[xcorr_result, lags] = xcorr(buffer_rx, buffer_tx, bufferSize/2);\n' ...
    '[~, maxIdx] = max(abs(xcorr_result));\n' ...
    'delay_samples = lags(maxIdx);\n' ...
    '\n' ...
    '%% Convert to milliseconds\n' ...
    'latency_ms = (delay_samples / Fs) * 1000;\n' ...
    'correlation = max(abs(xcorr_result)) / (norm(buffer_tx) * norm(buffer_rx) + eps);\n']);

% Note: MATLAB Function block code needs to be set via the block dialog
% We'll create a separate file for the function

% --- Display for Latency ---
add_block('simulink/Sinks/Display', [modelName '/Latency_Display']);
set_param([modelName '/Latency_Display'], ...
    'Format', 'short', ...
    'Decimation', '1');

% --- Constant for Sample Rate ---
add_block('simulink/Sources/Constant', [modelName '/SampleRate_Const']);
set_param([modelName '/SampleRate_Const'], 'Value', num2str(config.sampleRate));

%% Position Blocks
set_param([modelName '/Sine_Generator'], 'Position', [50, 100, 130, 140]);
set_param([modelName '/Audio_Output'], 'Position', [250, 95, 350, 145]);
set_param([modelName '/Audio_Input'], 'Position', [50, 250, 150, 300]);
set_param([modelName '/Terminator'], 'Position', [200, 275, 220, 295]);
set_param([modelName '/Waveform_Scope'], 'Position', [500, 150, 550, 200]);
set_param([modelName '/Spectrum_TX'], 'Position', [250, 170, 350, 220]);
set_param([modelName '/Spectrum_RX'], 'Position', [250, 310, 350, 360]);
set_param([modelName '/Latency_Calculator'], 'Position', [400, 250, 500, 320]);
set_param([modelName '/Latency_Display'], 'Position', [550, 260, 620, 310]);
set_param([modelName '/SampleRate_Const'], 'Position', [300, 340, 360, 360]);
set_param([modelName '/Mux_Signals'], 'Position', [430, 145, 440, 210]);

%% Connect Blocks
% Sine to Audio Output
add_line(modelName, 'Sine_Generator/1', 'Audio_Output/1');

% Sine to Spectrum TX
add_line(modelName, 'Sine_Generator/1', 'Spectrum_TX/1');

% Audio Input to Spectrum RX
add_line(modelName, 'Audio_Input/1', 'Spectrum_RX/1');

% Audio Input overflow to Terminator
add_line(modelName, 'Audio_Input/2', 'Terminator/1');

% Signals to Mux for Scope
add_line(modelName, 'Sine_Generator/1', 'Mux_Signals/1');
add_line(modelName, 'Audio_Input/1', 'Mux_Signals/2');

% Mux to Scope
add_line(modelName, 'Mux_Signals/1', 'Waveform_Scope/1');

%% Save the model
save_system(modelName);

fprintf('Model "%s" created successfully!\n', modelName);
fprintf('\n=== IMPORTANT SETUP STEPS ===\n');
fprintf('1. Open the model: open_system(''%s'')\n', modelName);
fprintf('2. Double-click "Latency_Calculator" and paste the code from "latency_function.m"\n');
fprintf('3. Connect the Latency_Calculator block:\n');
fprintf('   - Input 1: Sine_Generator output\n');
fprintf('   - Input 2: Audio_Input output\n');
fprintf('   - Input 3: SampleRate_Const output\n');
fprintf('   - Output 1: Latency_Display input\n');
fprintf('4. Verify audio device names match your system\n');
fprintf('5. Run the model\n\n');

%% Alternative: Run MATLAB-based real-time system
fprintf('Or run the MATLAB script version: run_audio_loopback_test.m\n');
