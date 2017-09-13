model.A = 0.5;
model.Q = 1.0;
model.C = 1;
model.R = 0.1;
model.noObservations = 10000;
model.dimState = 1;
model.dimObservation = 1;

model.initialState = 0;

% Data generation

data.input = zeros([1 model.noObservations]);

data.state = zeros([model.dimState, model.noObservations]);
data.observation = zeros([model.dimObservation, model.noObservations]);
data.noObservations = model.noObservations;
data.dimState = model.dimState;
data.dimObservation = model.dimObservation;
data.state(:, 1) = model.initialState;

data.observation(:, 1) = model.C * data.state(:, 1) + mvnrnd(zeros([1, model.dimObservation]), model.R)';
for t = 2:model.noObservations
    data.state(:, t) = model.A * data.state(:, t-1) + data.input(:, t) + mvnrnd(zeros([1, model.dimState]), model.Q)';
    data.observation(:, t) = model.C * data.state(:, t) + mvnrnd(zeros([1 model.dimObservation]), model.R)';
end

%%
settings.initialState = 0;
settings.initialCovariance = 0.1;

ksOutput = kalmanSmoother(data, model, settings);


figure(1);
grid = 1:model.noObservations;

subplot(3, 2, [1 2]);
plot(grid, data.state(1, :), grid, ksOutput.filteredStateEstimate(1, :), grid, ksOutput.predictedStateEstimate(1, :), grid, ksOutput.smoothedStateEstimate(1, :))

mseFilter = mean((data.state(1, :) - ksOutput.filteredStateEstimate(1, :)).^2);
msePredictor = mean((data.state(1, 1:end-1) - ksOutput.predictedStateEstimate(1, 2:end)).^2);
mseSmoother = mean((data.state(1, :) - ksOutput.smoothedStateEstimate(1, :)).^2);
[mseFilter msePredictor mseSmoother]

%%
grid = 0:0.01:0.99;
scoreA = zeros([1 length(grid)]);
logLikelihoodA = zeros([1 length(grid)]);
theta = model;

for i = 1:length(grid)
    theta.A = grid(i);
    ksOutput = kalmanSmoother(data, theta, settings);
    scoreA(i) = ksOutput.scoreA;
    logLikelihoodA(i) = ksOutput.logLikelihood;
end

subplot(3, 2, 3);
plot(grid, scoreA)
hold on;
    vline(model.A);
    hline(0.0);
hold off;
xlabel('A'); 
ylabel('Score function');

subplot(3, 2, 4);
plot(grid, logLikelihoodA)
hold on;
    vline(model.A);
hold off;
xlabel('A'); 
ylabel('logLikelihood');

%%
grid = 0.1:0.1:3;
scoreQ = zeros([1 length(grid)]);
logLikelihoodQ = zeros([1 length(grid)]);
theta = model;

for i = 1:length(grid)
    theta.Q = grid(i);
    ksOutput = kalmanSmoother(data, theta, settings);
    scoreQ(i) = ksOutput.scoreA;
    logLikelihoodQ(i) = ksOutput.logLikelihood;
end

subplot(3, 2, 5);
plot(grid, scoreQ)
hold on;
    vline(model.Q);
    hline(0.0);
hold off;
xlabel('Q'); 
ylabel('Score function');


subplot(3, 2, 6);
plot(grid, logLikelihoodQ)
hold on;
    vline(model.Q);
hold off;
xlabel('Q'); 
ylabel('logLikelihood');
