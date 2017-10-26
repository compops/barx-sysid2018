load('../data/eeg.mat')
maxOrder = 10;

%% Downsample and partition data
y = y(1:4:end);
y = (y - mean(y)) / sqrt(var((y)));

trainingData = y(1:1200);
evaluationData = y(1201:2000);
testData = y(2001:end);

%% Standard Least squares with exhaustive search

for order = 1:maxOrder 
    arModel = ar(iddata(double(trainingData)'), order, 'ls');
    predictedSignal = predict(arModel, iddata(double(evaluationData)'), 1);
    rmse(order) = sqrt(mean((predictedSignal.OutputData(order:end)' - evaluationData(order:end)).^2));
end

selectedModelOrder = find(min(rmse) == rmse);
trainingData = [trainingData evaluationData];

arModel = ar(iddata(double(trainingData)'), selectedModelOrder, 'ls');
predictedSignal = predict(arModel, iddata(double(testData)'), 1);

finalRMSEls = sqrt(mean((predictedSignal.OutputData(order:end)' - testData(order:end)).^2));
finalMFls = 1 - sum((predictedSignal.OutputData(order:end)' - testData(order:end)).^2) / sum((testData(order:end) - mean(testData(order:end))).^2);

%% Regularised Least Squares
regressorMatrix = buildY(trainingData, maxOrder);
regressorMatrix = regressorMatrix(2:end, 1:maxOrder);
regressorMatrix = regressorMatrix(maxOrder:end, 1:maxOrder);

% L1-penalised regression
lambdaGrid = 0:1e-2:100;
%l1Coefficients = ridge(trainingData(1+maxOrder:end)', regressorMatrix, lambdaGrid);
l1Coefficients = ridge(trainingData(1+maxOrder:end)', regressorMatrix, 60);

% L2-penalised regression
[l2Coefficients, FitInfo] = lasso(regressorMatrix, trainingData(1+maxOrder:end), 'CV', 10);
%lassoPlot(B,FitInfo,'PlotType','CV');
l2Coefficients = l2Coefficients(:, FitInfo.Index1SE);

regressorMatrixTest = buildY(testData, maxOrder);
regressorMatrixTest = regressorMatrixTest(2:end, 1:maxOrder);
regressorMatrixTest = regressorMatrixTest(maxOrder:end, 1:maxOrder);

predictedSignalL1 = regressorMatrixTest * l1Coefficients;
predictedSignalL2 = regressorMatrixTest * l2Coefficients;

finalRMSEl1 = sqrt(mean((predictedSignalL1' - testData(order+1:end)).^2));
finalMFl1 = 1 - sum((predictedSignalL1' - testData(order+1:end)).^2) / sum((testData(order+1:end) - mean(testData(order+1:end))).^2);
finalRMSEl2 = sqrt(mean((predictedSignalL2' - testData(order+1:end)).^2));
finalMFl2 = 1 - sum((predictedSignalL2' - testData(order+1:end)).^2) / sum((testData(order+1:end) - mean(testData(order+1:end))).^2);

%% Compile results
[finalMFls finalMFl1 finalMFl2]
[finalRMSEls finalRMSEl1 finalRMSEl2]
