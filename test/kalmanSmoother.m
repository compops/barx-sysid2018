model.A = [1 0.1; 0 0.2];
model.Q = 2 * eye(2);
model.C = [1 0];
model.R = 1;
model.noObservations = 1000;
model.dimState = 2;
model.dimObservation = 1;

model.initialState = [0 0];

%% Data generation

data.input = zeros([2 model.noObservations]);
tt = 1:model.noObservations;
data.input(1, :) = sin(4 * pi * tt / model.noObservations);

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
settings.initialState = [0 0];
settings.initialCovariance = eye([1 1]);

ksOutput = kalmanSmoother(data, model, settings);

figure(1);
grid = 1:model.noObservations;

subplot(2, 1, 1);
plot(grid, data.state(1, :), grid, ksOutput.filteredStateEstimate(1, :), grid, ksOutput.predictedStateEstimate(1, :), grid, ksOutput.smoothedStateEstimate(1, :))

subplot(2, 1, 2);
plot(grid, data.state(2, :), grid, ksOutput.filteredStateEstimate(2, :), grid, ksOutput.predictedStateEstimate(2, :), grid, ksOutput.smoothedStateEstimate(2, :))


mean((data.state(1, :) - ksOutput.filteredStateEstimate(1, :)).^2)
mean((data.state(1, 1:end-1) - ksOutput.predictedStateEstimate(1, 2:end)).^2)
mean((data.state(1, :) - ksOutput.smoothedStateEstimate(1, :)).^2)