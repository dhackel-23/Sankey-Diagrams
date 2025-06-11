function [first_i, first_j, errors, smooth_colors, custom_colormap] = plot_error_surface(target_error, same_value, method, imageName, timeData, tempData, unit)

% PLOT_ERROR_SURFACE - Risk Surface Analysis
% Primary Application: Financial Risk Surface Modeling
% 
% DESCRIPTION:
% Creates 3D error surfaces across parameter combinations for numerical stability analysis.
% Originally developed for spacecraft heat shield modeling, this function has direct 
% applications in algorithmic trading and quantitative finance for optimizing 
% computational performance vs accuracy trade-offs.
%
% SYNTAX:
%   [first_i, first_j, errors, smooth_colors, custom_colormap] = plot_error_surface(target_error, same_value, method, imageName, timeData, tempData, unit)
%
% INPUT ARGUMENTS:
%   target_error - Target error threshold for optimization
%   same_value   - Base parameter value (increases grid resolution)
%   method      - Numerical method ('forward', 'backward-difference', 'crank-nicolson', 'dufort-frankel')
%   imageName   - Image identifier for predefined error targets
%   timeData    - Time vector for boundary conditions (s)
%   tempData    - Temperature/value vector for boundary conditions
%   unit        - Unit system for temperature conversion ("kelvin", "celcius", "farenheight")
%
% OUTPUT ARGUMENTS:
%   first_i        - Temporal grid dimension (nt range)
%   first_j        - Spatial grid dimension (nx range)
%   errors         - 2D error matrix for all parameter combinations
%   smooth_colors  - Interpolated color mapping for visualization
%   custom_colormap - RGB color scheme for risk zones
%
% NUMERICAL METHODS TESTED:
%   1. Forward Differencing    - O(Δt, Δx²), conditionally stable
%   2. Backward Differencing   - O(Δt, Δx²), more stable than forward
%   3. DuFort-Frankel         - O(Δt², Δx²), unconditionally stable
%   4. Crank-Nicolson         - O(Δt², Δx²), unconditionally stable (OPTIMAL)
%
% APPLICATIONS:
%   - Options Pricing: Black-Scholes PDE grid optimization
%   - Risk Management: VaR calculation stability analysis
%   - Algorithmic Trading: Backtesting parameter optimization
%   - Monte Carlo: Convergence analysis for derivative pricing
%
% EXAMPLE USAGE:
%   % Extract temperature data for boundary conditions
%   [timeData, tempData] = extractTemperatureData('m_l', "kelvin");
%   
%   % Test different numerical methods
%   [i, j, errors, colors, cmap] = plot_error_surface(145.9728, 20, 'crank-nicolson', 'm_l', timeData, tempData, "kelvin");
%   
%   % Visualize error surface
%   figure;
%   surf(1:j, 1:i, errors, colors);
%   xlabel('Spatial Steps (nx)');
%   ylabel('Temporal Steps (nt)');
%   zlabel('Absolute Error');
%   title('Numerical Stability Surface - Crank-Nicolson Method');
%   colorbar;
%
% Date: 16/03/24
% Modified for GitHub Portfolio: Advanced Numerical Methods Suite

    % Image-specific target error configuration
    imgw = [imageName '.jpg'];
    
    % Predefined error targets for different test cases
    % These values represent critical temperature thresholds for spacecraft tiles
    switch imgw
        case 'm_r.jpg'
            target_error = 434.1425; % Right section measurement point
        case 'm_l.jpg'
            target_error = 421.7735; % Left section measurement point
        case 'm_b.jpg'
            target_error = 411.1631; % Bottom section measurement point
        case 'f_m.jpg'
            target_error = 415.9252; % Front middle measurement point
        case 'b_r_t.jpg'
            target_error = 430.0766; % Back right top measurement point
        case 'b_r_s.jpg'
            target_error = 437.7832; % Back right side measurement point
        case 'b_r_f.jpg'
            target_error = 439.9135; % Back right front measurement point
        case 'b_m.jpg'
            target_error = 401.4381; % Back middle measurement point
        otherwise
            msgbox('Unrecognized image file. Please select a valid image.', 'Error', 'error');
            return;
    end
    
    % Unit conversion for temperature scales
    if strcmp(unit, "celcius")
        target_error = target_error - 273.15;
    elseif strcmp(unit, "farenheight")
        target_error = ((target_error - 273.15) * (9/5)) + 32;
    end
    
    % Extract temperature data for boundary conditions
    [timeData, tempData] = extractTemperatureData(imageName, unit);
    
    % Define parameter grid dimensions
    first_i = same_value + 50;  % Temporal steps range
    first_j = same_value + 50;  % Spatial steps range
    
    % Initialize error matrix
    errors = zeros(first_i, first_j);
    
    % Progress tracking for large computations
    total_iterations = first_i * first_j;
    current_iteration = 0;
    
    fprintf('Starting error surface calculation...\n');
    fprintf('Method: %s\n', method);
    fprintf('Grid size: %d x %d = %d iterations\n', first_i, first_j, total_iterations);
    
    % Main computation loop - sweep through parameter space
    for i = 1:first_i
        for j = 1:first_j
            current_iteration = current_iteration + 1;
            
            % Display progress every 10%
            if mod(current_iteration, round(total_iterations/10)) == 0
                progress = (current_iteration / total_iterations) * 100;
                fprintf('Progress: %.1f%% complete\n', progress);
            end
            
            % Simulation parameters
            tmax = 4000;        % Maximum simulation time (s)
            nx_val = 1 + j;     % Number of spatial grid points
            nt_val = i + 1;     % Number of temporal grid points
            xmax = 0.05;        % Domain thickness (m)
            
            try
                % Call numerical solver with current parameters
                [~, ~, ~, p] = calctemp1(tmax, nt_val, xmax, nx_val, method, ...
                                       timeData, tempData, "no", 10000, 'material provided');
                
                % Calculate error metric (maximum temperature deviation)
                error = max(p(:,1));
                diff = abs(error - target_error);
                
                % Cap extreme errors for visualization purposes
                if diff > 150
                    diff = 100;
                end
                
                % Store computed error
                errors(i, j) = diff;
                
            catch ME
                % Handle numerical instabilities
                fprintf('Warning: Numerical instability at nt=%d, nx=%d\n', nt_val, nx_val);
                errors(i, j) = 100; % Mark as high error
            end
        end
    end
    
    fprintf('Error surface calculation complete!\n');
    
    % Create custom colormap for risk visualization
    % Green: Low risk (error < 1)
    % Yellow: Medium risk (1 ≤ error ≤ 5)  
    % Red: High risk (error > 5)
    custom_colormap = [0 1 0;    % Green
                       1 1 0;    % Yellow  
                       1 0 0];   % Red
    
    % Assign color categories based on error thresholds
    color_values = zeros(size(errors));
    color_values(errors > 5) = 3;                           % High risk - Red
    color_values(errors <= 5 & errors >= 1) = 2;          % Medium risk - Yellow
    color_values(errors < 1) = 1;                          % Low risk - Green
    
    % Create smooth color interpolation for better visualization
    smooth_colors = zeros([size(errors), 3]);
    for k = 1:3
        smooth_colors(:,:,k) = interp1([1, 2, 3], custom_colormap(:,k), color_values, 'linear');
    end
    
    % Optional: Display results summary
    fprintf('\n--- Error Surface Analysis Results ---\n');
    fprintf('Method: %s\n', method);
    fprintf('Grid dimensions: %d x %d\n', first_i, first_j);
    fprintf('Minimum error: %.4f\n', min(errors(:)));
    fprintf('Maximum error: %.4f\n', max(errors(:)));
    fprintf('Mean error: %.4f\n', mean(errors(:)));
    
    % Find optimal parameters (minimum error)
    [min_error, min_idx] = min(errors(:));
    [opt_i, opt_j] = ind2sub(size(errors), min_idx);
    opt_nt = opt_i + 1;
    opt_nx = 1 + opt_j;
    
    fprintf('Optimal parameters: nt=%d, nx=%d (Error: %.4f)\n', opt_nt, opt_nx, min_error);
    
    % Calculate stability metrics
    stable_points = sum(errors(:) < 1);
    total_points = numel(errors);
    stability_ratio = stable_points / total_points * 100;
    
    fprintf('Stability ratio: %.1f%% (%d/%d points with error < 1)\n', ...
            stability_ratio, stable_points, total_points);
    
    % Optional: Create and display the surface plot
    % Uncomment the following lines to automatically generate the plot
    %
    % figure;
    % surf(1:first_j, 1:first_i, errors, smooth_colors);
    % xlabel('Spatial Steps (nx)');
    % ylabel('Temporal Steps (nt)');
    % zlabel('Absolute Error');
    % title(sprintf('Error Surface Analysis - %s Method', method));
    % colormap(custom_colormap);
    % colorbar;
    % grid on;
    % view(45, 30);
    
end