function [ negdata2 ] = crbm_reconstruct(l, S )
%CRBM_RECONSTRUCT Summary of this function goes here
%   S => states

ws = sqrt(size(l.W,1));
patch_M = size(S,1);
patch_N = size(S,2);
numchannels = size(l.W,2);
numbases = size(l.W,3);

S2 = S;
negdata2 = zeros(patch_M+ws-1, patch_N+ws-1, numchannels);

for b = 1:numbases
    H = reshape(l.W(:,:,b),[ws,ws,numchannels]);
    negdata2 = negdata2 + conv2_mult(S2(:,:,b), H, 'full');
end
end

