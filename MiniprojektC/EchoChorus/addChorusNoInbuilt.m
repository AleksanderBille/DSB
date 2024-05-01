function outputSignal = addChorusNoInbuilt(inputSignal, fs, numEchoes, echoDelay, decayFactor, gain, chorusVoices, modulationDepth, modulationRate)
    if size(inputSignal, 2) > 1
        inputLeft = inputSignal(:, 1); % First channel
        %inputRight = inputSignal(:, 2); % Second channel
    else
        inputLeft = inputSignal; % Make double mono
        %inputRight = inputSignal; % Make double mono
    end
    
    maxVoiceShift=fs*0.01; % max voice shift eller N sættes til 0.1 seconds

    % Generer impulsrespons for ekko-effekten
    IR = createEchoIR(fs, numEchoes, echoDelay, decayFactor);
    outputSignalLeft = inputLeft;
    for i=1:chorusVoices %lav echo for hver voice
       
        delayVariation = round((rand(1) * 2 - 1) * modulationDepth * maxVoiceShift);
        shiftedSignal = shiftSignal(inputLeft, delayVariation); %lav et tilfældigt shifted version af inputsignal

        echoSignalLeft = myEchoFIR(shiftedSignal, IR);

        gainVariation = 1 + (rand(1) * 2 - 1) * modulationRate; %nummer mellem -modulationRate og +modulationRate
        echoSignalLeft = echoSignalLeft .* gainVariation; %læg den random gain på ekkoet

       
        outputSignalLeft = echoSignalLeft+outputSignalLeft; %læg ekkoet på inputsignalet
    end
    
    %outputRight = myEchoFIR(inputRight, IR);      %Deciding to only work on left ear input  
    outputSignal = outputSignalLeft;
    %normalize til sidst
    outputSignal = outputSignal / max(abs(outputSignal(:)));
end

function shiftedSignal = shiftSignal(signal, shiftAmount)
    % Circular shift the signal
    shiftedSignal = circshift(signal, shiftAmount);
    % If shifting to the right, pad the left end with zeroes
    if shiftAmount > 0
        shiftedSignal(1:shiftAmount) = 0;
    % If shifting to the left, pad the right end with zeroes
    elseif shiftAmount < 0
        shiftedSignal(end+shiftAmount+1:end) = 0;
    end
end

function IR = createEchoIR(fs, numEchoes, echoDelay, decayFactor)
    N = round(echoDelay * fs);
    IR = zeros(1, N*numEchoes);
    p = 1;
    %IR(p) = 1; Generer KUN ekko-signal, originalt signal inkluderes ikke.
    for i=1:numEchoes
        p = p * decayFactor;
        IR(N*numEchoes) = p;
    end
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
    echoSignal = transpose(echoSignal);
end