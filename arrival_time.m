function [T_w,AT_inserted,WT_inserted]=arrival_time(u,w,new_nodes,new_schedule,is_i2,candidate_schedule)

%global s a tt a_v
%global AT WT T PF
%global initial_schedule counter_AT

global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt
global initial_schedule counter_AT tour_sched

N_u = u+1;
N_w = w+1;

%u,w = [0,1,2,3,4,5,6,7]

%u = veh_start_stop(1,1);
%w = 1+1;%act 1 plus 1 due to matrix indexing.

%s_u = veh_start_stop(1,4);
%s_w = act_attr(1,4);
%a_w = act_attr(1,2);
%T_u = initial_schedule(1,4);

if (u==0)
    s_u=0;
else
    %s_u = s(u);
    s_u = ACT_DUR(u);
end

%s_w = s(w);
switch w
    case {1,2,3,4,5,6}
        %a_w = a(w);
        a_w = ACT_EARLY(w);
    case {7}
        a_w = HOME_EARLY(2);
end
%T_u = T(u+1);%previous activity?
%T_u = T(end);
%T_u = tour_sched(end,6);

T_u = new_schedule(new_schedule(:,1)==u,6);
tt_uw = tt(N_u,N_w);

%determine arrival time
AT_inserted = T_u + s_u + tt_uw;

if (AT_inserted >= a_w)
    WT_inserted = 0;
    T_w = AT_inserted;
else
    WT_inserted = a_w-AT_inserted;
    T_w = a_w;
end

%update
%new_act = [w,AT_inserted,wt,T_w];
AT = [AT;AT_inserted];
WT = [WT;WT_inserted];
T  = [T;T_w];

% switch counter_AT
%     case 1 %first act of tour...depot
%         PF1 = 0;
%     case 2
%         this_row = initial_schedule(:,1)==w;
%         T_w_old = initial_schedule(this_row,4);
%         PF1 = max(0,T_w-T_w_old);
%     otherwise
%         this_row = initial_schedule(:,1)==w;
%         PF1 = max(0,PF(end)-initial_schedule(this_row,3));
% end

%%%%%%%%%%%%THIS NEEDS HELP %%%%%%%%%%%%%%%%%

if (new_nodes==0)%need to update old ones
    if(is_i2==1)
        this_row = candidate_schedule(:,1)==w;
        T_w_old = candidate_schedule(this_row,6);
        PF1 = max(0,T_w-T_w_old);
    else
        PF1 = max(0,PF(end)-WT_inserted);
    end
else
    PF1=0; %no PF if activity is new
end
PF = [PF;PF1];
%%%%%%%%%%%%THIS NEEDS HELP %%%%%%%%%%%%%%%%%