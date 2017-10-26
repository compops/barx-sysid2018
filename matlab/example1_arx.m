rng(54531445)

noObservations = 1000;
noEstimationData = floor(0.67 * noObservations);
noValidationData = noObservations - noEstimationData;
systemOrder = 2;

[b, a] = cheby1(systemOrder, 5, [0.2 0.6], 'stop');
dataIn = randn(noObservations, 1);
dataOut = filter(b, a, dataIn);

indicator = randsample(2, noObservations, true, [0.2 0.8]);
noise = 0.5 * randn(noObservations, 1);
dataOutNoisy = dataOut + noise;

save('../data/example1-arx.mat', 'dataIn', 'dataOutNoisy', 'a', 'b', '-v4')

%% Oracle
oracleOutput = dataOut + noise;

oracleEstimationData = iddata(dataOutNoisy(1:noEstimationData), dataIn(1:noEstimationData));
oracleValidationData = iddata(dataOutNoisy(noEstimationData:end), dataIn(noEstimationData:end));
res1 = arx(oracleEstimationData,[4 5 0]);
pre1 = predict(res1, oracleValidationData);
pre1 = pre1.OutputData;

res1.A
res1.B

%% Naive solution
estimationData = iddata(dataOutNoisy(1:noEstimationData), dataIn(1:noEstimationData));
validationData = iddata(dataOutNoisy(noEstimationData:end), dataIn(noEstimationData:end));

res2 = arx(estimationData, [4 5 0]);
pre2 = predict(res1, oracleValidationData);
pre2 = pre2.OutputData;
%%

plot(1:noObservations, dataOutNoisy, 1:noObservations, dataOut + noise3, 'r')
%%
noValidationData = noValidationData + 1;
plot(1:noValidationData, dataOutNoisy(noEstimationData:end), 1:noValidationData, pre1, 'g', 1:noValidationData, pre2, 'r')

%%
mf1 = 100 * (1 - sum((pre1 - dataOutNoisy(noEstimationData:end)).^2) / sum((dataOutNoisy(noEstimationData:end) - mean(dataOutNoisy(noEstimationData:end))).^2));
mf2 = 100 * (1 - sum((pre2 - dataOutNoisy(noEstimationData:end)).^2) / sum((dataOutNoisy(noEstimationData:end) - mean(dataOutNoisy(noEstimationData:end))).^2));
