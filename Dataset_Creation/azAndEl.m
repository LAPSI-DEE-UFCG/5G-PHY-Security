function [azimuth1, elevation1, azimuth2, elevation2] = azAndEl(point1, point2, plotGraph)
    % Plot the two points in 3D space
    
    if plotGraph
        figure;
        scatter3(point1(1), point1(2), point1(3), 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');
        hold on;
        scatter3(point2(1), point2(2), point2(3), 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
    end

    vector1 = point2 - point1;
    vector2 = point1 - point2;

    % Calculate azimuth and elevation angles for both points
    [azimuth1, elevation1, ~] = cart2sph(vector1(1), vector1(2), vector1(3));
    [azimuth2, elevation2, ~] = cart2sph(vector2(1), vector2(2), vector2(3));

    % Convert angles from radians to degrees
    azimuth1 = rad2deg(azimuth1);
    elevation1 = rad2deg(elevation1);
    azimuth2 = rad2deg(azimuth2);
    elevation2 = rad2deg(elevation2);
    
    if plotGraph
        % Display azimuth and elevation angles as text on the graph
        text(point1(1), point1(2), point1(3), sprintf('Azimuth: %.2f°\nElevation: %.2f°', azimuth1, elevation1), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'BackgroundColor', [1 1 1]);
        text(point2(1), point2(2), point2(3), sprintf('Azimuth: %.2f°\nElevation: %.2f°', azimuth2, elevation2), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'BackgroundColor', [1 1 1]);
    
        % Draw arrows using quiver
        quiver3(point1(1), point1(2), point1(3), vector1(1)/3, vector1(2)/3, vector1(3)/3, 'MaxHeadSize', 0.2);
        quiver3(point2(1), point2(2), point2(3), vector2(1)/3, vector2(2)/3, vector2(3)/3, 'MaxHeadSize', 0.2);
    
        % Set axis labels
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
    
        % Set axis limits
        axis equal;
        grid on;
    
        % Adjust the view for better visualization
        view(-45, 30);
        hold off;
    end

end
