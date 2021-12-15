function missing_nodes=node_check

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt s N OD2Route
global initial_schedule counter_AT tour_sched put_aside
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

missing_nodes = [];
for node = 1:2*n
    %loop through each tour
    n_tour=0;
    for r = 1:length(solution)    
        this_tour = solution_schedule{r};
        n_tour    = n_tour + sum(this_tour(:,1)==node);  
    end
    
    if (n_tour == 0)
        missing_nodes = [missing_nodes;node];
    end

end