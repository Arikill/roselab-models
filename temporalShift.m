function Y = temporalShift(X, shiftTime, fs)
    Y = X;
    N = floor(abs(shiftTime)*fs);
    samples = zeros(size(Y, 1), N);
    if shiftTime > 0
        samples = samples + Y(:, 1);
        if N < size(Y, 2)
            Y = cat(2, samples, Y(:, 1:end-N));
        else
            Y = Y*0 + Y(:, 1);
        end
    elseif shiftTime < 0
        samples = samples + Y(:, end);
        if N < size(Y, 2)
            Y = cat(2, Y(:, (N+1):end), samples);
        else
            Y = Y*0 + Y(:, end);
        end
    end
end