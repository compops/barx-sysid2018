noObservations = 1000;
systemOrder = 2;

inputEstimation = randn(1000, 1);
inputValidation = randn(500, 1);

[b, a] = cheby1(systemOrder, 5, [0.2 0.6], 'stop');

outputEstimation = filter(b, a, inputEstimation);
outputValidation = filter(b, a, inputValidation);

% Noise free
res1 = arx(iddata(outputEstimation, inputEstimation),[4 5 0]);
prediction1 = predict(res1, iddata(outputValidation, inputValidation));
squaredPE1 = sum((prediction1.OutputData - outputValidation).^2);
squaredObs1 = sum((outputValidation - mean(outputValidation)).^2);
modelFit1 = 100 * (1 - squaredPE1 / squaredObs1)
norm(res1.A - a)
norm(res1.B - b)

% Standard normal noise
res2 = arx(iddata(outputEstimation + randn(1000, 1), inputEstimation),[4 5 0]);
prediction2 = predict(res2, iddata(outputValidation, inputValidation));
squaredPE2 = sum((prediction2.OutputData - outputValidation).^2);
squaredObs2 = sum((outputValidation - mean(outputValidation)).^2);
modelFit2 = 100 * (1 - squaredPE2 / squaredObs2)
norm(res2.A - a)
norm(res2.B - b)

% Student's t noise
res3 = arx(iddata(outputEstimation + trnd(2, 1000, 1), inputEstimation),[4 5 0]);
prediction3 = predict(res3, iddata(outputValidation, inputValidation));
squaredPE3 = sum((prediction3.OutputData - outputValidation).^2);
squaredObs3 = sum((outputValidation - mean(outputValidation)).^2);
modelFit3 = 100 * (1 - squaredPE3 / squaredObs3)
norm(res3.A - a)
norm(res3.B - b)

% Gaussian mixture
obj = gmdistribution([0; 20], cat(3, [0.5], [0.5]), [0.8, 0.2]);
res4 = arx(iddata(outputEstimation + random(obj, 1000), inputEstimation),[4 5 0]);
prediction4 = predict(res4, iddata(outputValidation, inputValidation));
squaredPE4 = sum((prediction4.OutputData - outputValidation).^2);
squaredObs4 = sum((outputValidation - mean(outputValidation)).^2);
modelFit4 = 100 * (1 - squaredPE4 / squaredObs4)
norm(res4.A - a)
norm(res4.B - b)

% Uniform
res5 = arx(iddata(outputEstimation + unifrnd(-4, 4, 1000, 1), inputEstimation),[4 5 0]);
prediction5 = predict(res5, iddata(outputValidation, inputValidation));
squaredPE5 = sum((prediction5.OutputData - outputValidation).^2);
squaredObs5 = sum((outputValidation - mean(outputValidation)).^2);
modelFit5 = 100 * (1 - squaredPE5 / squaredObs5)
norm(res5.A - a)
norm(res5.B - b)