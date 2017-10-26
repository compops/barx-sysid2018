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
 
%save('../data/example1-arx.mat', 'dataIn', 'dataOutNoisy', 'a', 'b', '-v4')

load('../data/example1-arx.mat')

%% Naive solution
estimationData = iddata(dataOutNoisy(1:noEstimationData), dataIn(1:noEstimationData));
validationData = iddata(dataOutNoisy(noEstimationData:end), dataIn(noEstimationData:end));

res = arx(estimationData, [4 5 0]);
pre = predict(res, validationData);
pre = pre.OutputData;

%%
noValidationData = noValidationData + 1;
plot(1:noValidationData, dataOutNoisy(noEstimationData:end), 1:noValidationData, pre, 'r')

%%
mf = 100 * (1 - sum((pre - dataOutNoisy(noEstimationData:end)).^2) / sum((dataOutNoisy(noEstimationData:end) - mean(dataOutNoisy(noEstimationData:end))).^2));
