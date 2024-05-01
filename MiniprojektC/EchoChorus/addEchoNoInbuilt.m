function outputSignal = addEchoNoInbuilt(inputSignal, fs, numEchoes, echoDelay, decayFactor, gain)
    if size(inputSignal, 2) > 1
        inputLeft = inputSignal(:, 1); % First channel
        inputRight = inputSignal(:, 2); % Second channel
    else
        inputLeft = inputSignal; % Make double mono
        inputRight = inputSignal; % Make double mono
    end

    % Generer impulsrespons for ekko-effekten
    IR = createEchoIR(fs, numEchoes, echoDelay, decayFactor);

    outputLeft = myEchoFIR(inputLeft, IR);
    outputRight = myEchoFIR(inputRight, IR);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frekvensanalyse

inputSignal_FFT = fft(inputLeft);
lenI = length(inputLeft);
t = (0:lenI-1) / fs; % Correct calculation of time vector
IR_FFT = fft(IR, lenI); % Remember to zero-pad IR.
echoSignal_FFT = inputSignal_FFT .* transpose(IR_FFT);
echoSignal = ifft(echoSignal_FFT);

% Plot input and output signals in time domain
figure;
subplot(2,1,1);
s1 = size(inputLeft);
s2 = size(echoSignal);
s3 = size(t);
disp(s1);
disp(s2);
disp(s3);

plot(t, inputLeft, 'b', t, echoSignal, 'r');
xlabel('Time (s)');
ylabel('Amplitude');
title('Input and Echoed Signals (Time Domain)');
legend('Input Signal', 'Echoed Signal');

% Plot input and output signals in frequency domain
inputSignal_FFT = fft(inputSignal);
echoSignal_FFT = fft(echoSignal);
f = (0:lenI-1)*fs/lenI; % Correct calculation of frequency vector
subplot(2,1,2);
plot(f, abs(inputSignal_FFT), 'b', f, abs(echoSignal_FFT), 'r');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Input and Echoed Signals (Frequency Domain)');
legend('Input Signal', 'Echoed Signal');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    outputSignal = outputLeft;
end

function echoSignal = myEchoFIR(inputSignal, IR)
    
    lenInput = length(inputSignal);
    lenIR = length(IR);
    echoSignal = zeros(1, lenInput);
    for i = 1:lenInput
        for j = 1:lenIR
            if i + j - 1 <= lenInput % Stop giving me out of bounds errors!
                echoSignal(i + j - 1) = echoSignal(i + j - 1) + inputSignal(i) * IR(j);
            end
        end
    end
end

function IR = createEchoIR(fs, numEchoes, echoDelay, decayFactor)
    N = round(echoDelay * fs);
    IR = zeros(1, N*numEchoes);
    p = 1;
    %IR(p) = 1; kommenteret ud fordi vi generer KUN ekko-signal, originalt signal inkluderes ikke.
    for i=1:numEchoes
        p = p * decayFactor;
        IR(N*i) = p;
    end
end