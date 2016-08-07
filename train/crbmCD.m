function[ferr, dW_total, dh_total, dv_total, poshidprobs, poshidstates, negdata] = ...
    crbmCD( l, imdata_batch )
%  fobj_tirbm_CD_LB_sparse(imdata_batch, W, hbias_vec, v_bias, pars, CD_mode, bias_mode, spacing, l2reg);


%%%%%%%%% START POSITIVE PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% do convolution/ get poshidprobs
poshidexp = crbm_inference(l, imdata_batch); % For calculating bottom-up signal to hidden units from visible units

% poshidstates2 = double(poshidprobs > rand(size(poshidprobs)));
[poshidstates, poshidprobs] = sample_multrand(poshidexp, l.Npooling); %sample hidden units (Eq 14)

posprods = crbm_vh_conv(imdata_batch, poshidprobs, l.Nw);
poshidact = squeeze(sum(sum(poshidprobs,1),2));

%%%%%%%%% START NEGATIVE PHASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neghidstates = poshidstates;
for j=1:l.K_CD  %% pars.K_CD-step contrastive divergence
    negdata = crbm_reconstruct(l, neghidstates); %Reconstruct visible units
    % neghidprobs = tirbm_inference(negdata, W, hbias_vec, pars);
    % neghidstates = neghidprobs > rand(size(neghidprobs));
    neghidexp = crbm_inference(l, negdata); %Final step of CD - calculating hidden units again
    [neghidstates, neghidprobs] = sample_multrand(neghidexp, l.Npooling);
    
end
negprods = crbm_vh_conv(negdata, neghidprobs, l.Nw); %Calculate the Negdata given hidden states (Sampling V from H)
neghidact = squeeze(sum(sum(neghidprobs,1),2));

ferr = mean( (imdata_batch(:)-negdata(:)).^2 ); %Calculate the Recon error

% if 0
%     figure(1), display_images(imdata)
%     figure(2), display_images(negdata)
%
%     figure(3), display_images(W)
%     figure(4), display_images(posprods)
%     figure(5), display_images(negprods)
%
%     figure(6), display_images(poshidstates)
%     figure(7), display_images(neghidstates)
% end


%%%%%%%%% UPDATE WEIGHTS AND BIASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch l.bias_mode
    case 'none'
        dhbias = 0;
        dvbias = 0;
        dW = 0;
    case 'simple'
        dhbias = squeeze(mean(mean(poshidprobs,1),2)) - l.phi_sparsity;
        dvbias = 0;
        dW = 0;
    case 'hgrad'
        error('hgrad not yet implemented!');
    case 'Whgrad'
        error('Whgrad not yet implemented!');
    otherwise
        error('wrong adjust_bias mode!');
end



numcases1 = size(poshidprobs,1)*size(poshidprobs,2);
% dW_total = (posprods-negprods)/numcases - l2reg*W - weightcost_l1*sign(W) - pars.pbias_lambda*dW;
dW_total1 = (posprods-negprods)/numcases1;
dW_total2 = - l.l2reg*l.W;
dW_total3 = - l.phi_sparsity_lambda*dW;
dW_total = dW_total1 + dW_total2 + dW_total3;

dh_total = (poshidact-neghidact)/numcases1 - l.phi_sparsity_lambda*dhbias;

dv_total = 0; %dv_total';

cdbn_log(l, sprintf('||W||=%g, ||dWprod|| = %g, ||dWl2|| = %g, ||dWsparse|| = %g\n', sqrt(sum(l.W(:).^2)), sqrt(sum(dW_total1(:).^2)), sqrt(sum(dW_total2(:).^2)), sqrt(sum(dW_total3(:).^2))));


end

