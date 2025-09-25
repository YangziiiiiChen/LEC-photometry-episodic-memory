function mapped_points = map_points_to_quad(P1, P2, points_in_polygon)
    mapped_points = zeros(size(points_in_polygon));
    P2_center = [(P2(1, 1) + P2(2, 1)) / 2, (P2(1, 2) + P2(3, 2)) / 2];
    
    for i = 1:size(points_in_polygon, 1)
        point = points_in_polygon(i, :);
        
        if inpolygon(point(1), point(2), P1(:, 1), P1(:, 2))
            v0 = P1(1, :);
            v1 = P1(2, :);
            v2 = P1(3, :);
            v3 = P1(4, :);
            
            A = polyarea(P1(:, 1), P1(:, 2));
            A1 = polyarea([point(1), v1(1), v0(1)], [point(2), v1(2), v0(2)]);
            A2 = polyarea([point(1), v2(1), v1(1)], [point(2), v2(2), v1(2)]);
            A3 = polyarea([point(1), v3(1), v2(1)], [point(2), v3(2), v2(2)]);
            A4 = polyarea([point(1), v0(1), v3(1)], [point(2), v0(2), v3(2)]);
            
            alpha = A1 / A;
            beta = A2 / A;
            gamma = A3 / A;
            delta = A4 / A;
            
            mapped_points(i, 1) = alpha * P2(1, 1) + beta * P2(2, 1) + gamma * P2(3, 1) + delta * P2(4, 1);
            mapped_points(i, 2) = alpha * P2(1, 2) + beta * P2(2, 2) + gamma * P2(3, 2) + delta * P2(4, 2);
            
            mapped_points(i, 1) = P2_center(1) + P2_center(1) - mapped_points(i, 1);
            mapped_points(i, 2) = P2_center(2) + P2_center(2) - mapped_points(i, 2);
        else
            mapped_points(i, :) = NaN; 
        end
    end
end
