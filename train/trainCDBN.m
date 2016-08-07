function [ layers ] = trainCDBN( layers, idx )

l = layers{idx};
% function train_tirbm_updown_LB_v1h(images_all, ws, num_bases, pbias, pbias_lb, pbias_lambda, spacing, epsilon, l2reg, batch_size)

if isempty(l.input_data)
    l.input_data = read_database(l.database);
end
if isempty(l.input_data)
    l.input_data = layers{idx-1}.output_data;
end
l.num_channels = size(l.input_data{1}, 3);

if isempty(l.W)
     l.W = 0.01*randn(l.Nw^2, l.num_channels, l.num_filters);
end
if isempty(l.v_bias)
    l.v_bias = zeros(l.num_channels,1);
end
if isempty(l.h_bias)
    l.h_bias = -0.01*ones(l.num_filters,1);
end

Winc=0; 
vbiasinc=0.0;
hbiasinc=0.0;
l.imbatch_size = numel(l.input_data);


for t=1:l.num_trials % repeat for number of epochs    
    % Take a random permutation of the samples
    tic;
    ferr_current_iter = [];
    sparsity_curr_iter = [];
    imidx_batch = randsample(length(l.input_data), l.imbatch_size, length(l.input_data)<l.imbatch_size); %randomly take images    
    for i = 1:length(imidx_batch) %repeat for all images
        imidx = imidx_batch(i);
        imdata = l.input_data{imidx};
        rows = size(imdata,1);
        cols = size(imdata,2);
        for batch=1:l.batch_size
            % Show progress in epoch
            cdbn_log(l, sprintf('epoch %d image %d batch %d\r',t, imidx, batch));
            
            rowidx = ceil(rand*(rows-2*l.Nw-l.batch_Nw))+l.Nw + (1:l.batch_Nw); %randomly take rowids and colids
            colidx = ceil(rand*(cols-2*l.Nw-l.batch_Nw))+l.Nw + (1:l.batch_Nw);            

            imdata_batch = imdata(rowidx, colidx, :);
            imdata_batch = imdata_batch - mean(imdata_batch(:)); %make mean 0           
            imdata_batch = trim_for_pooling(imdata_batch, l.Nw, l.Npooling);            
            if flipcoin && l.fliplr
                imdata_batch = fliplr(imdata_batch); %invert the image for introducing variable inputs
            end
            
            % update rbm
            [ferr, dW, dh, dv, poshidprobs, ~, ~]= crbmCD(l, imdata_batch);
            
            % get: dW, ferr, dh, dv, poshidprobs, poshidstates, negdata
            %%%%%%%
            ferr_current_iter = [ferr_current_iter, ferr];
            sparsity_curr_iter = [sparsity_curr_iter, mean(poshidprobs(:))];
            
            if t< l.momentum_change_points
                momentum = l.initial_momentum;
            else
                momentum = l.final_momentum;
            end
            % update parameters
            Winc = momentum*Winc + l.learningRate*dW;
            l.W = l.W + Winc;

            vbiasinc = momentum*vbiasinc + l.learningRate*dv;
            l.v_bias = l.v_bias + vbiasinc;

            hbiasinc = momentum*hbiasinc + l.learningRate*dh;
            l.h_bias = l.h_bias + hbiasinc;
        end
        if (l.std_gaussian > l.sigma_stop) % stop decaying after some point
            l.std_gaussian = l.std_gaussian*0.99;
        end

        % figure(1), display_network(W);
        % figure(2), subplot(1,2,1), imagesc(imdata(rowidx, colidx)), colormap gray
        % subplot(1,2,2), imagesc(negdata), colormap gray
    end
    toc;

    l.error_history(t) = mean(ferr_current_iter);
    l.sparsity_history(t) = mean(sparsity_curr_iter);

    figure(1);
    if idx > 1
        l.display_result = display_network(l, layers{idx-1}.display_result);
    else
        l.display_result = display_network(l, []);
    end
%     if mod(t, l.snapshot_period) == 0
%     end
end


layers{idx} = l;
end

