function mapped_points = map_points_to_rectangle(P1, P2, points_in_P1)

    center_P1 = mean(P1);
    center_P2 = mean(P2);
    
    width_P1 = norm(P1(2, :) - P1(1, :));
    height_P1 = norm(P1(4, :) - P1(1, :));
    
    width_P2 = norm(P2(2, :) - P2(1, :));
    height_P2 = norm(P2(4, :) - P2(1, :));
    
    mapped_points = zeros(size(points_in_P1));
    
    for i = 1:size(points_in_P1, 1)
        offset = points_in_P1(i, :) - center_P1;
        
        mapped_offset = offset .* [width_P2 / width_P1, height_P2 / height_P1];
        
        mapped_points(i, :) = center_P2 + mapped_offset;
    end
end
