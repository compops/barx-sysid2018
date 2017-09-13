model.A = 0.5;
model.Q = 1.0;
model.C = 1;
model.R = 0.1;
model.noObservations = 1000;
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

plot(grid, data.state(1, :), grid, ksOutput.filteredStateEstimate(1, :), grid, ksOutput.predictedStateEstimate(1, :), grid, ksOutput.smoothedStateEstimate(1, :))
mean((data.state(1, :) - ksOutput.filteredStateEstimate(1, :)).^2)
mean((data.state(1, 1:end-1) - ksOutput.predictedStateEstimate(1, 2:end)).^2)
mean((data.state(1, :) - ksOutput.smoothedStateEstimate(1, :)).^2)

%%
grid = 0:0.01:0.99;
scoreA = zeros([1 length(grid)]);

for i = 1:length(grid)
    model.Q = 1.0;
    model.A = grid(i);
    ksOutput = kalmanSmoother(data, model, settings);
    scoreA(i) = ksOutput.scoreA;
end

plot(grid, scoreA)

%%
grid = 0.1:0.1:3;
scoreQ = zeros([1 length(grid)]);

for i = 1:length(grid)
    model.A = 0.5;
    model.Q = grid(i);
    ksOutput = kalmanSmoother(data, model, settings);
    scoreQ(i) = ksOutput.scoreA;
end

plot(grid, scoreQ)
