% Yuan Gao, Rice University
% Elec 345, Midterm, Mar 18th

close all
%clear all

tsukubaL = rgb2gray(im2double(imread('tsukuba_l.ppm')));
tsukubaR = rgb2gray(im2double(imread('tsukuba_r.ppm')));

[height,width] = size(tsukubaL);

psize = 13; % has to be odd number for convenience
padding = (psize - 1)/2;
leftMatrix = zeros(padding*2 + height, padding*2 + width);
rightMatrix = zeros(padding*2 + height, padding*2 + width);
leftMatrix(padding + 1:height + padding,...
    padding + 1:width + padding) = tsukubaL;
rightMatrix(padding + 1:height + padding,...
    padding + 1:width + padding) = tsukubaR;
% wrap up for convenience in corner cases

rowIndex = 190; columnIndex = 150;

patch = leftMatrix(rowIndex - padding:rowIndex + padding,...
    columnIndex - padding:columnIndex + padding);
cost = zeros(1,width);

for c = padding + 1: 1: padding + width
   comparePatch = rightMatrix(rowIndex - padding:rowIndex + padding,...
       c - padding:c + padding);
   cost(1,c - padding) = ssd(comparePatch, patch);
end

figure
plot(cost)
title('Candidate along 190th row');
ylabel('Cost');
xlabel('Pixel Index');

d = zeros(height,width);

% The raw d map that display unreliable results
%
% for row = padding + 1: 1: padding + height
%    for column = padding + 1: 1: padding + width
%        patch = leftMatrix(row - padding: row + padding,...
%            column - padding: column + padding);
%        for rcol = padding + 1: 1: padding + width
%            comparePatch = rightMatrix(row - padding: row + padding,...
%                rcol - padding: rcol + padding);
%            cost(1,rcol - padding) = ssd(comparePatch, patch);
%        end
%        [val,matchingCol] = min(cost);
%        d(row - padding, column - padding) = ...
%            abs(matchingCol - column + padding);
%    end
% end


% The modified d map that filters out unreliable results

 threshold = 0.2;
 numberOfAffnty = 5;
 neighborNum = 3;
% 
% for row = padding + 1: 1: padding + height
%    for column = padding + 1: 1: padding + width
%        patch = leftMatrix(row - padding: row + padding,...
%            column - padding: column + padding);
%        for rcol = padding + 1: 1: padding + width
%            comparePatch = rightMatrix(row - padding: row + padding,...
%                rcol - padding: rcol + padding);
%            cost(1,rcol - padding) = ssd(comparePatch, patch);
%        end
%        [val,ind] = min(cost);
%        neighborhood = rightMatrix(row,...
%            ind + padding - neighborNum: ind + padding + neighborNum);
%        count = 0;
%        for t = 1:neighborNum * 2 + 1
%            if abs(neighborhood(t) - val) <= threshold
%                count = count + 1;
%            end
%        end
%        if count < numberOfAffnty
%            d(row - padding, column - padding) = ...
%                 abs(ind - column + padding);
%        else
%            d(row - padding, column - padding) = 0;
%        end
%    end
% end

% The modified algorithm that interpolates undefined disparity values

for row = padding + 1: 1: padding + height
   for column = padding + 1: 1: padding + width
       patch = leftMatrix(row - padding: row + padding,...
            column - padding: column + padding);
       for rcol = padding + 1: 1: padding + width
           comparePatch = rightMatrix(row - padding: row + padding,...
               rcol - padding: rcol + padding);
           cost(1,rcol - padding) = ssd(comparePatch, patch);
       end
       [val,ind] = min(cost);
       neighborhood = rightMatrix(row,...
           ind + padding - neighborNum:ind + padding + neighborNum);
       count = 0;
       for t = 1:neighborNum * 2 + 1
           if abs(neighborhood(t) - val) <= threshold
               count = count + 1;
           end
       end
       if count < numberOfAffnty
           d(row - padding, column - padding) = ...
               abs(ind - column + padding);
       else
           if (row - padding - 1 == 0 || column - padding - 1 == 0)           
               if (row - padding - 1 == 0 && column - padding - 1 == 0)
                   d(row - padding,column - padding) = 0;
               elseif (row - padding - 1 == 0)
                   d(row - padding,column - padding) = ...
                       d(row - padding,column - padding - 1);
               else 
                   d(row - padding,column - padding) = ...
                       d(row - padding - 1, column - padding);
               end
           else
               d(row - padding,column - padding) = ...
                   (d(row - padding - 1, column - padding - 1) + ...
                   d(row - padding - 1, column - padding) + ...
                   d(row - padding, column - padding - 1))/3;
           end
       end
   end
end

p = d;
% scaling the d map for color display
p(d > 100) = 0;
p(d <= 2 & d >0) = 10;
p(d <= 5 & d > 2) = 20;
p(d <= 8 & d > 5) = 30;
p(d <= 10 & d > 8) = 40;
p(d <= 15 & d > 10) = 50;
p(d <= 20 & d > 15) = 60;
p(d <= 100 & d > 20) = 70;
imshow(p/(max(p(:))));
colormap('jet');



