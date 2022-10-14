function [expDesign, selfLabels, otherLabels] = snGenDesignControlFake()

%% to do
% randomize order of trials within a block

%% function to generate experimental design

% default labels
defLabels = 0:25:100;
vsBlock = [1, 1, 1, 1, 1, 1, 1];
voBlock = [0.25, 0.33, 0.50, 1, 2, 3, 4];
voBlock = voBlock(randperm(length(voBlock)));
% number of blocks and trials
nBlocks = size(vsBlock,2);
% exchange rate for each block
erBlock = voBlock./vsBlock; 
erBlockBottom = repelem(0.8,nBlocks);
erBlockTop = repelem(1.2,nBlocks);
% position on the screen
posSelf = 1:1:9;
posSelfRand = ones(1,length(vsBlock)); % posSelf(randperm(length(posSelf)));
nTrialsBlock = 1;

k = 0;

% labels for self and other for each trial
selfLabels = [];
otherLabels = [];

expDesign = [];
for block = 1:nBlocks
    for trial = 1:nTrialsBlock
        k = k + 1;
        a = erBlockBottom(block);
        b = erBlockTop(block);
        erTrial = erBlock(block);
        vsTrial = vsBlock(block);
        voTrial = vsTrial*erTrial;
        selfLabelsTrial = round(defLabels*vsTrial);
        otherLabelsTrial = round(defLabels*voTrial);
        expDesign = [expDesign; block, k, vsBlock(block), voBlock(block), round(erBlock(block),2),...
                                erBlockBottom(block), erBlockTop(block), ...
                                vsTrial, voTrial, round(erTrial,2),...
                                posSelfRand(block)];
        selfLabels = [selfLabels; selfLabelsTrial];
        otherLabels = [otherLabels; otherLabelsTrial];
    end
end


end

