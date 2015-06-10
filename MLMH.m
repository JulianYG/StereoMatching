%Yuan Gao, Rice University

left = rgb2gray(im2double(imread('tsukuba_l.ppm')));
right = rgb2gray(im2double(imread('tsukuba_r.ppm')));
[height,width] = size(left);

occonst = 28;
padding = 4;
dMap = zeros(height,width);

leftMatrix = zeros(padding*2 + height, padding*2 + width);
rightMatrix = zeros(padding*2 + height, padding*2 + width);
leftMatrix(padding + 1:height + padding,...
    padding + 1:width + padding) = left;
rightMatrix(padding + 1:height + padding,...
    padding + 1:width + padding) = right;

c = zeros(width,width);
Dd = zeros(width,width);
Dh = zeros(width,width);
Dv = zeros(width,width);
dr = zeros(1,3);

for r = 1:1:height
    
    % Initialize the cost matrix
    for t = 1:1:width
        c(t,1) = t*occonst;
        c(1,t) = t*occonst;
    end

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
                [minV,minIdx] = min([Dd(i - 1,j - 1) ...
                    Dh(i - 1,j - 1) + 1 Dv(i - 1,j - 1) + 1]);
                Dd(i,j) = minIdx;
            else
                Dd(i,j) = Inf;
            end
            if minCost == horiCost
                [minV,minIdx] = min([Dd(i - 1,j) + 1 ...
                    Dh(i - 1,j) Dv(i - 1,j) + 1]);
                Dh(i,j) = minIdx;
            else
                Dh(i,j) = Inf;
            end
            if minCost == vertCost
                [minV,minIdx] = min([Dd(i,j - 1) + 1 ...
                    Dh(i,j - 1) + 1 Dv(i,j - 1)]);
                Dv(i,j) = minIdx;
            else
                Dv(i,j) = Inf;
            end
        end
    end

    % Initialize the cost and index counters
    [minDis,minIdx] = min([Dd(width,width) Dv(width,width) ...
        Dh(width,width)]);
    switch minIdx
        case 1
            dr(1) = 0;
            dr(2) = 1;
            dr(3) = 1;
            er = 1; fr = 1;
        case 2
            dr(1) = 1;
            dr(2) = 0;
            dr(3) = 1;
            er = 1; fr = 0;  
        case 3
            dr(1) = 1;
            dr(2) = 1;
            dr(3) = 0;
            er = 0; fr = 1;
    end

    % Reconstruct and feed values into disparity map
    lidx = width; ridx = width;
    while (lidx > 1 && ridx > 1)
        [minV,minIdx] = min([Dd(lidx - er,ridx - fr)+dr(1) ...
            Dv(lidx-er,ridx-fr)+dr(2) ...
            Dh(lidx-er,ridx-fr)+dr(3)]);
        switch minIdx
            case 1
                dMap(lidx) = abs((lidx-er)-(ridx-fr));
                dr(1) = 0; dr(2) = 1; dr(3) = 1;
                lidx = lidx - er; ridx = ridx - fr;
                er = 1; fr = 1;
            case 2
                % unmatched
                dr(1) = 1; dr(2) = 0; dr(3) = 1;
                lidx = lidx - er; ridx = ridx - fr;
                er = 1; fr = 0;
            case 3
                % unmatched
                dr(1) = 1; dr(2) = 1; dr(3) = 0;
                lidx = lidx - er; ridx = ridx - fr;
                er = 0; fr = 1;
        end
    end
end

imshow(dMap/max(dMap(:)));
colormap('jet');
