function [expDesign, expSocialInfo] = snGenDesignControl()


%% function to generate experimental design for first control 
vsBlock = [1, 1, 1, 1, 1, 1, 1];
voBlock = [0.25, 0.33, 0.50, 1, 2, 3, 4];
voBlock = voBlock(randperm(length(voBlock)));
% number of blocks and trials
nBlocks = size(vsBlock,2);
% zeros for social info
expSocialInfo = zeros(nBlocks,8);
% exchange rate for each block
erBlock = voBlock./vsBlock; 
expDesign = [];
for block = 1:nBlocks
    erTrial = erBlock(block);
    vsTrial = vsBlock(block);
    voTrial = vsTrial*erTrial;
    expDesign = [expDesign; vsBlock(block), voBlock(block), round(erBlock(block),2),...
                            vsTrial, voTrial, round(erTrial,2),...
                            block,block,block,...
                            block,block,1,block];
                        
                                               

end




end

