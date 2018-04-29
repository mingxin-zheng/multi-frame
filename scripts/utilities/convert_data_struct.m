%Cvert.m
function [u,v,res] = convert_data_struct(data,paras)
threshold = 0;
if nargin > 1
    if strcmp(paras,'xcorr')
        threshold = 0.8;
    end
end
    u = zeros(length(data),1);
    v = u;
    res = u;
    for k = 1:length(data)
        ind = data(k).res>threshold;
        if any(ind(:))
            u(k) = sum(data(k).u(ind))/sum(ind(:));
            v(k) = sum(data(k).v(ind))/sum(ind(:));
            res(k) = sum(data(k).res(ind))/sum(ind(:));
        end
    end
end