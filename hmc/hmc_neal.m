noIterations = 1000; 

accept = zeros([noIterations 1]);
theta = zeros([noIterations 100]);
theta(1, :) = zeros([1 100]);

for iter = 2:noIterations
    [theta(iter, :), accept(iter)] = hamiltonianMonteCarlo(theta(iter-1, :), unifrnd(0.0104, 0.0156), 150);
end

figure(1);
subplot(2, 2, 1); plot(theta(:,1)); ylabel('x1'); xlabel('iteration');
subplot(2, 2, 2); plot(theta(:,50)); ylabel('x1'); xlabel('iteration');
subplot(2, 2, 3); plot(theta(:,75)); ylabel('x1'); xlabel('iteration');
subplot(2, 2, 4); plot(theta(:,100)); ylabel('x1'); xlabel('iteration');

function [newTheta, accepted] = hamiltonianMonteCarlo(currentTheta, stepLength, noSteps)

    theta = currentTheta;
    momentum = normrnd(0, 1, 1 , length(theta));
    currentMomentum = momentum;

    % Make half step for momentum
    momentum = momentum - stepLength * gradientPotentialFunction(theta) / 2;

    % Alternate full steps for momentumosition and momentum
    for step = 1:noSteps
        % Full step for momentumosition
        theta = theta + stepLength * momentum;

        % Full step for momemtum (if nof at the end)
        if step ~= noSteps
            momentum = momentum - stepLength * gradientPotentialFunction(theta);
        end
    end

    % Make half step for momentum et the end
    momentum = momentum - stepLength * gradientPotentialFunction(theta) / 2;   

    % Negate momentum to make momentumromomentumosal symmetric
    momentum = -momentum;

    % Evaluate momentumotential and kinetic energy at start and end of trajectory
    current_U = potentialFunction(currentTheta);
    current_K = sum(currentMomentum.^2) / 2;
    proposed_U = potentialFunction(theta);
    proposed_K = sum(momentum.^2) / 2;

    % Accemomentumt or reject step
    acceptanceProbability = exp(current_U - proposed_U + current_K - proposed_K);
    uniformRandomVariable = unifrnd(0, 1);

    if (uniformRandomVariable < acceptanceProbability)
        newTheta = theta;
        accepted = 1.0;
    else
        newTheta = currentTheta;
        accepted = 0.0;
    end
end

function output = potentialFunction(theta)
    noDimensions = 100;
    variances = (1.0 ./ (1:noDimensions)).^2;
    covarianceMatrix = diag(variances);    
    output = 0.5 * theta / covarianceMatrix * theta';
end

function output = gradientPotentialFunction(theta)
    noDimensions = 100;
    variances = (1.0 ./ (1:noDimensions)).^2;
    covarianceMatrix = diag(variances);
    output = theta / covarianceMatrix;
end