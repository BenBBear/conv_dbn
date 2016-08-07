function  [result] = display_network( l, other)
figure(1);
idx = l.id;
if idx == 1
    display_network_first(l.W);
    result = l.W;
    return
elseif idx > 1
    result = display_network_following(l.W, other);
    return
end
end

