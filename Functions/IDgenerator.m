function ID=IDgenerator(Max,Num,Flag)

% function m-file to generate random index
%
% INPUT --- Max: maximum value of index
%           Num: the number of index
%           Flag: 1 sort the result
%
% OUTPUT --- ID: the randomly generated ID number


ID=1;
while length(ID)<Num;
    ID=randi(Max, 1, Num*10);
    ID=unique(ID, 'stable');
end
ID=ID(1:Num);
if Flag==1;
    ID=sort(ID(1:Num));
end

