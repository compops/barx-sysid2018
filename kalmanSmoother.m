 function output = kalmanSmoother(data, model, settings)
    
    A = model.A;
    Q = chol(model.Q);
    C = model.C;
    R = chol(model.R);

    inputSignal = data.input;
    observation = data.observation;
    noObservations = data.noObservations;
    dimObservation = data.dimObservation;
    dimState = data.dimState;

    predictedStateEstimate = zeros([dimState, noObservations]);
    filteredStateEstimate = zeros([dimState, noObservations]);
    predictedStateCovariance = zeros([dimState, dimState, noObservations]);
    filteredStateCovariance = zeros([dimState, dimState, noObservations]);
    kalmanGain = zeros([dimState, noObservations]);

    % Kalman filter
    filteredStateEstimate(:, 1) = settings.initialState;
    filteredStateCovariance(:, :, 1) = chol(settings.initialCovariance);

    for t = 2:noObservations    
        % Compute QR-factorization of [Pf'A'; Q'] to get Pp
        QR1 = zeros([2*dimState dimState]);
        QR1(1:dimState, 1:dimState) = filteredStateCovariance(:, :, t-1)' * A';
        QR1(dimState+1:2*dimState, 1:dimState) = Q';
        [Q1, R1] = qr(QR1);

        predictedStateEstimate(:, t) = A * filteredStateEstimate(:, t-1) + inputSignal(:, t);
        predictedStateCovariance(:, :, t) = R1(1:dimState, 1:dimState);

        innovation = observation(:, t) - C * predictedStateEstimate(:, t);

        % Compute QR-factorization of [R' 0; Pp'C' Pp'] to get K and Pf
        dimQR2 = dimState + dimObservation;
        QR2 = zeros([dimQR2 dimQR2]);
        QR2(1:dimObservation, 1:dimObservation) = R';
        QR2(dimObservation+1:dimQR2, 1:dimObservation) = predictedStateCovariance(:, :, t) * C';
        QR2(dimObservation+1:dimQR2, dimObservation+1:dimQR2) = predictedStateCovariance(:, :, t);
        [Q2, R2] = qr(QR2);
        
        kalmanGain(:, t) = R2(1:dimObservation, dimObservation+1:dimQR2)' / R2(1:dimObservation, 1:dimObservation)';
        filteredStateEstimate(:, t) = predictedStateEstimate(:, t) + kalmanGain(:, t) * innovation;
        filteredStateCovariance(:, :, t) = R2(dimObservation+1:dimQR2, dimObservation+1:dimQR2);
    end

    % RTS smoother
    smoothedStateEstimate = zeros([dimState, noObservations]);
    smoothedStateCovariance = zeros([dimState, dimState, noObservations]);
    gainFactor = zeros([dimState, dimState, noObservations]);
    smoothedStateCovarianceTwoStep = zeros([dimState, dimState, noObservations]);

    % Set last smoothing covariance and state estimate to the filter solutions
    smoothedStateEstimate(:, noObservations) = filteredStateEstimate(:, noObservations);
    %smoothedStateCovariance(:, :, noObservations) = filteredStateCovariance(:, :, noObservations)' * filteredStateCovariance(:, :, noObservations);
    smoothedStateCovariance(:, :, noObservations) = filteredStateCovariance(:, :, noObservations);

    for t = noObservations-1:-1:1
        
        gainFactor(:, :, t) = filteredStateCovariance(:, :, t)' * filteredStateCovariance(:, :, t) * A' / (predictedStateCovariance(:, :, t+1)' * predictedStateCovariance(:, :, t+1));
        smoothedStateEstimate(:, t) = filteredStateEstimate(:, t) + gainFactor(:, :, t) * (smoothedStateEstimate(:, t+1) - predictedStateEstimate(: ,t+1));
        
        QR3 = zeros([3*dimState 2*dimState]);
        QR3(1:dimState, 1:dimState) = filteredStateCovariance(:, :, noObservations) * A';
        QR3(1:dimState, dimState+1:end) = filteredStateCovariance(:, :, noObservations);
        QR3(dimState+1:2*dimState, 1:dimState) = Q';
        QR3(2*dimState+1:end, dimState+1:end) = smoothedStateCovariance(:, :, t+1) * gainFactor(:, :, t)';
        [Q3, R3] = qr(QR3);
        
        smoothedStateCovariance(:, :, t) = R3(dimState+1:2*dimState, dimState+1:2*dimState);
    end

    % Calculate the M-matrix (Smoothing covariance between states at t and t+1)
    smoothedStateCovarianceTwoStep(: , :, noObservations) = (eye(dimState) - kalmanGain(:, noObservations) * C) * A * smoothedStateCovariance(:, :, noObservations)' * smoothedStateCovariance(:, :, noObservations);
    for t = noObservations-1:-1:1
        Pf = filteredStateCovariance(:, :, t)' * filteredStateCovariance(:, :, t);
        smoothedStateCovarianceTwoStep(: , :, t) = Pf * gainFactor(:, :, t)' + gainFactor(:, :, t) * (smoothedStateCovarianceTwoStep(: , :, t+1) - A * Pf) * gainFactor(:, :, t)';
    end
    
    output.filteredStateEstimate = filteredStateEstimate;
    output.predictedStateEstimate = predictedStateEstimate;
    output.smoothedStateEstimate = smoothedStateEstimate;
    output.filteredStateCovariance = filteredStateCovariance;
    output.predictedStateCovariance = predictedStateCovariance;
    output.smoothedStateEstimate = smoothedStateEstimate;
end



        
