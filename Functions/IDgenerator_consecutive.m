function ID = IDgenerator_consecutive(Max, Num, Flag)
% function m-file to generate consecutive index
%
% INPUT --- Max: maximum value of index
%           Num: the length of consecutive index
%           Flag: 1 sort the result (not really needed here since it's consecutive)
%
% OUTPUT --- ID: the generated consecutive ID numbers

if Num > Max
    error('Num cannot be larger than Max.');
end

startIdx = randi(Max - Num + 1); % random index
ID = startIdx : startIdx + Num - 1;

if Flag == 1
    ID = sort(ID);
end
