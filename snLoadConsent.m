function S = snLoadConsent



% move to proper image directory
PWD = pwd;
folder = 'consent';
fileType = 'png';



                                  

filenames   = dir([folder filesep '*.' fileType]);  % get all the images   
nrImages    = size(filenames, 1);

% rename files with zero padding
%sprintf('Slide%3.3d.img', imageNumber);
%filenames   = dir([folder filesep '*.' fileType]);  % get all the images     
% for k = 1:nrImages
%     filenames(k,:) = sprintf('Slide%d.png', k);
% end

cd(folder);


    
    for i = 1:nrImages    
        S(i,1).id = [num2str(i,'%02.f')];
        S(i,1).imgfile = filenames(i).name;
    end
    
    % load images
    for i=1:nrImages
        S(i,1).img = imread(S(i,1).imgfile);
    end
    
    cd('../');

% end

% return to original directory
cd(PWD);