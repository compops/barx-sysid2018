clear all

%% Generate data
rng(54531445)
noObservations = 1000;

% From the documentation of the ARX command
A = [1  -1.5  0.7];
B = [0 1 0.5];
m0 = idpoly(A, B);
u = iddata([], idinput(noObservations, 'rbs'));
e = iddata([], randn(noObservations, 1));
y = sim(m0,[u e]);
z = [y, u];

dataIn = u.InputData;
dataOutNoisy = y.OutputData;

% Save to file
a = A;
b = B;
save('../data/example1_arx.mat', 'dataIn', 'dataOutNoisy', 'a', 'b', '-v4')

%% Estimate the model when the model order is unknown

% Select model order by exhaustive search using half of the estimation set
% for estimating model and the remaining for computing the prediction error
noDataPoints = floor(0.33 * noObservations);
estimationData1 = iddata(dataOutNoisy(1:noDataPoints), dataIn(1:noDataPoints));
estimationData2 = iddata(dataOutNoisy(noDataPoints:(2*noDataPoints)), dataIn(noDataPoints:(2*noDataPoints)));

predictionError = zeros([5 5]);
for na=1:5
    for nb=1:5
        modelEstimate = arx(estimationData1, [na nb 0]);
        predictionErrObject = pe(modelEstimate, estimationData2);
        predictionError(na, nb) = sum((predictionErrObject.OutputData).^2);
        disp([na nb]);
    end
end

% Find the model order that minimises the squared prediction error
idx = find(min(min(predictionError)) == predictionError);
[na, nb] = ind2sub([5 5], idx);

% Estimate the model using all the estimation data
noEstimationData = floor(0.67 * noObservations);
noValidationData = noObservations - noEstimationData;
estimationData = iddata(dataOutNoisy(1:noEstimationData), dataIn(1:noEstimationData));
validationData = iddata(dataOutNoisy(noEstimationData:end), dataIn(noEstimationData:end));

modelEstimate = arx(estimationData1, [na nb 0]);
yhat = predict(modelEstimate, validationData);
yhat = yhat.OutputData;

aHat = modelEstimate.a;
bHat = modelEstimate.b;
modelFit = 100 * (1 - sum((yhat - dataOutNoisy(noEstimationData:end)).^2) / sum((dataOutNoisy(noEstimationData:end) - mean(dataOutNoisy(noEstimationData:end))).^2));

%% Estimate the model when the model order is known

modelEstimate = arx(estimationData1, [2 3 0]);
yhatOracle = predict(modelEstimate, validationData);
yhatOracle = yhatOracle.OutputData;

aHatOracle = modelEstimate.a;
bHatOracle = modelEstimate.b;
modelFitOracle = 100 * (1 - sum((yhatOracle - dataOutNoisy(noEstimationData:end)).^2) / sum((dataOutNoisy(noEstimationData:end) - mean(dataOutNoisy(noEstimationData:end))).^2));

%% Save everything to file

save('example1_arx_workspace.mat')
