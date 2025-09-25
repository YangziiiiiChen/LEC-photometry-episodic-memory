function result = replace_speed_outliers(dat)

idx = find(dat.speed > 15); 

for row = idx'
    prev = row - 1;
    next = row + 1;
    
    while prev > 0 && dat.speed(prev) > 15
        prev = prev - 1;
    end
    
    while next <= height(dat) && dat.speed(next) > 15
        next = next + 1;
    end
    
    if prev > 0 && next <= height(dat)
        dat.speed(row) = mean([dat.speed(prev), dat.speed(next)]);
        dat.nose_x(row) = mean([dat.nose_x(prev), dat.nose_x(next)]);
        dat.nose_y(row) = mean([dat.nose_y(prev), dat.nose_y(next)]);
    elseif prev > 0
        dat.speed(row) = dat.speed(prev);
        dat.nose_x(row) = dat.nose_x(prev);
        dat.nose_y(row) = dat.nose_y(prev);
    elseif next <= height(dat)
        dat.speed(row) = dat.speed(next);
        dat.nose_x(row) = dat.nose_x(next);
        dat.nose_y(row) = dat.nose_y(next);
    else
        dat.speed(row) = NaN;
        dat.nose_x(row) = NaN;
        dat.nose_y(row) = NaN;
    end
end

result = dat;

end
