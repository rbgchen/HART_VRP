function case3_doit(this_i,this_j)

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt s N OD2Route
global initial_schedule counter_AT tour_sched
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%find 2 routes with the 2 points
route_nums = (present_n_tour(:,end)==1).*[1:num_tours]';
route_nums(route_nums==0) = [];        %remove zeros
first_route     =  solution{route_nums(1)};
second_route    =  solution{route_nums(2)};

first_candidate_schedule =  solution_schedule{route_nums(1)}; 
second_candidate_schedule =  solution_schedule{route_nums(2)}; 

end_depot_node = 2*n+1+1;

%find out which route had which node
i_is_O_first = sum(first_route(this_i,:))==1;
j_is_O_first = sum(first_route(this_j,:))==1;

%i_is_D_first = sum(this_tour(:,this_i))==1;
%j_is_D_first = sum(this_tour(:,this_j))==1;
        
%note: if i is in the first node, it must mean j is in secon and vice-versa
        
%note: all nodes are an O and D in the tours, if they are in it since none 
%of these nodes are end nodes; these would be the depots or node 1 and 8
              
%make sure neither is interior       
if (i_is_O_first==1) %then j is in second
            
    j_is_O_second = sum(second_route(this_j,:))==1;
    %j_is_D_second = sum(second_route(:,this_j))==1;
            
    %check if depot (1) is not interior
    %depot_after_i  = first_route(this_i,1)==1;
    
    depot_after_i  = first_route(this_i,end_depot_node)==1;
    depot_before_i = first_route(1,this_i)==1;
           
    depot_after_j  = second_route(this_j,end_depot_node)==1;         
    depot_before_j = second_route(1,this_j)==1;
            
    i_not_interior = depot_after_i+depot_before_i;
    j_not_interior = depot_after_j+depot_before_j;
            
    if(i_not_interior == 1 && j_not_interior == 1)
        %combine routes 
        
        %combine second into first
        candidate_schedule = first_candidate_schedule;
         
        %Note: if i after depot, then j must be before depot to combine
        
        new_route_first  = first_route;
        new_route_second = second_route;
                
        if ((depot_before_i == 1) && (depot_after_j == 1))
            
            %Case 1
            %1-i-X-X-X-1 (first)
            %1-Y-Y-Y-j-1 (second)
            %1-Y-Y-Y-j-i-X-X-X-1(combined)
            
            %remove 1-i link
            new_route_first(1,this_i)=0;
            
            %remove j-8 link
            new_route_second(this_j,end_depot_node)=0;
            
            %add second route to new route
            new_route = new_route_first + new_route_second;
            %add j to i
            new_route (this_j,this_i) = 1;
            
            %check schedule feasibility
            %insert_segment = [candidate_schedule(1,1),insert_this,candidate_schedule(2,1)]; %x-i-j-x
            insert_this = second_candidate_schedule(1:end-1,1);
            insert_segment =[insert_this',candidate_schedule(2:3,1)];
            [make_new_tour,new_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule);
             
            %we passed update
            if (make_new_tour == 0)
            
                %get rid of old routes
                solution{route_nums(1)}=[];
                solution{route_nums(2)}=[];
                solution_schedule{route_nums(1)}=[];
                solution_schedule{route_nums(2)}=[];
                        
                solution{end+1} = new_route; 
                solution_schedule{end+1}=new_schedule; 
            
            end
            
        end
                       
        if ((depot_before_j == 1)&&(depot_after_i == 1))
            
            %Case 2
            %1-j-Y-Y-Y-1 (second)
            %1-X-X-X-i-1 (first)
            %1-X-X-X-i-j-Y-Y-Y-1(combined)
            
            %remove i-8 link
            new_route_first(this_i,end_depot_node)=0;
            
            %remove 1-j link
            new_route_second(1,this_j)=0;
            
            %add second route to new route
            new_route = new_route_first + new_route_second;
            %add i to j
            new_route (this_i,this_j) = 1;
            
            %check schedule feasibility
            %insert_this = second_candidate_schedule(2:end-1,1);
            %insert_segment = [candidate_schedule(1,end-1),insert_this,candidate_schedule(end,1)]; %x-i-j-x
            
            insert_this = second_candidate_schedule(2:end,1);
            insert_segment =[candidate_schedule(end-1,1),insert_this'];
            [make_new_tour,new_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule);
            
            %we passed update
            if (make_new_tour == 0)
            
                %get rid of old routes
                solution{route_nums(1)}=[];
                solution{route_nums(2)}=[];
                solution_schedule{route_nums(1)}=[];
                solution_schedule{route_nums(2)}=[];
                        
                solution{end+1} = new_route; 
                solution_schedule{end+1}=new_schedule; 
            
            end
            
        end
    end
end

if (j_is_O_first==1) %then i is in second
    
    i_is_O_second = sum(second_route(this_i,:))==1;
    
    depot_after_i  = second_route(this_i,end_depot_node)==1;
    depot_before_i = second_route(1,this_i)==1;
           
    depot_after_j  = first_route(this_j,end_depot_node)==1;         
    depot_before_j = first_route(1,this_j)==1;
            
    i_not_interior = depot_after_i+depot_before_i;
    j_not_interior = depot_after_j+depot_before_j;
    
    if(i_not_interior == 1 && j_not_interior == 1)
        %combine routes 
        
        %combine second into first
        candidate_schedule = first_candidate_schedule;
        
        %Note: if i after depot, then j must be before depot to combine
        
        new_route_first  = first_route;
        new_route_second = second_route;
                
        if ((depot_before_i == 1) && (depot_after_j == 1))
            
            %Case 3
            %1-i-X-X-X-1 (second)
            %1-Y-Y-Y-j-1 (first)
            %1-Y-Y-Y-j-i-X-X-X-1(combined)
            
            %remove 1-i link
            new_route_second(1,this_i)=0;
            
            %remove j-8 link
            new_route_first(this_j,end_depot_node)=0;
            
            %add second route to new route
            new_route = new_route_first + new_route_second;
            %add j to i
            new_route (this_j,this_i) = 1;
            
            %check schedule feasibility
            %insert_this = second_candidate_schedule(2:end-1,1);
            %insert_segment = [candidate_schedule(1,end-1),insert_this,candidate_schedule(end,1)]; %x-i-j-x
            
            
            insert_this = second_candidate_schedule(2:end,1);
            insert_segment =[candidate_schedule(end-1,1),insert_this'];
            [make_new_tour,new_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule);
            
            %we passed update
            if (make_new_tour == 0)
            
                %get rid of old routes
                solution{route_nums(1)}=[];
                solution{route_nums(2)}=[];
                solution_schedule{route_nums(1)}=[];
                solution_schedule{route_nums(2)}=[];
                        
                solution{end+1} = new_route; 
                solution_schedule{end+1}=new_schedule; 
            
            end
            
        end
        
        if ((depot_before_j == 1) && (depot_after_i == 1))
            
            %Case 4
            %1-X-X-X-i-1 (second)
            %1-j-Y-Y-Y-1 (first)
            %1-X-X-X-i-j-Y-Y-Y-1(combined)
            
            %remove i-8 link
            new_route_second(this_i,end_depot_node)=0;
            
            %remove 1-j link
            new_route_first(1,this_j)=0;
            
            %add second route to new route
            new_route = new_route_first + new_route_second;
            
            %add j to i
            new_route (this_i,this_j) = 1;
            
            %check schedule feasibility
            %insert_this = second_candidate_schedule(2:end-1,1);
            %insert_segment = [candidate_schedule(1,1),insert_this,candidate_schedule(2:end,1)]; %x-i-j-x
            
            insert_this = second_candidate_schedule(2:end,1);
            insert_segment =[candidate_schedule(end-1,1),insert_this'];
            [make_new_tour,new_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule);
            
            %we passed update
            if (make_new_tour == 0)
            
                %get rid of old routes
                solution{route_nums(1)}=[];
                solution{route_nums(2)}=[];
                solution_schedule{route_nums(1)}=[];
                solution_schedule{route_nums(2)}=[];
                        
                solution{end+1} = new_route; 
                solution_schedule{end+1}=new_schedule; 
            
            end
            
            
        end
        
    end
            
    
end