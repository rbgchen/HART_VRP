function case2_doit_v2(this_i,this_j)

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d solution solution_schedule num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM ACT_DUR
global AT WT T PF tt s N OD2Route
global initial_schedule counter_AT tour_sched
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%expand the one tour with the one endpoint
%find which tour this is...

route_nums                = (present_n_tour(:,end)==1).*[1:num_tours]';
route_nums(route_nums==0) = [];        %remove zeros
%this_route                =  solution{route_nums(1)};

this_route                =  solution{route_nums};
candidate_schedule        =  solution_schedule{route_nums}; 

%check to see if i or j is already in the tour
i_n_tour = sum(this_route(this_i,:))==1;      
j_n_tour = sum(this_route(this_j,:))==1;
       
if (i_n_tour == 1) %i is in the tour; insert j
    
    %the node inserted is j
    node_insert = this_j-1;
    
    %this means that node i needs to preceed node 7
    %check if node in tour is not interiot
    depot_after  = (this_route(this_i,end   )==1);  %node i preceeds node 7
    depot_before = (this_route(1     ,this_i)==1);  %node 0 preceeds node i
    
    %check if the node you insert is a dropoff node;
    %if it is a dropoff node, make sure the pickup is in the same route;
    %if the pickup is in the same route, make sure it comes before where
    %you want to insert;
    
    these=[1:n]+n;
    if(sum(node_insert==these)>=1 && ((depot_after+depot_before)==1))
        node_insert
        PU_node = node_insert-n; 
        PU_present = sum(candidate_schedule(:,1)==PU_node);
            
        %find location of PU_node
        [PU_r,c] = find(candidate_schedule(:,1)==PU_node);        
        PU_here = 1-isempty(PU_r);
        
        if(PU_here ==1)
            if (depot_after==1)
                cutoff = N-2;
            end
            if (depot_before==1)
                cutoff = 2;
            end
            PU_order = PU_r<cutoff;
        else
            PU_order = 0;
        end
            
        C_PD_V = 1-((PU_here + PU_order)==2);
    else
        C_PD_V = 0;
    end
      
    
    if (depot_after==1&&C_PD_V==0) 
        
        %%%%%Check Schedule Insertaion for (j,7)
        u = this_i-1;
        w = node_insert;
        %w = 2*n+1;
        
        %new_nodes,new_schedule,is_i2
        new_nodes = 1; %requires inserting a new node
        is_i2 = (w==(2*n+1)); %destination is depot at end of day
                               
        insert_segment = [candidate_schedule(end-1,1),w,candidate_schedule(end,1)]; %x-i-j-x
        [make_new_tour,new_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule);
        
        
        %we passed update
        if (make_new_tour == 0)
            %remove (i,7)
            this_route(this_i,2*n+1+1)=0;
                
            %make (i,j)
            this_route(this_i,this_j)=1;
                
            %make (j,7)
            this_route(this_j,2*n+1+1)=1;
            
            solution{route_nums}=this_route;
            solution_schedule{route_nums}=new_schedule; 
            
        end
    end
            
    if (depot_before==1&&C_PD_V==0) %and j is inserted node, this is not possible
        stop=1;
    end
end

if (j_n_tour == 1)
    %the node inserted is i
    node_insert = this_i-1;
    
    %this means that node 0 needs to preceed node j.... 0-i-j
    %check if node in tour is not interiot
    depot_after  = (this_route(this_j,end   )==1);  %node j preceeds node 7
    depot_before = (this_route(1     ,this_j)==1);  %node 0 preceeds node j
    
    %check if the node you insert is a dropoff node;
    %if it is a dropoff node, make sure the pickup is in the same route;
    %if the pickup is in the same route, make sure it comes before where
    %you want to insert;
    
    these=[1:n]+n;
    if(sum(node_insert==these)>=1 && ((depot_after+depot_before)==1))
        node_insert
        PU_node = node_insert-n; 
        PU_present = sum(candidate_schedule(:,1)==PU_node);
            
        %find location of PU_node
        [PU_r,c] = find(candidate_schedule(:,1)==PU_node);        
        PU_here = 1-isempty(PU_r);
        
        if(PU_here ==1)
            if (depot_after==1)
                cutoff = N-2;
            end
            if (depot_before==1)
                cutoff = 2;
            end
            PU_order = PU_r<cutoff;
        else
            PU_order = 0;
        end
            
        C_PD_V = 1-((PU_here + PU_order)==2);
    else
        C_PD_V = 0;
    end
    
    
    if (depot_before==1&&C_PD_V==0)
        %%%%%Check Schedule Insertaion for (j,7)
        u = 0;
        w = node_insert;
        
        %new_nodes,new_schedule,is_i2
        new_nodes = 1; %requires inserting a new node
        is_i2 = (w==(2*n+1)); %destination is depot at end of day
                
        insert_segment = [candidate_schedule(1,1),w,candidate_schedule(2,1)]; %x-i-j-x
        [make_new_tour,new_schedule]=schedule_insertion_v2(insert_segment,candidate_schedule);
        
        if(make_new_tour == 0)
            %remove (0,j)
            this_route(0+1,this_j)=0;
        
            %make (0,i)
            this_route(0+1,this_i)=1;
                
            %make (i,j)
            this_route(this_i,this_j)=1;
            
            solution{route_nums}=this_route;
            solution_schedule{route_nums}=new_schedule; 
        end
        
    end
    
end

    


