function u = MatchFilter_function(Img)
cnt=uint(0);
%%% Image Acquisition
% [filename , pathname] = uigetfile({('*.jpg;*.png;*.gif;*.tif;*.bmp')},'Select a pic');
% I=imread([pathname filename]);

[s1 s2 s3]=size(Img);
% Degree of freedom if needed
free=2;
% Internal MAtched filter temps
M=0;
count=0;
% Parameters for BETA matched filter
alpha = 1;
BETHA = 1;
% Parameters for Gumbel matched filter
mu = 1;
Beta = 0.5;
% Parameters for matched filter (coushy)
Sigma=1;  %% NOTE: changed from 2 to 1.1
Length=8;   %% NOTE: changed from 9 to 7
Size=25;    %% NOTE: changed from 17 to 25
Bound=9;     %% Default: 3*Sigma
% Angle resolution for 2D matched filters
NF=36;
middle=round(Size/2);
% Creating
F=zeros(Size,Size,NF);
% GaussKernel = [7 11 20];
% GaussFilter = fspecial('Gaussian', GaussKernel(k), 12);
GaussFilter = fspecial('Gaussian', 13, 1);

%% Matched filter computing
for A=1:NF
    Ang=(A)*(pi/NF);   
    for x=-fix(Size/2):fix(Size/2)
        for y=-fix(Size/2):fix(Size/2)
            %computing new rows
            u=((x)*cos(Ang)+(y)*sin(Ang));
            v=((y)*cos(Ang)-(x)*sin(Ang));
            F(x+middle,y+middle,A)=0;
            if (u>=-Bound && u<=Bound)&&(v>-Length/2 && v<Length/2)
                count=count+1;
                % Kernel of Matched filter
%                 F(x+middle,y+middle,A)= -cauchypdf(u,0,Sigma);% -exp(-(u^2)/(2*Sigma^2));
%                 F(x+middle,y+middle,A)= -wblpdf(u,1,5);% (k/landa)((x/landa).^k-1)exp(-(x/landa).^k);
%                 F(x+middle,y+middle,A)= -raylpdf(u,0.8);% Rayleigh 0.9056 (k/landa)((x/landa).^k-1)exp(-(x/landa).^k);
%                 F(x+middle,y+middle,A)= -GaussFilter(u,1,Sigma); % Gamma
%                 F(x+middle,y+middle,A)= -evpdf(u,mu,Beta); %Gumbel
%                 F(x+middle,y+middle,A)= -gampdf(u,1,Sigma); % Gamma
%                 F(x+middle,y+middle,A)= -normal_gaussian_pdf(u,1,Sigma); % Gamma
%                 F(x+middle,y+middle,A)= -sech(u);
                F(x+middle,y+middle,A)= -gampdf(u,1,Sigma); % Gamma 0.9250
%                 F(x+middle,y+middle,A)= -betapdf(u,1,1); % Beta
%                 F(x+middle,y+middle,A)= -poisspdf(u,Sigma); % Poisson 
                M=M+F(x+middle,y+middle,A);
            end
        end
    end
    m=M/count;
    
    for x=-fix(Size/2):fix(Size/2)
        for y=-fix(Size/2):fix(Size/2)
            %computing new rows
            u=((x)*cos(Ang)+(y)*sin(Ang));
            v=((y)*cos(Ang)-(x)*sin(Ang));
            if (u>=-Bound && u<=Bound)&&(v>-Length/2 && v<Length/2)
                F(x+middle,y+middle,A)=(10*(F(x+middle,y+middle,A)-m));
            end
        end
    end
end

I = Img;
%% convolotion Match filtering and Image
for i=1:NF
    Filtered_image(:,:,i)=(conv2(I,F(:,:,i),'same'));
end
Filtered_image_Reshaped=zeros(NF,s1*s2);
A1=zeros(1,s1*s2);

for i=1:NF
    Filtered_image_Reshaped(i,:)=reshape(Filtered_image(:,:,i),1,s1*s2);
end
A1=max(Filtered_image_Reshaped);
Max=max(A1);
Min=min(A1);
IG=reshape(A1,s1,s2);

IG(:,:)=((IG(:,:)-Min)/(Max-Min))* 255;
for i=1:s1
    for j=1:s2
        IG(i,j)=(IG(i,j)+2*IG(i,j)*log(IG(i,j)));
    end
end
% imshow(IG,[]);
u    = im2uint8(mat2gray(IG));
% imshow(u,[]);
end