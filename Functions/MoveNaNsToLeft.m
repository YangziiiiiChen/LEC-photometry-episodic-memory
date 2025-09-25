function result = MoveNaNsToLeft(matrix)

    result = matrix;
    for i = 1:size(matrix, 1)
        row = matrix(i, :);
        result(i, :) = [row(isnan(row)), row(~isnan(row))];
    end
end