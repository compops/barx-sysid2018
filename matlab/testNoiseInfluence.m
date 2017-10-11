inputEstimation = randn(1000, 1);
inputValidation = randn(500, 1);
roots = unifrnd(-1, 1, 5, 1);
coefs = poly(roots);
outputEstimation = filter(coefs, 1, inputEstimation);
outputValidation = filter(coefs, 1, inputValidation);

% Noise free
res1 = oe(iddata(outputEstimation, inputEstimation), [6 0 0]);
prediction1 = predict(res1, iddata(outputValidation, inputValidation));
squaredPE1 = sum((prediction1.OutputData - outputValidation).^2);
squaredObs1 = sum((outputValidation - mean(outputValidation)).^2);
modelFit1 = 100 * (1 - squaredPE1 / squaredObs1)
norm(res1.B - coefs)

% Standard normal noise
res2 = oe(iddata(outputEstimation + randn(1000, 1), inputEstimation), [6 0 0]);
prediction2 = predict(res2, iddata(outputValidation, inputValidation));
squaredPE2 = sum((prediction2.OutputData - outputValidation).^2);
squaredObs2 = sum((outputValidation - mean(outputValidation)).^2);
modelFit2 = 100 * (1 - squaredPE2 / squaredObs2)
norm(res2.B - coefs)

% Student's t noise
res3 = oe(iddata(outputEstimation + trnd(5, 1000, 1), inputEstimation), [6 0 0]);
prediction3 = predict(res3, iddata(outputValidation, inputValidation));
squaredPE3 = sum((prediction3.OutputData - outputValidation).^2);
squaredObs3 = sum((outputValidation - mean(outputValidation)).^2);
modelFit3 = 100 * (1 - squaredPE3 / squaredObs3)
norm(res3.B - coefs)

% Gaussian mixture
obj = gmdistribution([-3; 0; 4], cat(3, [1], [3], [1]), [0.4, 0.2, 0.4]);
res4 = oe(iddata(outputEstimation + random(obj, 1000), inputEstimation), [6 0 0]);
prediction4 = predict(res4, iddata(outputValidation, inputValidation));
squaredPE4 = sum((prediction4.OutputData - outputValidation).^2);
squaredObs4 = sum((outputValidation - mean(outputValidation)).^2);
modelFit4 = 100 * (1 - squaredPE4 / squaredObs4)
norm(res4.B - coefs)

% Uniform
res5 = oe(iddata(outputEstimation + unifrnd(-4, 4, 1000, 1), inputEstimation), [6 0 0]);
prediction5 = predict(res5, iddata(outputValidation, inputValidation));
squaredPE5 = sum((prediction5.OutputData - outputValidation).^2);
squaredObs5 = sum((outputValidation - mean(outputValidation)).^2);
modelFit5 = 100 * (1 - squaredPE5 / squaredObs5)
norm(res5.B - coefs)