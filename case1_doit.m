function case1_doit(this_i,this_j)

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt s N OD2Route
global initial_schedule counter_AT tour_sched
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %initialize new route and add to solutions
% new_tour = zeros(N,N);
% new_tour(1,this_i)=1; %out of depot to first node
% new_tour(this_i,this_j)=1; %first node to second node
% new_tour(this_j,8)=1; %second node back in to depot
% solution{end+1} = new_tour;


%start with empty tour
candidate_tour = zeros(2*n+1+1,2*n+1+1);

%assume veh leaves home (0) at earliest time possible
u = 0;
N_u = u+1; 
s_u = 0;
candidate_schedule = [u,N_u,HOME_EARLY(1),HOME_LATE(1),s_u,HOME_EARLY(1),0];
%tour_sched = [u,N_u,HOME_EARLY(1),HOME_LATE(1),s_u,HOME_EARLY(1),0];

%assume veh arrives home (7) at earliest time possible
w = 2*n+1;
N_w = w+1; 
s_w = 0;
add_this = [w,N_w,HOME_EARLY(2),HOME_LATE(2),s_w,HOME_LATE(2),0];
candidate_schedule = [candidate_schedule;add_this];

%depot-to-depot
candidate_tour(u+1,w+1)=1;

%try to insert first link
insert_segment = [candidate_schedule(1,1),s(1,1:2)-1,candidate_schedule(end,1)]; %x-i-j-x
[make_new_tour,out_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule);
%initial_schedule = candidate_schedule;

if (make_new_tour == 1)
    
    %if first link cannot be inserted- you will need to give up.
    put_aside = [put_aside; s(1,:)];   
    
else
    
    for p = 1:(numel(insert_segment)-1)
       u = insert_segment(p);
       w = insert_segment(p+1);
       
       %make sure any origin and dest associated is zeroed out
       candidate_tour(u+1,:)=0;
       candidate_tour(:,w+1)=0;
       candidate_tour(u+1,w+1)=1; %out of depot to first node
    end
    solution{end+1} = candidate_tour;
    solution_schedule{end+1} = out_schedule;
end
