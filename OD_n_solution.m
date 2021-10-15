function [case1,case2,case3,present_n_tour]=OD_n_solution(this_i,this_j)

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt s N
global initial_schedule counter_AT tour_sched
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

present_n_tour = [];
for r = 1:num_tours
         this_tour = solution{r};
         
         %for each i/j check to see which tours they are present
         %note these points will always be either an O and a D so we only check one
         %for example if i is the O, then j is the D and vice versa.
         
         i_is_O = sum(this_tour(this_i,:))>=1;
         %i_is_D = sum(this_tour(:,this_i))>=1;
         
         j_is_O = sum(this_tour(this_j,:))>=1;
         %j_is_D = sum(this_tour(:,this_j))>=1;
         
         check = [i_is_O,j_is_O];
          
         present_n_tour = [present_n_tour;...
                           [r,check]];
end
    
%IDs of tours that have one end point from the candidate link (i,j)
present_n_tour = [present_n_tour,...
                  sum(present_n_tour(:,2:3),2)];
    
%each row of present_n_tour has these col:
%r      - route/tour number in solution
%i_is_O - i is in one of the route/tours in solution
%j_is_O - j is in one of the route/tours in solution
%0,1,2  - depending on how many routes/tours have i and/or j
    
%Check to see which case we have
case1 = (sum(present_n_tour(:,end))==0); %there is no tour with both or either point individually
case2 = (sum(present_n_tour(:,end))==1); %there is a tour with exactly one of the two points
case3 = (sum(present_n_tour(:,end))==2&...
         sum(present_n_tour(:,end)==1)>0); %there is a tour with each one of the points (in different tours)
end
