% % SubSampleEst.m (SSE)
% % Previous Names: SSDint.m Adze.m
% % Author: Mingxin(Rogge) Zheng
% % Created 12/3/2013; last modified: 12/10/2015
% % Purpose: Off-line bruteforce searching | Dec 16 Add: Increase Output
% parameters, change quadratic fitting method (from measure to correlation
% ratio)
% % Contact: zmx.pku@gmail.com 
% % rf1: template rf image that contains a rectangle (ROI). The program
% % looks for the matched region in target image - rf2, by quadratic approximation estimation 
% % Range: lateral +/- 1. vertical: +/- schv

function data = SsdEst(tpl,tar,st,kn) 

tpl = double(tpl);
tar = double(tar);

x1 = st.x1; x2 = st.x2; y1=st.y1; y2 = st.y2;

hx = kn.hx; hy = kn.hy; 
rx = kn.rx; cy = kn.cy; 
sx = kn.sx; sy = kn.sy;

u = zeros(rx,cy);
v = u;
res = u;

yStepSamples = 10;
yStep = 1/yStepSamples;

AD_schv = -1:yStep:1;

Ystack = zeros(kn.h+hx*2,kn.w+hy*2,sx*2+1,yStepSamples*2+1);
 
ref =  tpl(x1-hx:x2+hx,y1-hy:y2+hy);

for AD_uCount = 1:(yStepSamples*2+1)
    for Rs = -sx:sx
        Ad_u = AD_schv(AD_uCount);
        target = ( 1 - abs(Ad_u) ) * tar(x1-hx+Rs:x2+hx+Rs , y1-hy:y2+hy) + ...
               (Ad_u>=0)*abs(Ad_u) * tar(x1-hx+Rs:x2+hx+Rs , y1-hy+1:y2+hy+1) + ...
               (Ad_u< 0)*abs(Ad_u) * tar(x1-hx+Rs:x2+hx+Rs , y1-hy-1:y2+hy-1); 
        tmp_Ystack_pre = (target - ref).^2;
        Ystack(:,:,Rs+sx+1,AD_uCount) = imfilter(tmp_Ystack_pre,ones(2*hx+1,2*hy+1)); %sum of difference in kernel
    end
end

[locx,locy,~] = locs(kn);
mr = size(Ystack,3);
for k=1:rx
    for p=1:cy
        ix = locx(k);
        iy = locy(p);
        
        tmpY = squeeze(Ystack(ix+hx+1,iy+hy+1,:,:));
        [MINV,ind] = min(tmpY(:));

        v(k,p) = AD_schv(ceil(ind/mr));
        u(k,p) = mod(ind,mr)-sx-1;
        res(k,p) = MINV;
    end;
end;

data.u = u;
data.v = v;
data.res = res;

end

function [x,y,kn] = locs(kn)
    rx = kn.rx;
    cy = kn.cy;
    w = kn.w;
    h = kn.h;
    
    if rx>h || cy>w
        error('number of elements in rx/cy needs to be larger than h/w');
    end
    
    if rx ~= round(rx) || cy ~=round(cy)
        error('kn containts number that is not integer');
    end
    
    if rx == 1
            x = round(h/2);
            kn.hx = max(kn.hx,round(kn.h/2));
    else
            x = round(linspace(0,h-1,rx));
            kn.hx = max(kn.hx,round(mean(diff(x))/2));
    end
    
    if cy == 1
            y = round(w/2);
            kn.hy = max(kn.hy,round(kn.w/2));
    else
            y = round(linspace(0,w-1,cy));
            kn.hy = max(kn.hy,round(mean(diff(y))/2));
    end
    
end