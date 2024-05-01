%% IIR Low pass filter

% Import audio
[sample_input, Fs] = audioread('SultansOfSwing.wav');
sample_input = sample_input(:,1)';
N = length(sample_input);
filtered_signal = zeros(1, length(sample_input));

% Filter coefficients
order = 6;
cutoff_frequency = 3000;
setting = 'high';

f_c_normalized = cutoff_frequency/(Fs/2);
[b, a] = butter(order, f_c_normalized, setting);

for n = 1:N
    filtered_signal(n) = b(1) * sample_input(n);

    for k = 2:length(b)
        if n-k+1 > 0
            filtered_signal(n) = filtered_signal(n) + b(k) * sample_input(n-k+1); % Tilføj feedforward hvis muligt
        end
    end
    for l = 2:length(a)
        if n-l+1 > 0
            filtered_signal(n) = filtered_signal(n) - a(l)*filtered_signal(n - l + 1); % Tilføj feedback hvis muligt
        end
    end
end

f_delta = Fs/N;
f_axis = [0:f_delta:Fs-f_delta];

% FFT input sample
fft_input_sample = fft(sample_input);
fft_temp_input = 20*log10(abs( fft_input_sample(1:N/2)) ); % Halver for at undgå spejling
f_axis_temp = f_axis(1:length(f_axis)/2); % Halver for at undgå spejling

% Plot input signal
fig1 = figure(1); clf
ax1 = axes(fig1);
hold on;
semilogx(f_axis_temp, fft_temp_input);
ax1.XScale = 'log'; % Tving "Hold on" til at holde op med at ødelægge mit plot
line([cutoff_frequency, cutoff_frequency], ylim, 'Color', 'r', 'LineStyle', '--'); % Straight line at x_value
title('Frequency spectrum of input sample');
xlabel('Frequency Hz');
ylabel('Amplitude [dB]');

% FFT filtered sample
fft_filter_output = fft(filtered_signal);
fft_temp_output = 20*log10(abs( fft_filter_output(1:N/2)) ); % Halver for at undgå spejling

% Plot filtered signal
fig2 = figure(2); clf
ax2 = axes(fig2);
hold on;

semilogx(f_axis_temp, fft_temp_output);
ax2.XScale = 'log'; % Tving "Hold on" til at holde op med at ødelægge mit plot
line([cutoff_frequency, cutoff_frequency], ylim, 'Color', 'r', 'LineStyle', '--'); % Straight line at x_value
title(['Frequency spectrum of resulting signal after ', num2str(order), '. order', setting, '-pass IIR filter with ', num2str(cutoff_frequency), 'Hz cutoff frequency '])
xlabel('Frequency Hz');
ylabel('Amplitude [dB]');

% Play filtered sample
%sound(filtered_signal, Fs);


