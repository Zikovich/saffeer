function [latency_ms, correlation] = fcn(tx_signal, rx_signal, Fs)
%#codegen
% Latency Calculator using Cross-Correlation
%
% This function measures the round-trip latency between transmitted and
% received audio signals using cross-correlation.
%
% Inputs:
%   tx_signal   - Transmitted signal frame (column vector)
%   rx_signal   - Received signal frame (column vector)
%   Fs          - Sample rate in Hz
%
% Outputs:
%   latency_ms  - Measured latency in milliseconds
%   correlation - Normalized correlation coefficient (0-1)
%
% Usage:
%   Copy this entire function into the MATLAB Function block in Simulink

persistent buffer_tx buffer_rx
bufferSize = 4096;  % Buffer size for correlation (adjust if needed)
frameSize = length(tx_signal);

% Initialize buffers on first call
if isempty(buffer_tx)
    buffer_tx = zeros(bufferSize, 1);
    buffer_rx = zeros(bufferSize, 1);
end

% Update circular buffers with new frame data
buffer_tx = [buffer_tx(frameSize+1:end); tx_signal(:)];
buffer_rx = [buffer_rx(frameSize+1:end); rx_signal(:)];

% Cross-correlation to find delay
maxLag = bufferSize/2;
[xcorr_result, lags] = xcorr(buffer_rx, buffer_tx, maxLag);

% Find peak correlation
[maxVal, maxIdx] = max(abs(xcorr_result));
delay_samples = lags(maxIdx);

% Convert delay to milliseconds
latency_ms = double(delay_samples) / double(Fs) * 1000;

% Calculate normalized correlation coefficient
norm_tx = sqrt(sum(buffer_tx.^2));
norm_rx = sqrt(sum(buffer_rx.^2));
correlation = maxVal / (norm_tx * norm_rx + 1e-10);

end
