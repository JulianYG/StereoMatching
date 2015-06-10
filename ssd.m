function cost = ssd(A,B)

[row,col] = size(A);
cost = 0;
for i = 1:row
    for j = 1:col
        s = (A(i,j) - B(i,j))^2;
        cost = cost + s;
    end
end
