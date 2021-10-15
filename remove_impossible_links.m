function remove_impossible_links(u_remove,w_remove)

%%%%%%%%%%%%%%%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global c d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_remove = size(u_remove,2);
for n = 1:N_remove
    i = u_remove(n);
    j = w_remove(n);
    index= and(any(c(:,1) == i,2), any(c(:,2) == j,2));
    c(index,:)=[]; %remove
    stop=1;
end
