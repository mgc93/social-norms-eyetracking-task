function [expDesignTrial, expDesignControl, expSocialInfoTrial, expNoSocialInfo] = snGenDesignPosition(square_self)

% read csv file
SocialInfo = readtable('data_social_info.csv');

%% function to generate experimental design
expSocialInfo = table2array(SocialInfo(:,{'subject_1','subject_2','subject_3','subject_4',...
    'subject_5','subject_6','subject_7','subject_8'}));
expDesign = table2array(SocialInfo(:,{'value_self_block','value_other_block','exchange_rate_block',...
    'value_self_trial','value_other_trial','exchange_rate_trial',...
    'trial_block_number','block_number','trial'}));

% added - trial_exp, block_exp, pos_square_self

% position on the screen of self
%square_self = [3, 7, 2, 5, 4, 6, 9]; %randperm(9);
expDesign(:,10) = transpose(repelem(square_self,20));

expSocialInfoBlock = [];
expSocialInfoTrial = [];
expDesignBlock = [];
expDesignTrial = [];
% randomize blocks
block_number_exp = randperm(7);
trial_exp = 0;
for i = 1:7
    % select block
    expDesignBlock = expDesign(block_number_exp(1,i)==expDesign(:,8),:);
    expSocialInfoBlock = expSocialInfo(block_number_exp(1,i)==expDesign(:,8),:);
    % randomize order of trials within blocks
    trial_block_number_exp = randperm(20);
    for j = 1:20
        trial_exp = trial_exp + 1;
        % select trial
        expDesignTrial = [expDesignTrial; expDesignBlock(trial_block_number_exp(1,j)==expDesignBlock(:,7),1:9), j, i,expDesignBlock(trial_block_number_exp(1,j)==expDesignBlock(:,7),10), trial_exp];
        expSocialInfoTrial = [expSocialInfoTrial; expSocialInfoBlock(trial_block_number_exp(1,j)==expDesignBlock(:,7),:)];
    end
end



% generate control trial
expDesignControl = [];
for i = 1:size(expDesign,1)
    if(mod(i,21)==1)
        expDesignControl = [expDesignControl; expDesignTrial(i,:)];
    end
end

% use mean exchange rates from blocks as trial exchange rates
for i = 1:size(expDesignControl,1)
    expDesignControl(i,5) = expDesignControl(i,2);
    expDesignControl(i,6) = expDesignControl(i,3);
end

% all social information is 0 for control trials
expNoSocialInfo = zeros(7,8);

end

