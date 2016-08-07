function im2 = trim_for_pooling(im2, Nw, pooling_size)
% % Trim image so that it matches the spacing.
% % size(im2,1)-ws+1 => the output of the conv. 
if mod(size(im2,1)-Nw+1, pooling_size)~=0
    n = mod(size(im2,1)-Nw+1, pooling_size);
    im2(1:floor(n/2), : ,:) = [];
    im2(end-ceil(n/2)+1:end, : ,:) = [];
end
if mod(size(im2,2)-Nw+1, pooling_size)~=0
    n = mod(size(im2,2)-Nw+1, pooling_size);
    im2(:, 1:floor(n/2), :) = [];
    im2(:, end-ceil(n/2)+1:end, :) = [];
end
end
