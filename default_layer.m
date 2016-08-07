function [ layer ] = default_layer( varargin )
% create a layer by default parameter

layer.database = '';
layer.input_data = [];

layer.Nw=10; %ws=10; %Weight shape Nw
layer.num_filters = 24;  %num_bases= 24; %Number of weights K
layer.phi_sparsity = 0.003; %pbias=.003; % sparsity parameter - expected activations of the hidden units
layer.phi_sparsity_lambda = 5; % pbias_lambda=5; %Learning rate for sparsity update
layer.Npooling = 2; % spacing=2; %C - pooling ratio
layer.learningRate = 0.02; %epsilon=.02; % Learning rate - the ratio of change taken from gradient descent
layer.l2reg = 0.01; %l2reg=.01; % Weight decay - regularization factor to keep the length of weight vector small
layer.batch_size = 10;    %batch_size=10; % Number of patches from each image
layer.batch_Nw = 50; %  batch_ws = 70; % changed from 100 (2008/07/24) - shape of the patch of the image to be fed to the network
layer.imbatch_size = floor(100/layer.batch_size); %imbatch_size

layer.num_trials = 1000;
layer.snapshot_prefix = './snapshots/';
layer.snapshot_period = 50; % mod(t, 50)
layer.id = 1; %% to determine is visible or not.
layer.initial_momentum  = 0.5; % initialmomentum  = 0.5; % used in updating parameters (W,vbias,hbias)
layer.final_momentum    = 0.9; % finalmomentum    = 0.9; % change value after a certain number (5) of epochs
layer.momentum_change_points = 5;
layer.W = [];

layer.K_CD = 1;
layer.CD_mode = 'exp';
layer.bias_mode = 'simple';
layer.sigma_start = 0.2;
layer.std_gaussian = layer.sigma_start;
layer.sigma_stop = 0.1;
layer.v_bias = [];  %  vbias_vec = [];
layer.h_bias = [];  %  hbias_vec = [];
layer.error_history = [];
layer.sparsity_history = [];
layer.console = true;
layer.fliplr = false;

kv_pairs = parse_input_kv(varargin);
for i=1:numel(kv_pairs);
    k = kv_pairs{i}.key;
    v = kv_pairs{i}.value;
    layer.(k) = v;
end
end

