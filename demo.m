[filename , pathname] = uigetfile({('*.jpg;*.png;*.gif;*.tif;*.bmp')},'Select a pic');
I=imread([pathname filename]);
tic
I = I(:,:,2);
% I = imadjust(I);
I = adapthisteq(I); % CLHAE
Img=double(I);
% Img = medfilt2(Img, [3, 3]);
%% mask and manual
name = filename(1:3);
% path = pathname;
fnd = findstr(pathname,'test');
if isempty(fnd)
    imgman=imread(strcat('DRIVE\trn\1st_manual\',name,'manual1.gif'));
    imgmsk=imread(strcat('DRIVE\trn\mask\',name,'training_mask.gif'));
else
    imgman=imread(strcat('DRIVE\test\1st_manual\',name,'manual1.gif'));
    imgmsk=imread(strcat('DRIVE\test\mask\',name,'test_mask.gif'));
end

manu=imgman;
mask=imgmsk;
Omask=mask;

%% crop image
Img = MatchFilter_function(Img);

%% % % % % % % % 
Img = double(Img(:, :, 1));
%apply median filter to denoise
Img = medfilt2(Img, [3, 3]);

%% setting the initial level set function 'u':
u = initialcurve(Img,'gradient');

%% setting the parameters in ACWE algorithm:
mu=1;
lambda1=.75; lambda2=.7;
timestep = .001; v=1; epsilon=.6;
iterNum=70;
%show the initial 0-level-set contour:
figure;imshow(Img, []);hold on;axis off,axis equal
title('Initial contour');
[c,h] = contour(u,[0 0],'r');
pause(0.1);
% start level set evolution
for n=1:iterNum
    u=acwe(u, Img,  timestep,...
             mu, v, lambda1, lambda2, 1, epsilon, 1);
    if mod(n,10)==0
        pause(0.1);
        imshow(Img, []);hold on;axis off,axis equal
        [c,h] = contour(u,[0 0],'r');
        iterNum=[num2str(n), ' iterations'];
        title(iterNum);
        hold off;
    end
end
imshow(Img, []);hold on;axis off,axis equal
[c,h] = contour(u,[0 0],'r');
totalIterNum=[num2str(n), ' iterations'];
title(['Final contour, ', totalIterNum]);

edit = im2uint8(mat2gray(u));
% edit = u;
figure;
% imagesc(u);axis off,axis equal;
subplot(1, 2,1), imshow(edit,[]);title('Final level set function');
subplot(1, 2,2), imshow(manu);title('Manual extraction');
toc

figure;
computAUC
