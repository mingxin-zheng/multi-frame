function ind = findClosest(val,array,ind_guess,window)
    len = length(array);
    switch nargin
        case 2
            x1 = 1;
            x2 = len;
        case 4
            x1 = max(1,round(ind_guess-window));
            x2 = min(len,round(ind_guess+window));
        otherwise
            error('wrong number and input arguments for findClosest.m');
    end
    
    [~,ind] = min(abs(array(x1:x2)-val));
    ind = ind + x1 - 1;
end