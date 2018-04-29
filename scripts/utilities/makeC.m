function C = makeC(Q)
    C = zeros(size(Q,1),2*(sum(Q(:)>0)));
    
    co = 1;
    for k = 1:size(Q,1)
        for p = 1:size(Q,2)
            if Q(k,p)>0
                C(k     ,co*2-1) = 1;
                C(Q(k,p),co*2-1) = -1;
                C(k     ,co*2) = -1;
                C(Q(k,p),co*2) = 1;
                co = co+1;
            end
        end
    end
end