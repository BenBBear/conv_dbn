function images = read_database(dataname)
global root
switch lower(dataname)
    case 'natural'
        fpath = strcat(root, '/demo/data/natural_imgs');
        op_type = 'resize';
        flist = dir(sprintf('%s/*.tif', fpath));        
    case 'face'
        fpath = strcat(root, '/demo/data/face_imgs');
        op_type = 'crop';
        crop_to = [88 88];
        flist = dir(sprintf('%s/*.jpg', fpath));
        
    otherwise
        images = [];
        return;
end
images_num = min(length(flist), 200);
images = cell(1, images_num);

for imidx = 1:images_num
    fprintf('[%d]', imidx);
    fname = sprintf('%s/%s', fpath, flist(imidx).name);
    im = imread(fname);
    
    if size(im,3)>1
        im2 = double(rgb2gray(im));
    else
        im2 = double(im);
    end    
    switch lower(op_type)
        case 'resize'
            ratio = min([512/size(im,1), 512/size(im,2), 1]);
            if ratio<1
                im2 = imresize(im2, [round(ratio*size(im,1)), round(ratio*size(im,2))], 'bicubic');
            end
        case 'crop'
            [ r,c] = size(im2);
            if c > r
                im2 = imcrop(im2,[(c-r)/2 0 r-1 r]);
            elseif r > c
                im2 = imcrop(im2,[0 (r-c)/2 c c-1]);
            end
            im2=imresize(im2, crop_to, 'bicubic');
    end
                        
    im2 = im_whiten_contrastnorm(im2);       
    im2 = im2-mean(mean(im2));
    im2 = im2/sqrt(mean(mean(im2.^2)));
    imdata = im2;
    imdata = sqrt(0.1)*imdata; % just for some trick??
    images{imidx} = imdata;   
end
fprintf('\n');
end
