clear all;

%% Settings
% Define system
%A = [0.8 0.1; 0 0.9];
%C = [1 0];
%Q = [1 0; 0 1];
%R = 0.1^2;

% T = 0.01;
% A = [1 T T^2/2; 0 1 T; 0 0 1];
% Q = [T^3/6 T^2/2 T];
% Q = 0.01 * Q' * Q;
% C = [1 0 0];
% R = 0.01^2;

A = [1 0.1; 0 0.2];
Q = 2 * eye(2);
C = [1 0];
R = 10;

noObservations = 1000;
initialState = [0 0];
initialCovariance = 1;

input = zeros([2 noObservations]);
tt = 1:noObservations;
input(1, :) = sin(4 * pi * tt /  noObservations);

dimState = 2;
dimObservation = 1;

%% Data generation
% Simulate the system
state = zeros([dimState, noObservations]);
observation = zeros([dimObservation, noObservations]);

state(:, 1) = initialState;
observation(:, 1) = C * state(:, 1) + mvnrnd(zeros([1, dimObservation]), R)';
for t = 2:noObservations
    state(:, t) = A * state(:, t-1) + input(:, t) + mvnrnd(zeros([1, dimState]), Q)';
    observation(:, t) = C * state(:, t)   + mvnrnd(zeros([1 dimObservation]), R)';
end

%% Square-root Kalman filter

% Initial QR factorization
dimLLt = dimState + dimObservation;
LLt = zeros([dimLLt dimLLt]);
LLt(1:dimState,1:dimState) = Q;
LLt(dimState+1:dimLLt, dimState+1:dimLLt) = R;

% Pre-allocate matrices
predictedStateEstimate = zeros([dimState, noObservations]);
filteredStateEstimate = zeros([dimState, noObservations]);
predictedStateCovariance = zeros([dimState, dimState, noObservations]);
filteredStateCovariance = zeros([dimState, dimState, noObservations]);

% Set initial state and covariance
filteredStateEstimate(:, 1) = initialState;
filteredStateCovariance(:, :, 1) = eye(dimState) * initialCovariance;

for t = 2:noObservations
    %-----------------------------------------------------------------
    % Prediction
    %-----------------------------------------------------------------
    
    % Compute QR-factorization of [Pf'A'; Q'] to get Pp
    QR1 = zeros([2*dimState dimState]);
    QR1(1:dimState, 1:dimState) = filteredStateCovariance(:, :, t-1)' * A';
    QR1(dimState+1:2*dimState, 1:dimState) = Q';
    [Q1, R1] = qr(QR1);

    % Propagate state using model
    predictedStateEstimate(:, t) = A * filteredStateEstimate(:, t-1) + input(:, t);

    % Compute the prediction covariance (R11'* R11) but save the
    % transposed square-root
    predictedStateCovariance(:, :, t) = R1(1:dimState, 1:dimState);

    %-----------------------------------------------------------------
    % Correction
    %-----------------------------------------------------------------

    % Compute the innovation and its covariance
    innovation = observation(:, t) - C * predictedStateEstimate(:, t);

    % Compute QR-factorization of [R' 0; Pp'C' Pp'] to get K and Pf
    dimQR2 = dimState+dimObservation;
    QR2 = zeros([dimQR2 dimQR2]);
    QR2(1:dimObservation, 1:dimObservation) = R';
    QR2(dimObservation+1:dimQR2, 1:dimObservation) = predictedStateCovariance(:, :, t) * C';
    QR2(dimObservation+1:dimQR2, dimObservation+1:dimQR2) = predictedStateCovariance(:, :, t);
    [Q2, R2] = qr(QR2);
    
    % Compute Kalman gain (R12'/R11')
    kalmanGain = R2(1:dimObservation, dimObservation+1:dimQR2)' / R2(1:dimObservation, 1:dimObservation)';
    
    % Correct the state estimate
    filteredStateEstimate(:, t) = predictedStateEstimate(:, t) + kalmanGain * innovation;
    
    % Compute the filtering covariance (R22' * R22) but save the transposed
    % square-root
    filteredStateCovariance(:, :, t) = R2(dimObservation+1:dimQR2, dimObservation+1:dimQR2);
end

%% Plotting
figure(1);
subplot(2, 1, 1);
plot(observation); 
xlabel("time");
ylabel("observations");

subplot(2, 1, 2);
plot(1:noObservations, state, 1:noObservations, filteredStateEstimate);
xlabel("time");
ylabel("state");


