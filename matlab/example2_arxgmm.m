clear all

%% Generate data
rng(54531445)

noObservations = 1000;
noEstimationData = floor(0.67 * noObservations);
noValidationData = noObservations - noEstimationData;
systemOrder = 2;

[b, a] = cheby1(systemOrder, 5, [0.2 0.6], 'stop');
dataIn = randn(noObservations, 1);
dataOut = filter(b, a, dataIn);

indicator = randsample(2, noObservations, true, [0.2 0.8]);
noise1 = 4 + 0.50 * randn(noObservations, 1);
noise2 = 0  + 0.50 * randn(noObservations, 1);
noise = noise2;
noise(indicator == 1) = noise1(indicator == 1);
dataOutNoisy = dataOut + noise;

save('../data/example2_arxgmm.mat', 'dataIn', 'dataOutNoisy', 'a', 'b', '-v4')

% Estimate the one-step ahead predictor on validation data using an 
% oracle that knows the offset
noise3 = noise;
noise3(indicator == 1) = noise3(indicator == 1) - 3;
oracleOutput = dataOut + noise3;

oracleEstimationData = iddata(oracleOutput(1:noEstimationData), dataIn(1:noEstimationData));
oracleValidationData = iddata(oracleOutput(noEstimationData:end), dataIn(noEstimationData:end));
res1 = arx(oracleEstimationData,[4 5 0]);
pre1 = predict(res1, oracleValidationData);
pre1 = pre1.OutputData;
pre1(indicator(noEstimationData:end) == 1) = pre1(indicator(noEstimationData:end) == 1) + 3;
mf1 = 100 * (1 - sum((pre1 - dataOutNoisy(noEstimationData:end)).^2) / sum((dataOutNoisy(noEstimationData:end) - mean(dataOutNoisy(noEstimationData:end))).^2));

%% Estimate the one-step ahead predictor on validation data
estimationData = iddata(dataOutNoisy(1:noEstimationData), dataIn(1:noEstimationData));
validationData = iddata(dataOutNoisy(noEstimationData:end), dataIn(noEstimationData:end));
noValidationData = length(validationData.OutputData);

res2 = arx(estimationData, [4 5 0]);
pre2 = predict(res2, validationData);
pre2 = pre2.OutputData;

plot(1:noValidationData, dataOutNoisy(noEstimationData:end), 1:noValidationData, pre2, 'r')
mf2 = 100 * (1 - sum((pre2 - dataOutNoisy(noEstimationData:end)).^2) / sum((dataOutNoisy(noEstimationData:end) - mean(dataOutNoisy(noEstimationData:end))).^2));

%%
save('../results/example2_arxgmm_prediction.mat', 'pre2')
save('example2_arxgmm_workspace.mat')