function [ layers ] = crbm_forward( layers, idx )
l = layers{idx};

if isempty(l.input_data)
    l.input_data = read_database(l.database);
end

ConvolvedFeaturesL1=[];
dim_order = [3,4,1,2];

for i=1:numel(l.input_data)
    imdata_batch=l.input_data{i};
    imdata_batch = imdata_batch - mean(imdata_batch(:));
    imdata_batch = trim_for_pooling(imdata_batch, l.Nw, l.Npooling);
    poshidexp = crbm_inference( l, imdata_batch );
    [poshidstates, ~] = sample_multrand(poshidexp, l.Npooling);
    ConvolvedFeaturesL1=cat(4,ConvolvedFeaturesL1,poshidstates);
end

ConvolvedFeaturesL1=permute(ConvolvedFeaturesL1, dim_order);
PooledFeaturesL1=max_pooling(ConvolvedFeaturesL1, l.Npooling);
PooledFeaturesL1=permute(PooledFeaturesL1, dim_order);
numImages=size(PooledFeaturesL1,4);
images_all_conv=cell(1,numImages);
for i=1:numImages
    
    images_all_conv{i}=squeeze(PooledFeaturesL1(:,:,:,i));
    
end
l.output_data = images_all_conv;
layers{idx} = l;
end

