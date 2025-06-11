function [bestMethod, maxdt] = timestepInv(tmax, ntMin, ntMax, ntIncr, thick, nx, tol, timeData, tempData)

% TIMESTEPINV - Optimal timestep finder for numerical methods
%
% DESCRIPTION:
% Finds the largest stable timestep for various numerical methods within a
% specified tolerance. Originally developed for spacecraft heat shield modeling,
% this function has direct applications in algorithmic trading and quantitative
% finance for optimizing computational performance vs accuracy trade-offs.
%
% SYNTAX:
%   [bestMethod, maxdt] = timestepInv(tmax, ntMin, ntMax, ntIncr, thick, nx, tol, timeData, tempData)
%
% INPUT ARGUMENTS:
%   tmax     - Maximum simulation time (seconds)
%   ntMin    - Minimum number of timesteps to test
%   ntMax    - Maximum number of timesteps to test  
%   ntIncr   - Increment between timestep tests
%   thick    - Total thickness of domain (meters)
%   nx       - Number of spatial grid points
%   tol      - Tolerance for acceptable error (±tol)
%   timeData - Time vector for boundary conditions
%   tempData - Temperature/value vector for boundary conditions
%
% OUTPUT ARGUMENTS:
%   bestMethod - String indicating most stable method ('crank-nicolson', etc.)
%   maxdt      - Maximum stable timestep (seconds)
%
% NUMERICAL METHODS TESTED:
%   1. Forward Differencing      - O(dt, dx²), conditionally stable
%   2. Backward Differencing     - O(dt, dx²), more stable than forward
%   3. DuFort-Frankel           - O(dt², dx²), unconditionally stable
%   4. Crank-Nicolson           - O(dt², dx²), unconditionally stable (optimal)
% Initialize arrays

i = 0;
methods = {'forward', 'backward-difference', 'dufort-frankel','crank-nicolson'};
z = zeros(length(methods), length(ntMin:ntIncr:ntMax));

% Test each timestep and method combination
for nt = ntMin : ntIncr : ntMax
    i = i + 1;
    dt(i) = tmax / (nt - 1);
    
    % Uncomment for debugging:
    % disp(['Testing nt = ' num2str(nt) ', dt = ' num2str(dt(i)) ' s']);
    
    for j = 1:length(methods)
        % Calculate temperature using specified method
        % Note: This calls the main heat equation solver
        [~, ~, u] = calctemp_Neuman(tmax, nt, thick, nx, methods{j}, timeData, tempData, "No");
        
        % Store final temperature at specific location (spatial point 25)
        z(j, i) = u(end, 25);
    end
end

% Calculate convergence reference (average of all methods at finest timestep)
avgConvergence = mean(z(:, end));

% Create stability plot
plot(dt, z, 'LineWidth', 2);
hold on
yline(avgConvergence + tol, 'k--', 'LineWidth', 1.5, 'DisplayName', '+tolerance');
yline(avgConvergence - tol, 'k--', 'LineWidth', 1.5, 'DisplayName', '-tolerance');
hold off

% Format plot
ylim([avgConvergence - 3 * tol, avgConvergence + 3 * tol]);
xlim([0, max(dt)]);
xlabel('Timestep, dt (s)', 'FontSize', 12);
ylabel('Solution Value at Final Time', 'FontSize', 12);
title('Numerical Method Stability Analysis', 'FontSize', 14);
legend('Forward', 'Backward', 'Dufort-Frankel', 'Crank-Nicolson', 'Tolerance Bounds', ...
       'Location', 'best', 'FontSize', 10);
grid on

% Find the method with largest stable timestep
maxdt = 0;
bestMethod = '';

for i = 1:length(methods)
    % Find last point outside upper tolerance bound
    lastIdxPos = find(z(i, :) > avgConvergence + tol, 1, 'last');
    if ~isempty(lastIdxPos)
        intersectPos = dt(min(lastIdxPos + 1, length(dt)));
    else
        intersectPos = inf;  % Never exceeded upper bound
    end
    
    % Find last point outside lower tolerance bound  
    lastIdxNeg = find(z(i, :) < avgConvergence - tol, 1, 'last');
    if ~isempty(lastIdxNeg)
        intersectNeg = dt(min(lastIdxNeg + 1, length(dt)));
    else
        intersectNeg = inf;  % Never exceeded lower bound
    end
    
    % Take the more conservative (smaller) of the two bounds
    methodMaxDt = min(intersectPos, intersectNeg);
    
    % Update overall maximum if this method is better
    if methodMaxDt > maxdt
        maxdt = methodMaxDt;
        bestMethod = methods{i};
    end
end

% Display results
fprintf('\n=== TIMESTEP OPTIMIZATION RESULTS ===\n');
fprintf('Best Method: %s\n', bestMethod);
fprintf('Maximum Stable Timestep: %.2f seconds\n', maxdt);
fprintf('Tolerance: ±%.4f\n', tol);
fprintf('Convergence Reference: %.4f\n', avgConvergence);

% Handle case where no method is stable
if maxdt == 0
    warning('No method found stable within tolerance. Consider reducing tolerance or timestep range.');
    bestMethod = 'crank-nicolson';  % Default to most robust method
    maxdt = dt(1);  % Return smallest timestep tested
end

end