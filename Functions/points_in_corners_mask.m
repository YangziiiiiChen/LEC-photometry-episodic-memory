function result = points_in_corners_mask(points, corners)    
    points_x = points(:, 5);
    points_y = points(:, 6);
    poly_x = corners(:, 1);
    poly_y = corners(:, 2);
    result = inpolygon(points_x, points_y, poly_x, poly_y);
end