function [ result ] = parse_input_kv( lst )
    len = length(lst);
    if mod(len, 2) ~= 0
        error('Key Value Pairs are not matched');
    end    
    result = {};
    for i=1:2:numel(lst)
        x.key = lst{i};
        x.value = lst{i+1};
        result{end+1} = x; 
    end
end

