function s=link_savings_list_act(c,d,dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt s N
global initial_schedule counter_AT tour_sched
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s=[];
for ij = 1:size(c,1)
    i = c(ij,1);
    j = c(ij,2);
    
    ai = ACT_EARLY(i-1); %minus 1 because it is depot
    bi = ACT_LATE(i-1); %minus 1 because it is depot
    
    aj = ACT_EARLY(j-1); %minus 1 because it is depot
    bj = ACT_LATE(j-1); %minus 1 because it is depot
    
    if (strcmp('directional',dir)==1)
        
        depot2 = 2*n+1+1;
        
        s_ij = (d(1,i) + d(i,depot2)) +...
               (d(1,j) + d(j,depot2)) -... 
               (d(1,i)+d(i,j)+d(j,depot2)); %for Recker
    else
        s_ij = d(1,i) + d(1,j) - d(i,j);    
    end
    
    s = [s;...
          [c(ij,1:2),s_ij,[ai,bi],[aj,bj]]];
    
    %s = [s;...
    %      [c(ij,1:2),s_ij]];
end

%sort
col_sav=3; %savings is in 3rd col
col_EARLY_i=4; %savings is in 3rd col
col_EARLY_j=6; %savings is in 3rd col

s=sortrows(s,[col_sav,col_EARLY_i,col_EARLY_j,1,2],...
            {'descend','ascend','ascend','ascend','ascend'});
end