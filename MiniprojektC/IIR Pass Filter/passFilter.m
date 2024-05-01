%% IIR Low pass filter

function filtered_signal = passFilter(order, cutoff_frequency, mode, sampleInput, Fs)

    if order < 1 || order > 8
        disp("Order must be between 1 and 8")
        return;
    end

    if cutoff_frequency < 1000 || cutoff_frequency > 7000
       disp("Cutoff frequency must be between 1000 and 7000")
       return;
    end

    if size(sampleInput, 1) > 1
        disp("Taking only left channel because fuck you")
        sampleInput = sampleInput(:,1);
    end

    N = length(sampleInput);
    filtered_signal = zeros(1, N);

    f_c_normalized = cutoff_frequency/(Fs/2);
    [b, a] = butter(order, f_c_normalized, mode);
    disp('a')
    disp(a)
    disp('b')
    disp(b)

    for n = 1:N
        filtered_signal(n) = b(1) * sampleInput(n);

        for k = 2:length(b)
            if n-k+1 > 0
                filtered_signal(n) = filtered_signal(n) + b(k) * sampleInput(n-k+1); % Tilføj feedforward hvis muligt
            end
        end
        for l = 2:length(a)
            if n-l+1 > 0
                filtered_signal(n) = filtered_signal(n) - a(l)*filtered_signal(n - l + 1); % Tilføj feedback hvis muligt
            end
        end
    end
end


