clear
clc
% Load your input signal
[inputSignal, fs] = audioread('SultansShort.wav');

% Echo parameters
numEchoes = 3; %How many echo repeats?
echoDelay = 0.03; %How big does the room feel?
decayFactor = 0.8; %How loud are subsequent echoes or: how quickly do echoes fade?
gain = 1; %How loud are the echoes compared to the original sound? (unused rn)

%Chorus parameters
chorusVoices = 3; %
modulationDepth = 15;
modulationRate = 5;

% Call the function
%Single Echo
outputSignal = addEchoNoInbuilt(inputSignal, fs, numEchoes, echoDelay, decayFactor, gain);

N = length(outputSignal);
order = 6;
cutoff = 4500;
mode = "high";

postPassFilter = passFilter(order, cutoff, mode, outputSignal, fs);

f_delta = fs/N;
f_axis = [0:f_delta:fs-f_delta];

% FFT input sample
fft_input_sample = fft(outputSignal);
fft_temp_input = 20*log10(abs( fft_input_sample(1:N/2)) ); % Halver for at undgå spejling
f_axis_temp = f_axis(1:length(f_axis)/2); % Halver for at undgå spejling

% Plot input signal
fig1 = figure(1); clf
ax1 = axes(fig1);
hold on;
semilogx(f_axis_temp, fft_temp_input);
ax1.XScale = 'log'; % Tving "Hold on" til at holde op med at ødelægge mit plot
line([cutoff, cutoff], ylim, 'Color', 'r', 'LineStyle', '--'); % Straight line at x_value
title('Frequency spectrum of input sample');
xlabel('Frequency Hz');
ylabel('Amplitude [dB]');

% FFT filtered sample
fft_filter_output = fft(postPassFilter);
%disp(length(postPassFilter))
%disp(N/2)
%disp(length(fft_filter_output))
fft_temp_output = 20*log10(abs( fft_filter_output(1:N/2)) ); % Halver for at undgå spejling

% Plot filtered signal
fig2 = figure(2); clf
ax2 = axes(fig2);
hold on;

semilogx(f_axis_temp, fft_temp_output);
ax2.XScale = 'log'; % Tving "Hold on" til at holde op med at ødelægge mit plot
line([cutoff, cutoff], ylim, 'Color', 'r', 'LineStyle', '--'); % Straight line at x_value
title(['Frequency spectrum of resulting signal after ', num2str(order), '. order', mode, '-pass IIR filter with ', num2str(cutoff), 'Hz cutoff frequency '])
xlabel('Frequency Hz');
ylabel('Amplitude [dB]');

% Play filtered sample
%sound(filtered_signal, Fs);








%Chorus
%outputSignal = addChorusNoInbuilt(inputSignal, fs, numEchoes, echoDelay, decayFactor, gain, chorusVoices, modulationDepth, modulationRate);



% Press play på det shit
%sound(inputSignal, fs); % Play original signal
%pause(length(inputSignal) / fs); % Pause to play the echoed signal separately
sound(outputSignal, fs); % Play echoed signal


