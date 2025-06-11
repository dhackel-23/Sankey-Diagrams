function [x, t, u, thick, temp1] = last_temp(tmax, nt, nx, ~, timeData, tempData, tmin, max_iterations)
% LAST_TEMP - Iterative Target Solver
% Primary Application: Options Pricing and Calibration
%
% DESCRIPTION:
% Uses secant method to find parameters that achieve target values for numerical 
% optimization problems. Originally developed for spacecraft heat shield modeling,
% this function has direct applications in algorithmic trading and quantitative
% finance for optimizing computational performance vs accuracy trade-offs.
%
% SYNTAX:
%   [x, t, u, thick, temp1] = last_temp(tmax, nt, nx, ~, timeData, tempData, tmin, max_iterations)
%
% INPUT ARGUMENTS:
%   tmax           - Maximum simulation time (seconds)
%   nt             - Number of timesteps
%   nx             - Number of spatial steps  
%   ~              - Unused parameter (placeholder for compatibility)
%   timeData       - Time vector for boundary conditions (s)
%   tempData       - Temperature/value vector for boundary conditions
%   tmin           - Target temperature value wanted at the end
%   max_iterations - Maximum number of iterations for convergence
%
% OUTPUT ARGUMENTS:
%   x      - Distance vector (m)
%   t      - Time vector (s)
%   u      - Temperature matrix (C or K)
%   thick  - Optimal thickness parameter (m)
%   temp1  - Final temperature achieved at convergence
%
% NUMERICAL METHOD:
%   Secant Method - Iterative root-finding algorithm that uses two previous 
%   points to approximate the derivative, avoiding expensive derivative calculations
%   Formula: x_{n+1} = x_n - f(x_n) * (x_n - x_{n-1}) / (f(x_n) - f(x_{n-1}))
%
% APPLICATIONS:
%   - Options Pricing: Black-Scholes parameter calibration
%   - Risk Management: VaR threshold optimization
%   - Algorithmic Trading: Performance target achievement
%   - Engineering: Thermal protection system design
%
% CONVERGENCE CRITERIA:
%   - Absolute error tolerance: 0.001
%   - Maximum iterations: user-defined
%   - Secant method provides superlinear convergence
%
% EXAMPLE USAGE:
%   % Extract temperature data for boundary conditions
%   [timeData, tempData] = extractTemperatureData('m_l', "kelvin");
%   
%   % Find optimal thickness to achieve target temperature
%   [x, t, u, thickness, last_temperature] = last_temp(4000, 1000, 21, ...
%                                           "tt", timeData, tempData, 450, 50);
%   
%   % Visualize temperature distribution
%   surf(x, t, u);
%   xlabel('Distance (m)'); ylabel('Time (s)'); zlabel('Temperature (K)');
%   
%   % Display results
%   fprintf('Optimal thickness: %.4f m\n', thickness);
%   fprintf('Final temperature: %.2f K\n', last_temperature);
%

    % Initial guess for thickness parameters (secant method requires two points)
    thick(1) = 0.05;  % First guess: 5 cm thickness
    thick(2) = 0.15;  % Second guess: 15 cm thickness
    n = 1;
    
    % Calculate temperature for the first two thicknesses
    [x, t, u] = calctemp_Neuman(tmax, nt, thick(1), nx, 'crank-nicolson', ...
                               timeData, tempData, "no");
    temp(n) = max(u(:,end));        % Maximum temperature at final time
    err(1) = temp(n) - tmin;        % Error from target temperature
    
    [x, t, u] = calctemp_Neuman(tmax, nt, thick(2), nx, 'crank-nicolson', ...
                               timeData, tempData, "no");
    temp(n+1) = max(u(:,end));      % Maximum temperature at final time
    err(n+1) = temp(n+1) - tmin;    % Error from target temperature
    
    count = 0;
    
    % Iterative secant method loop
    % Continue until convergence or maximum iterations reached
    while (abs(err(n+1)) > 0.001 && count < max_iterations)
        count = count + 1;
        
        % Secant method formula for next thickness estimate
        % This avoids expensive derivative calculations by using slope between two previous points
        thick(n+2) = thick(n+1) - err(n+1) * ((thick(n+1) - thick(n)) / (err(n+1) - err(n)));
        
        % Calculate temperature distribution for new thickness estimate
        [x, t, u] = calctemp_Neuman(tmax, nt, thick(n+2), nx, 'crank-nicolson', ...
                                   timeData, tempData, "no");
        
        % Evaluate objective function (temperature error)
        temp(n+2) = max(u(:,end));      % Maximum temperature at final time
        err(n+2) = temp(n+2) - tmin;    % Error from target temperature
        
        % Update iteration counter
        n = n + 1;
        
        % Store final temperature for output
        temp1 = max(u(:,end));
        
        % Optional: Display iteration progress
        % fprintf('Iteration %d: thickness = %.4f m, error = %.4f\n', count, thick(n+1), abs(err(n+1)));
    end
    
    % Return the converged thickness value
    thick = thick(n+1);
    
    % Display convergence results
    if abs(err(n+1)) <= 0.001
        fprintf('Convergence achieved in %d iterations\n', count);
        fprintf('Final thickness: %.4f m\n', thick);
        fprintf('Target temperature: %.2f, Achieved: %.2f\n', tmin, temp1);
        fprintf('Final error: %.6f\n', abs(err(n+1)));
    else
        fprintf('Maximum iterations (%d) reached without convergence\n', max_iterations);
        fprintf('Current error: %.6f (tolerance: 0.001)\n', abs(err(n+1)));
    end
    
end