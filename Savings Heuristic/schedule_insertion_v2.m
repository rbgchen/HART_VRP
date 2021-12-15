function [make_new_tour,new_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule)

global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt s
global initial_schedule counter_AT tour_sched put_aside
%This function is to test the schedule adjustment from an insertion

%We want to insert [i1-r1-r2...rn-i2] or some variant

i1 = insert_segment(1);
rn = insert_segment(2:end-1);
i2 = insert_segment(end);

%find location of i1
[insert_here,c] = find(candidate_schedule(:,1)==i1);
new_schedule = candidate_schedule(1:insert_here,:);
PF = zeros(numel(1:insert_here),1);

u = i1;
n_middle = rn;

for r=n_middle
    w = r;
    is_i2=0;
    new_nodes=1;
    
    %get time components of new act
    [T_w,AT_inserted,WT_inserted]=arrival_time(u,w,new_nodes,new_schedule,is_i2);
    new_act = [w,w+1,ACT_EARLY(w),ACT_LATE(w),ACT_DUR(w),T_w,WT_inserted];
    
    %add to schedule
    new_schedule = [new_schedule;new_act];
    u=w;
end

%now remainder of activities

%find location of i2
[insert_here,c] = find(candidate_schedule(:,1)==i2);

for r = candidate_schedule(insert_here:end,1)'
    new_nodes=0;
    is_i2=(r==i2);
    u = w; %node previous
    w = r;
    [T_w,AT_inserted,WT_inserted]=arrival_time(u,w,new_nodes,new_schedule,is_i2,candidate_schedule);
    
    if(w==(2*n+1))
        new_act = [w,w+1,HOME_EARLY(2),HOME_LATE(2),0,T_w,WT_inserted];
    else
        new_act = [w,w+1,ACT_EARLY(w),ACT_LATE(w),ACT_DUR(w),T_w,WT_inserted];
    end
    
    
    %add to schedule
    new_schedule = [new_schedule;new_act];
    
end

%check for violations
these_act = new_schedule(:,1);
T = new_schedule(:,6);
WT = new_schedule(:,7);

LATE_ALL = [HOME_LATE(1);ACT_LATE;HOME_LATE(2)];

%schedule_violations = sum(T>b(these_act+1));
schedule_violations = 0;
for act = these_act'
    this_row = (new_schedule(:,1)==act);
    schedule_violations =  schedule_violations...
                         + (T(this_row)>LATE_ALL(act+1));
end


%%%%%%%%%%%%%%%%%%%%%% Check Ordering %%%%%%%%%%%%%%%%%%%%%%%%

first = new_schedule(:,1)>=(n+1);
second = new_schedule(:,1)<(2*n+1);
has_doff_nodes = sum(first.*second)>0;
%has_doff_nodes = sum(((new_schedule(:,1)>=(n+1))+(new_schedule(:,1)<(2*n+1))))>=1;

only_doff_nodes =0;
doff_b4_piup = 0;

if(has_doff_nodes ==1)
    for doff_node = n+1:n+n
        
        %check to make sure this doff_node is present
        doff_here = find(new_schedule(:,1)==doff_node);
        
        if(isempty(doff_here)==0)
            
            %drop-off cannot happen before pickup
            piup_node = doff_node-n;
            piup_here = find(new_schedule(:,1)==piup_node);
        
        
            if(isempty(piup_here)==1)
                %drop-off is in there without pickup
                only_doff_nodes = only_doff_nodes + 1;
                %doff_b4_piup = 0; %put in to prevent error later
            else
                %only_doff_nodes = 0;
            
                if(doff_here<=piup_here)
                    doff_b4_piup = doff_b4_piup + 1;
                else
                    %doff_b4_piup = 0;
                end
            end
        end
         
    end
else
    %only_doff_nodes = 0;
    %doff_b4_piup = 0;
end

%%%%%%%%%%%%%%%% This spot needs HELP %%%%%%%%%%%%%%%%%%%%%%%%%%%

%if we have a violation we have to deal with this...? how
%for now, just don't allow insertion and make the new insertion it's own
%route if possible.

if (schedule_violations >0||doff_b4_piup >= 1||only_doff_nodes >= 1) %NOTHING CHANGES AND SUGGEST A NEW TOUR
    make_new_tour = 1;
    new_schedule = candidate_schedule; %go back to original
else %keep new_schedule as schedule out
    make_new_tour = 0;
end

here = 1;









