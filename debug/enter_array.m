function output = enter_array()
% Build array using numpad and enter key
if nargin < 1
    output = [];
else
    output = starting_array;
end

a = -1;
while a ~= 0
    a = input('.>');
    if isa(a, 'double')
        if a > 0
            output = [output, a];
        end
    end
end
    