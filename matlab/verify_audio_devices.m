%% Audio Device Verification Script
% Run this FIRST to verify your audio devices are detected correctly
% before running the loopback test

clear; clc;
fprintf('=== Audio Device Verification ===\n\n');

%% Check Required Toolboxes
fprintf('Checking required toolboxes...\n');
requiredToolboxes = {'Audio Toolbox', 'DSP System Toolbox', 'Signal Processing Toolbox'};
missingToolboxes = {};

v = ver;
installedToolboxes = {v.Name};

for i = 1:length(requiredToolboxes)
    if any(contains(installedToolboxes, requiredToolboxes{i}))
        fprintf('  [OK] %s\n', requiredToolboxes{i});
    else
        fprintf('  [MISSING] %s\n', requiredToolboxes{i});
        missingToolboxes{end+1} = requiredToolboxes{i};
    end
end

if ~isempty(missingToolboxes)
    fprintf('\nWARNING: Some required toolboxes are missing!\n');
    fprintf('Please install them using the Add-On Explorer.\n\n');
end

%% List Audio Devices
fprintf('\n--- Output Devices (Speakers/Headphones) ---\n');
try
    devWriter = audioDeviceWriter;
    outputDevices = getAudioDevices(devWriter);
    for i = 1:length(outputDevices)
        if contains(outputDevices{i}, 'USB Audio Demonstration', 'IgnoreCase', true)
            fprintf('  [%d] %s  <-- TARGET DEVICE\n', i, outputDevices{i});
        else
            fprintf('  [%d] %s\n', i, outputDevices{i});
        end
    end
    release(devWriter);
catch ME
    fprintf('  ERROR: Could not enumerate output devices\n');
    fprintf('  %s\n', ME.message);
end

fprintf('\n--- Input Devices (Microphones) ---\n');
try
    devReader = audioDeviceReader;
    inputDevices = getAudioDevices(devReader);
    for i = 1:length(inputDevices)
        if contains(inputDevices{i}, 'USB Audio Demonstration', 'IgnoreCase', true)
            fprintf('  [%d] %s  <-- TARGET DEVICE\n', i, inputDevices{i});
        else
            fprintf('  [%d] %s\n', i, inputDevices{i});
        end
    end
    release(devReader);
catch ME
    fprintf('  ERROR: Could not enumerate input devices\n');
    fprintf('  %s\n', ME.message);
end

%% Find RA8P1 USB Audio Devices
fprintf('\n--- Searching for RA8P1 USB Audio Devices ---\n');

outputMatch = '';
inputMatch = '';

% Search for output device
for i = 1:length(outputDevices)
    if contains(outputDevices{i}, 'USB Audio Demonstration', 'IgnoreCase', true) || ...
       contains(outputDevices{i}, 'Headphones (3-', 'IgnoreCase', true)
        outputMatch = outputDevices{i};
        break;
    end
end

% Search for input device
for i = 1:length(inputDevices)
    if contains(inputDevices{i}, 'USB Audio Demonstration', 'IgnoreCase', true) || ...
       contains(inputDevices{i}, 'Microphone', 'IgnoreCase', true) && ...
       contains(inputDevices{i}, '3-', 'IgnoreCase', true)
        inputMatch = inputDevices{i};
        break;
    end
end

if ~isempty(outputMatch)
    fprintf('  Output device found: %s\n', outputMatch);
else
    fprintf('  WARNING: Could not find RA8P1 output device!\n');
    fprintf('  Expected: "Headphones (3- USB Audio Demonstration)"\n');
end

if ~isempty(inputMatch)
    fprintf('  Input device found: %s\n', inputMatch);
else
    fprintf('  WARNING: Could not find RA8P1 input device!\n');
    fprintf('  Expected: "Microphone (3- USB Audio Demonstration)"\n');
end

%% Test Audio Output (Optional)
fprintf('\n--- Test Audio Output ---\n');
testOutput = input('Do you want to test audio output? (y/n): ', 's');

if strcmpi(testOutput, 'y')
    Fs = 48000;
    duration = 2;
    freq = 1000;
    
    fprintf('Playing %d Hz tone for %d seconds...\n', freq, duration);
    
    t = (0:1/Fs:duration)';
    testTone = 0.5 * sin(2*pi*freq*t);
    
    try
        if ~isempty(outputMatch)
            player = audioplayer(testTone, Fs);
            % Note: audioplayer uses default device
            play(player);
            pause(duration + 0.5);
            fprintf('Test complete. Did you hear the tone?\n');
        else
            sound(testTone, Fs);
            pause(duration + 0.5);
            fprintf('Test complete (using default device).\n');
        end
    catch ME
        fprintf('ERROR playing audio: %s\n', ME.message);
    end
end

%% Test Audio Input (Optional)
fprintf('\n--- Test Audio Input ---\n');
testInput = input('Do you want to test audio input? (y/n): ', 's');

if strcmpi(testInput, 'y')
    Fs = 48000;
    duration = 3;
    
    fprintf('Recording for %d seconds...\n', duration);
    
    try
        if ~isempty(inputMatch)
            recorder = audioDeviceReader('Device', inputMatch, ...
                'SampleRate', Fs, 'SamplesPerFrame', 1024);
            
            numFrames = ceil(duration * Fs / 1024);
            recordedAudio = zeros(numFrames * 1024, 1);
            
            for i = 1:numFrames
                [frame, ~] = recorder();
                recordedAudio((i-1)*1024+1:i*1024) = frame(:,1);
            end
            release(recorder);
        else
            recorder = audiorecorder(Fs, 16, 1);
            recordblocking(recorder, duration);
            recordedAudio = getaudiodata(recorder);
        end
        
        fprintf('Recording complete.\n');
        fprintf('Max amplitude: %.4f\n', max(abs(recordedAudio)));
        fprintf('RMS level: %.4f\n', rms(recordedAudio));
        
        % Plot recorded audio
        figure('Name', 'Recorded Audio Test');
        subplot(2,1,1);
        t = (0:length(recordedAudio)-1)/Fs;
        plot(t, recordedAudio);
        xlabel('Time (s)');
        ylabel('Amplitude');
        title('Recorded Audio Waveform');
        grid on;
        
        subplot(2,1,2);
        [pxx, f] = pwelch(recordedAudio, 1024, 512, 1024, Fs);
        plot(f/1000, 10*log10(pxx));
        xlabel('Frequency (kHz)');
        ylabel('Power (dB)');
        title('Recorded Audio Spectrum');
        grid on;
        
    catch ME
        fprintf('ERROR recording audio: %s\n', ME.message);
    end
end

%% Summary
fprintf('\n');
fprintf('='.^50 + '\n');
fprintf('SUMMARY\n');
fprintf('='.^50 + '\n');

if ~isempty(outputMatch) && ~isempty(inputMatch) && isempty(missingToolboxes)
    fprintf('\n[SUCCESS] All requirements met!\n\n');
    fprintf('You can now run:\n');
    fprintf('  >> build_simulink_model    (for Simulink)\n');
    fprintf('  >> run_audio_loopback_test (for standalone MATLAB)\n');
else
    fprintf('\n[WARNING] Some issues detected:\n');
    if isempty(outputMatch)
        fprintf('  - Output device not found\n');
    end
    if isempty(inputMatch)
        fprintf('  - Input device not found\n');
    end
    if ~isempty(missingToolboxes)
        fprintf('  - Missing toolboxes: %s\n', strjoin(missingToolboxes, ', '));
    end
    fprintf('\nPlease resolve these issues before running the loopback test.\n');
end

%% Save Device Names for Other Scripts
if ~isempty(outputMatch) && ~isempty(inputMatch)
    deviceConfig.outputDevice = outputMatch;
    deviceConfig.inputDevice = inputMatch;
    save('detected_devices.mat', 'deviceConfig');
    fprintf('\nDevice names saved to detected_devices.mat\n');
end
