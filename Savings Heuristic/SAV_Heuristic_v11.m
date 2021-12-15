function SAV_Heuristic_v11

clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt s N OD2Route
global initial_schedule counter_AT tour_sched put_aside
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% For Inputing OAHU HH Test Case %%%%%%%%%%%%%%%%%%%%%%%

%common parameters
delimiterIn = ',';
headerlinesIn = 0;

%filename = '1002724_TT.csv';
filename = '1036350_TT.csv';
%filename = '1035989_TT.csv';

tt=importdata(filename,delimiterIn,headerlinesIn);
tt=tt./60; %be careful here.
d = tt;

%filename = '1002724_a.csv';
filename = '1036350_a.csv';
%filename = '1035989_a.csv';

ACT_EARLY=importdata(filename,delimiterIn,headerlinesIn);
n=size(ACT_EARLY,1)/2;


%filename = '1002724_b.csv';
%filename = '1002724_b_tight_tw.csv';
filename = '1036350_b.csv';
%filename = '1035989_b_tight_tw.csv';
%filename = '1035989_b.csv';
ACT_LATE=importdata(filename,delimiterIn,headerlinesIn);

%filename = '1002724_s.csv';
%filename = '1002724_s_short.csv';
filename = '1036350_s.csv';
%filename = '1035989_s.csv';
ACT_DUR=importdata(filename,delimiterIn,headerlinesIn);
ACT_DUR=ACT_DUR./60;

%%%%%%%%%%%%%%%%%%%%%%%%% Get Network Attributes %%%%%%%%%%%%%%%%%%%%%%%%%%
N = size(d,1); %number of nodes

%OD2Route Factor %OD2Route = repmat([1:N],[N,1]);
%For recker - this network is directional
%Form list of unique OD pairs with directions. 1-2 is different from 2-1.
%Also linke from depots to activities are not considered.

c=[];
for P=1:N
    add_this = [[1:N]',repmat(P,[N,1])];
    c=[c;add_this];
end

%remove infeasible X - need to automate
%note: we do not consider links to/from depot for this heuristic
%u_remove=[1,1,1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,8,8,8,8,8];
%w_remove=[1,2,3,4,5,6,7,8,1,2,8,1,3,8,1,4,8,1,5,8,1,6,8,1,7,8,1,2,3,4,5,6,7,8];

%note these are in NODES...so 0 is 1!
%2*n+1 = 15... so 16 nodes total including 0
%note we reomove node '0' since this is built into the savings heuristic

%1002724
%u_remove=[1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,6,6];
%w_remove=[1,2,3,4,5,6,1,2,6,1,3,6,1,4,2,6,1,3,5,6,1,2,3,4,5,6];

%1036350
u_remove=[1,1,1,1,1,1,1,1,1,1 ,1 ,1 ,1 ,1 ,2,2,2 ,3,3,3 ,4,4,4 ,5,5,5 ,6,6,6 ,7,7,7 ,8,8,8, 8,9,9,9, 9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14];
w_remove=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,1,2,14,1,3,14,1,4,14,1,5,14,1,6,14,1,7,14,1,2,8,14,1,3,9,14, 1, 4,10,14, 1, 5,11,14, 1, 6,12,14, 1, 7,13,14, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14];

%1035989
%u_remove=[1,1,1,1,1,1,1,1,1,1 ,1 ,1 ,1 ,1 , 1, 1,2,2,2 ,3,3,3 ,4,4,4 ,5,5,5 ,6,6,6 ,7,7,7 ,8,8,8 ,9,9,9, 9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16];
%w_remove=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,1,2,16,1,3,16,1,4,16,1,5,16,1,6,16,1,7,16,1,8,16,1,2,9,16, 1, 3,10,16, 1, 4,11,16, 1, 5,12,16, 1, 6,13,16, 1, 7,14,16, 1, 8,15,16, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16];

%run through list of node pairs to remove if necessary
remove_impossible_links(u_remove, w_remove)

%%%%%%%%%%%%%%%%%%%%%%% Input Activity Information %%%%%%%%%%%%%%%%%%%%%%%%

%these are the early and late time windows for the vehs when they first
%leave the home.

%check to see if there is an activity before 6
REALLY_EARLY=sum(logical(ACT_EARLY<6));
REALLY_LATE=sum(logical(ACT_LATE>21));

if(REALLY_EARLY>=1)
    earliest_time = min(ACT_EARLY);
    HOME_EARLY  = earliest_time.*ones(2,1);
else
    HOME_EARLY  = [6;6];
end

if(REALLY_LATE>=1)
    latest_time = max(ACT_LATE);
    HOME_LATE  = latest_time.*ones(2,1);
else
    %HOME_LATE  = [6;6];
    HOME_LATE   = [20;21];
end

%node           1    2  3  4  5  6  
%%%%%%%%%%%%%% ORIGINAL %%%%%%%%%%%%%
%ACT_EARLY   = [8  ;10;12;17;10;12];
%ACT_LATE    = [8.5;20;13;19;21;21];
%ACT_DUR     = [8;1;2;0;0;0]; %Original
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ACT_EARLY   = [8  ;6;12;17;10;12];
%ACT_LATE    = [8.5;20;22;21;21;21];
%ACT_DUR     = [0.5;0.5;0.5;0;0;0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input Demand Loads %%%%%%%%%%%%%%%%%%%%%%%%%%%
demand_nodes = 1:N;
dd = ones(N,1);

%filename = 'DEMAND_DATA.csv';
%delimiterIn = ',';
%headerlinesIn = 0;
%dd=importdata(filename,delimiterIn,headerlinesIn);
dload_matrix = [demand_nodes',dd];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% Determine Savings Matrix %%%%%%%%%%%%%%%%%%%%%%%%
dir = 'directional';
%s = link_savings_list(c,d,dir); %this one does not sort for time windows
%s = [i,j,s_ij,a_i,b_i,a_j,b_j];
%i    - origin node of link to be considered
%j    - destination node of link to be considered
%s_ij - savings of link to be considered
%a_i  - earliest start time of i 
%b_i  - latest start time of i
%a_j  - earliest start time of j 
%b_j  - latest start time of j

s = link_savings_list_act(dir); %this one sorts for time windows

%initialize empty cell away of tours
solution          = {};
solution_schedule = {};

%%%%%%%%%%%%%%%%%%%%%%%%% Initialize Process %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialize scheudle with s(1,1) - this is the first link in savings list

all_demand_assigned = 0; %initialize demand count
put_aside = [];

%start with empty tour
candidate_tour = zeros(2*n+1+1,2*n+1+1);

%assume veh leaves home (0) at earliest time possible
u   = 0;
N_u = u+1; 
s_u = 0;
candidate_schedule = [u,N_u,HOME_EARLY(1),HOME_LATE(1),s_u,HOME_EARLY(1),0];

%assume veh arrives home (7) at earliest time possible
w   = 2*n+1;
N_w = w+1; 
s_w = 0;
add_this = [w,N_w,HOME_EARLY(2),HOME_LATE(2),s_w,HOME_LATE(2),0];
candidate_schedule = [candidate_schedule;add_this];

%depot-to-depot
candidate_tour(u+1,w+1)=1;

got_one = 0;
while(got_one ==0&&isempty(s)==0)
%try to insert first link.... keep doing until you find one
output_string = strcat('We are on link: ',num2str(s(1,1)-1),'-',num2str(s(1,2)-1));
disp(output_string)

insert_segment = [candidate_schedule(1,1),s(1,1:2)-1,candidate_schedule(end,1)]; %x-i-j-x
[make_new_tour,out_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule);

if (make_new_tour == 1) %should not happen
    put_aside = [put_aside; s(1,:)];   %if first link cannot be inserted -set aside
    %put_aside = [put_aside; s(1,1:2)];   %if first link cannot be inserted -set aside
    %solution{end+1} = candidate_tour;
    %solution_schedule{end+1} = out_schedule;
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
    
    got_one = 1;
    
end

%remove from savings list
s(1,:)=[];

end

%segment s into 0 cost and others
s_zero  = s(s(:,3)==0,:);
s_nzero = s(s(:,3)>0,:);
s       = s_nzero;

%%%%%%%%%%%% loop through remainder of the savings link list %%%%%%%%%%%%%%
while (isempty(s)==0 && all_demand_assigned==0)
    
    %always check link at the top of the list. 
    this_i = s(1,1);
    this_j = s(1,2);
    
    %indicate which link we are on in the savings list
    output_string = strcat('We are on link: ',num2str(this_i-1),'-',num2str(this_j-1));
    disp(output_string)
   
    num_tours = numel(solution);
    
    %loop through each route/tour in solutions generated so far to check if
    %we are checking if the candidate link has an O or D in one of the
    %route/tour solutions generated so far.
    
    [case1,case2,case3,present_n_tour]=OD_n_solution(this_i,this_j);
        
    %present in tour
    %each row of present_n_tour has these col:
    %r      - route/tour number in solution
    %i_is_O - i is in one of the route/tours in solution
    %j_is_O - j is in one of the route/tours in solution
    %0,1,2  - depending on how many routes/tours have i and/or j
      
    %initialize vehicle operations constraints
    %C1=0; %cannot go directly to dropoff node from 1(home)
    %C2=0; %cannot go back to 1(home) directly from pick-up node
    %C3=0; %cannot go straight to 8 (home) from pick-up node or 1
    %pass_constraints = C1+C2;
    
    if (case1==1)  
        case1_doit(this_i,this_j);
    end
    
    if (case2==1)
        case2_doit_v2(this_i,this_j);
    end
    
    if(case3==1)  
        case3_doit(this_i,this_j);
    end
    
    %remove from savings list regardless of whether it enters a route; note
    %first link on top of the list is always the prsently considered candidate
    %list is already in decending order
    s(1,:)=[];
    
    %check to see if all demand has been assigned
    stopped = zeros(1,N); 
    for r = 1:length(solution)
        stopped = stopped + sum(solution{r},1);
    end
    
    if (sum(stopped~=0,2)==N)
        all_demand_assigned = 1;
    end
    
end

%%%%%%%  check to see if all PU and DO have been assigned to a route %%%%%%
missing_nodes = node_check;
put_aside = [];

%make s_zero new s?
s = s_zero;

%while(isempty(missing_nodes)==0 && isempty(s_zero)==0)
while(isempty(missing_nodes)==0 && isempty(s)==0)
  
    %always check link at the top of the list. 
    %this_i = s_zero(1,1);
    %this_j = s_zero(1,2);
    
    this_i = s(1,1);
    this_j = s(1,2);
    
    %indicate which link we are on in the savings list
    output_string = strcat('We are on link: ',num2str(this_i-1),'-',num2str(this_j-1));
    disp(output_string)
   
    num_tours = numel(solution);
    
    %loop through each route/tour in solutions generated so far to check if
    %the candidate link has an O or D in one of the
    [case1,case2,case3,present_n_tour]=OD_n_solution(this_i,this_j);
        
    %present in tour
    %each row of present_n_tour has these col:
    %r      - route/tour number in solution
    %i_is_O - i is in one of the route/tours in solution
    %j_is_O - j is in one of the route/tours in solution
    %0,1,2  - depending on how many routes/tours have i and/or j
      
    %initialize vehicle operations constraints
    %C1=0; %cannot go directly to dropoff node from 1(home)
    %C2=0; %cannot go back to 1(home) directly from pick-up node
    %C3=0; %cannot go straight to 8 (home) from pick-up node or 1
    %pass_constraints = C1+C2;
    
    if (case1==1)  
        case1_doit(this_i,this_j);
    end
    
    if (case2==1)
        case2_doit_v2(this_i,this_j);
    end
    
    if (case3==1)  
        case3_doit(this_i,this_j);
    end
    
    %remove from savings list regardless of whether it enters a route; note
    %first link on top of the list is always the prsently considered candidate
    %list is already in decending order; you should have put it aside in
    %one of the casees above.
    %s_zero(1,:)=[];
    
    s(1,:)=[];
        
    %if(isempty(s_zero)==1)%it means we went through everything
    if(isempty(s)==1)%it means we went through everything
        %s_zero    = put_aside;
        s    = put_aside;
        put_aside = [];
        
        %check to see if all PU and DO have been assigned to a route
        missing_nodes = node_check;
    end
end
stop=1;

%%%%%%%%%%%%%%%%%%%%%%% Final Route/Tour Metrics %%%%%%%%%%%%%%%%%%%%%%%%%%

%initialize empty cell away of tours
solution_cost     = {};
solution_tt = {};
solution_wt = {};

%determine total cost and total travel time
for r = 1:length(solution)
    
    total_cost_r = solution{r}.*d;
    total_cost_r = sum(total_cost_r,'ALL');
    solution_cost{r}     = total_cost_r;
    %total_dist = total_dist + total_dist_r;
    
    total_tt_r = solution{r}.*tt;
    total_tt_r = sum(total_tt_r,'ALL');
    solution_tt{r}     = total_cost_r;
    
    %total wait time in schedule
    this_schedule = solution_schedule{r};
    total_wait    = sum(this_schedule(:,5));
    solution_wt{r} = total_wait;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stop=1;
