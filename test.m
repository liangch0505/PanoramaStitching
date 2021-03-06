% a=[1 2 3;
%    4 5 6;
%    7 8 9];
% q=rand(3000);
% tic
% localMinImage = imerode(q, true(3));
% localMaxImage = imdilate(q, true(3));
% toc
octaves = 4;
blur_level = 5;
difference_level = 4;
img = imread('images.jpg');

img = rgb2gray(img);
img = im2double(img);
k = sqrt(2);
sigma = sqrt(2);

first_octaves = [sigma, k*sigma, (k^2)*sigma, (k^3)*sigma, (k^4)*sigma];
second_octaves = [(k^2)*sigma, (k^3)*sigma, (k^4)*sigma, (k^5)*sigma, (k^6)*sigma ];
third_octaves = [(k^4)*sigma, (k^5)*sigma, (k^6)*sigma, (k^7)*sigma, (k^8)*sigma ];
fourth_octaves = [(k^6)*sigma, (k^7)*sigma, (k^8)*sigma, (k^9)*sigma, (k^10)*sigma ];

G1 = construct_octave(blur_level,img,first_octaves); 
img2 = reduce(img);
G2 = construct_octave(blur_level,img2,second_octaves);
img3 = reduce(img2);
G3 = construct_octave(blur_level,img3, third_octaves);
img4 = reduce(img3);
G4 = construct_octave(blur_level,img4, fourth_octaves);

L1 = DoG(G1);
DoGs=L1(:,:,(1:3));
threshold=0;


maskSize=3; %mask size (square mask) for checking min/max
sigma=1; %sigma for gauss blur in point removal
r=10; % value of r for point removal
[rnum, cnum,~]=size(DoGs);


middleLayer=DoGs(:,:,2);
mask=true(maskSize);
allMax=cat(3,imdilate(DoGs(:,:,1), mask),imdilate(DoGs(:,:,2),...
    mask),imdilate(DoGs(:,:,3), mask));
allMin=cat(3,imerode(DoGs(:,:,1), mask),imerode(DoGs(:,:,2),...
    mask),imerode(DoGs(:,:,3), mask));
localMax=max(allMax,[],3);
localMin=min(allMin,[],3);
count
nonKeyPts=logical(((localMax-middleLayer)&(localMin-middleLayer)));
maxMinValues=middleLayer;
maxMinValues(nonKeyPts)=0;
%Remove points given hard threshold
fprintf('#ofPts before hard threshold: %i\n',size(find(maxMinValues),1));
maxMinValues(abs(maxMinValues)<threshold)=0;
fprintf('#ofPts after hard threshold: %i\n',size(find(maxMinValues),1));
%maxMin=~((localMax-DoG(:,:,2))|(localMin-DoG(:,:,2)));