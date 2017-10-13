[b, a] = cheby1(2, 5, [0.2 0.6],'stop');
dataIn = randn(500, 1);
dataOut = filter(b, a, dataIn);
save('chebyData.mat', 'dataIn', 'dataOut', 'a', 'b', '-v4')