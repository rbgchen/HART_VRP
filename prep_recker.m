function [c,t,demand]=prep_recker

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d solution num_tours present_n_tour dload_matrix
global HOME_EARLY HOME_LATE ACT_EARLY ACT_LATE n V HM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=3; %(Number of Activities)
V=2; %(Number of Vehicles)
HM=2; %(Number of HH members) %C4

%%%%%%%%%%%%%%%%%%%%%%% Activity Node Sets %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PP = 1:n;
PN = n+1:2*n;
P  = [PP,PN];

%%%%%%%%%%%%%%%%%%%%%%% Construct Objective Function %%%%%%%%%%%%%%%%%%%%%%
%travel time matrix
t_matrix=[0,1,0.25,0.5;1,0,1,0.5;0.25,1,0,0.5;0.5,0.5,0.5,0];

%travel cost matrix
c_matrix=[0,0,2,1;2,0,1,1;1,1,0,0.5;1,1,0.5,0];

%Construct Objective Function

%start with X
c_ul=c_matrix;
%c_ul(1,PP+1)=c_ul(1,PP+1)+100;
c_ul(1,PP+1)=c_ul(1,PP+1);
c_ll=repmat(c_matrix(1,:),n+1,1);
c_lr=zeros(n+1,n+1);

%this is to test 
%hc=50; %high cost
%c_lr(2,1)=hc;
%c_lr(3,1:2)=hc;

%c_ur=[repmat(c_matrix(:,1),1,n),zeros(n+1,1)];
c_ur=[repmat(c_matrix(:,1),1,n+1)];
c=[c_ul,c_ur;c_ll,c_lr];

%create t matrix for drop off nodes too
t_ul=t_matrix;
t_ll=repmat(t_matrix(1,:),n+1,1);
t_lr=zeros(n+1,n+1);

%t_ur=[repmat(t_matrix(:,1),1,n),zeros(n+1,1)];
%I changed this to make travel times to home from out-of-home-activities
%non-zero
t_ur=[repmat(t_matrix(:,1),1,n),t_ul(:,1)];

t=[t_ul,t_ur;t_ll,t_lr];


%demand at nodes
demand=[0;1;1;1;...
        zeros(4,1)];
