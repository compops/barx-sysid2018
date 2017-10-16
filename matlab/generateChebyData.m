noObservations = 1000;
systemOrder = 2;

[b, a] = cheby1(systemOrder, 5, [0.2 0.6], 'stop');
dataIn = randn(noObservations, 1);
dataOut = filter(b, a, dataIn);

%indicator = randsample(2, noObservations, true, [0.2 0.8]);
%noise1 = 10 + 0.50 * randn(noObservations, 1);
noise2 = 0  + 0.50 * randn(noObservations, 1);
noise = noise2;
%noise(indicator == 1) = noise1(indicator == 1);
dataOutNoisy = dataOut + noise;

save('chebyData.mat', 'dataIn', 'dataOutNoisy', 'a', 'b', '-v4')

res = arx(iddata(dataOutNoisy, dataIn),[4 5 0]);
res.A
res.B

a
b

