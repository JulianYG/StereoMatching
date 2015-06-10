%Yuan Gao, Rice University

left = rgb2gray(im2double(imread('tsukuba_l.ppm')));
right = rgb2gray(im2double(imread('tsukuba_r.ppm')));

% Trial on 'crossing cars'
%left = im2double(imread('car_l.pgm'));
%right = im2double(imread('car_r.pgm'));

% Trial on 'flying snow'
%left = im2double(imread('snow_l.pgm'));
%right = im2double(imread('snow_r.pgm'));

[height,width] = size(left);
occonst = 1.2;
dMap = zeros(height,width);
padding = 3;

% surround the image matrices with paddings for convenience
leftMatrix = zeros(padding*2 + height, padding*2 + width);
rightMatrix = zeros(padding*2 + height, padding*2 + width);
leftMatrix(padding + 1:height + padding,...
    padding + 1:width + padding) = left;
rightMatrix(padding + 1:height + padding,...
    padding + 1:width + padding) = right;
c = zeros(width,width);
M = zeros(width,width);

for r = 1:1:height
    % Initialize the cost matrix
    for t = 1:1:width
        c(t,1) = t*occonst;
        c(1,t) = t*occonst;
    end
    % Now compute the cost matrix
    for i = 2:1:width
        for j = 2:1:width
            cost = ssd(leftMatrix(r:r + 2*padding,...
                 i: i + 2*padding), rightMatrix(r: r + 2*padding,...
                        j: j + 2*padding));
            diagCost = c(i - 1,j - 1) + cost;
            vertCost = c(i,j - 1) + occonst;
            horiCost = c(i - 1,j) + occonst;
            minCost = min([horiCost vertCost diagCost]);
            c(i,j) = minCost;
            if minCost == diagCost
                M(i,j) = 1;
            end
            if minCost == horiCost
                M(i,j) = 2;
            end
            if minCost == vertCost
                M(i,j) = 3;
            end
        end
    end
    % Start tracing back
    p = width; q = width;
    while (p > 1 && q > 1)
       switch(M(p,q))
           case 1
               % Compute the disparity values
               dMap(r,p) = abs(p-q);
               p = p - 1; q = q - 1;
           case 2
               p = p - 1;
           case 3
               q = q - 1;
       end
    end
end

imshow(dMap/max(dMap(:)));
colormap('jet');
