function mask = points_in_polygon_mask(points, polygon_coords)
    poly_x = polygon_coords(:, 1);
    poly_y = polygon_coords(:, 2);
    points_x = points(:, 1);
    points_y = points(:, 2);
    mask = inpolygon(points_x, points_y, poly_x, poly_y);
end