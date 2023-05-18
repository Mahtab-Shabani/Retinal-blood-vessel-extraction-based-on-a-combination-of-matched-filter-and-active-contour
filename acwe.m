function u = acwe(u0, Img,  timestep,...
                    mu, v, lambda1, lambda2, pc, ...
                    epsilon, numIter)
%Inputs:
%u0: the initial level set function.
%Img: the input gray img.
%timestep: the descenting step each time(positive real number)
%mu: the length term of equation(9) in ref[1]
%v: the area term of eq(9)
%lambda1, lambda2: the data fitting term
%pc: the penalty coefficient(used to avoid reinitialization according to [2])
%epsilon: the parameter to avoid 0 denominator
%numIter: the number of iterations
%reference:
%[1]. Active contour without edge. chan etc
%[2]. Minimizaion of region-scalable fitting energy for image segmentation.
u = u0;
for k1=1:numIter
    u = NeumannBoundCond(u);
    K = curvature_central(u);
    DrcU=(epsilon/pi)./(epsilon^2+u.^2); %eq.(9), ref[2] the delta function
    Hu=0.5*(1+(2/pi)*atan(u./epsilon));  %eq.(8)[2] the character function how large is 'epsilon'?

    th = mean(Hu(:));
    inside_idx = find(Hu(:) < th);
    outside_idx = find(Hu(:) >= th);

    c1 = mean(Img(inside_idx));
    c2 = mean(Img(outside_idx));
    
    data_force = -DrcU.*(mu*K - v - lambda1*(Img-c1).^2 + lambda2*(Img-c2).^2);
    %introduce the distance regularation term:
    P=pc*(4*del2(u) - K);               %ref[2]
    u = u+timestep*(data_force+P);
end                 %

function g = NeumannBoundCond(f)
%Neumann boundary condition
%originally written by Li chunming
%http://www.mathworks.com/matlabcentral/fileexchange/12711-level-set-for-image-segmentation
[nrow, ncol] = size(f);
g = f;
g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);  

function k = curvature_central(u)
%compute curvature:
%originally written by Li chunming
%http://www.mathworks.com/matlabcentral/fileexchange/12711-level-set-for-im
%age-segmentation
[ux, uy] = gradient(u);
normDu = sqrt(ux.^2+uy.^2+1e-10);
Nx = ux./normDu; Ny = uy./normDu;
[nxx, junk] = gradient(Nx); [junk, nyy] = gradient(Ny);
k = nxx+nyy;
% k = double(MatchFilter(u));

function k = curvature(P,h)
% computes curvature by central differences
Pxx = diff(P([1 1:end end],:),2)/h^2;
Pyy = diff(P(:,[1 1:end end])',2)'/h^2;
Px = (P(3:end,:)-P(1:end-2,:))/(2*h); Px = Px([1 1:end end],:);
Py = (P(:,3:end)-P(:,1:end-2))/(2*h); Py = Py(:,[1 1:end end]);
Pxy = (Px(:,3:end)-Px(:,1:end-2))/(2*h); Pxy = Pxy(:,[1 1:end end]);
F = (Pxx.*Py.^2-2*Px.*Py.*Pxy+Pyy.*Px.^2)./(Px.^2+Py.^2).^1.5;
F = min(max(F,-1/h),1/h);
