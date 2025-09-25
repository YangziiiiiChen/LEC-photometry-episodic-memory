function mapped_points = map_parallelogram_to_rectangle(P1, P2, points_in_P1)
% MAP_PARALLELOGRAM_TO_RECTANGLE
% Maps points from parallelogram P1 to rectangle P2 using affine transform.
% 
% INPUTS:
%   P1 - 4x2 matrix of corner points of the parallelogram (in order)
%   P2 - 4x2 matrix of corner points of the rectangle (in same order)
%   points_in_P1 - Nx2 matrix of points inside P1
%
% OUTPUT:
%   mapped_points - Nx2 matrix of mapped points inside P2

    % Create matrices A and B for affine transform: A * x + t = B
    % Use first three corners to compute affine map
    A = P1(1:3, :)';  % 2x3: [P1_1, P1_2, P1_3]
    B = P2(1:3, :)';  % 2x3: [P2_1, P2_2, P2_3]

    % Solve for affine transform: B = T * A
    % So T = B * inv(A)
    T = B / A;  % 2x2 affine matrix

    % Apply affine transformation
    mapped_points = (T * points_in_P1')';  % Transform and transpose back
end
