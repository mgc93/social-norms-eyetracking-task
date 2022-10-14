% check social info screens
% cehck if median others neighbors is correlated with median others
clear all;

rng(1234);

pos_matrix = [];
for i = 1:100
    square_self_rand = randperm(9);
    square_self = square_self_rand(1:7);
    
    
    % square_self = [3, 7, 2, 5, 4, 6, 9]; %randperm(9);
    % square_self = [2, 7, 8, 1, 5, 4, 9]; % 0.008
    
    [expDesign, expDesignControl, expSocialInfo, expNoSocialInfo] = snGenDesignPosition(square_self);
    med_all(:,i) = median(expSocialInfo,2);
    
    for trial = 1:140
        if(expDesign(trial,12)==1)
            med_neighbors(trial,i) = median(expSocialInfo(trial,[1,3,4]));
        elseif(expDesign(trial,12)==2)
            med_neighbors(trial,i) = median(expSocialInfo(trial,[1,2,3,4,5]));
        elseif(expDesign(trial,12)==3)
            med_neighbors(trial,i) = median(expSocialInfo(trial,[2,4,5]));
        elseif(expDesign(trial,12)==4)
            med_neighbors(trial,i) = median(expSocialInfo(trial,[1,2,4,6,7]));
        elseif(expDesign(trial,12)==5)
            med_neighbors(trial,i) = median(expSocialInfo(trial,[1,2,3,4,5,6,7,8]));
        elseif(expDesign(trial,12)==6)
            med_neighbors(trial,i) = median(expSocialInfo(trial,[2,3,5,7,8]));
        elseif(expDesign(trial,12)==7)
            med_neighbors(trial,i) = median(expSocialInfo(trial,[4,5,8]));
        elseif(expDesign(trial,12)==8)
            med_neighbors(trial,i) = median(expSocialInfo(trial,[4,5,6,7,8]));
        else
            med_neighbors(trial,i) = median(expSocialInfo(trial,[5,6,8]));
        end
    end
    
    all_pos(:,i) = transpose(repelem(square_self,20));
    if(any(square_self==5))
        has_middle(1,i) = 1;
        if(square_self(1)==5)
            first_middle(1,i) = 1;
        else
            first_middle(1,i) = 0;
        end
    else
        has_middle(1,i) = 0;
        first_middle(1,i) = 0;
    end
    %ind_middle = find(square_self==5);
    cor = corrcoef(med_neighbors(all_pos(:,i)~=5,i),med_all(all_pos(:,i)~=5,i));
    pos_matrix = [pos_matrix; square_self, cor(2,1), has_middle(1,i), first_middle(1,i)];
   
%     cor = corrcoef(med_neighbors(:,i),med_all(:,i));
%     pos_matrix = [pos_matrix; square_self, cor(2,1), has_middle, first_middle];
end

% [2, 7, 8, 1, 5, 4, 9]; % 0.008
% [6, 8, 9, 5, 2, 3, 4]; % 0.02
figure(1);
scatter(med_neighbors(all_pos(:,42)~=5,42),med_all(all_pos(:,42)~=5,42))
figure(2);
scatter(med_neighbors(:,42),med_all(:,42))


