function outputSignal = addChorus(inputSignal, fs, numEchoes, echoDelay, decayFactor, gain, numVoices, modulationDepth, modulationRate)
    N = round(echoDelay * fs);
    for v=1:numVoices
        voiceDelay = echoDelay + modulationDepth* sin(2 * pi * modulationRate * (0:length(inputSignal)-1) / fs);
        filterCoefficients = zeros(N * numEchoes, 1); % Prealloker koefficienter
        A=1;
        % Create filterCoefficients
        for i = 1:numEchoes
            filterCoefficients((i - 1) * N + 1) = A;
            % Update coefficient A with decayFactor
            A = A * decayFactor;
        end
        shiftSamples = round(voiceDelay * fs);
        shiftedSignal = circshift(inputSignal, shiftSamples);
        
        echoSignal = filter(filterCoefficients, 1, shiftedSignal);
    
        outputSignal=echoSignal+inputSignal;
        echoDelay = echoDelay * (1 + randn(1) * 0.05); % Randomize delay slightly
    end
    % Add gain
    outputSignal = outputSignal * gain;
    % Normalize the output to prevent clipping
    outputSignal = outputSignal / max(abs(outputSignal(:)));
    
end
