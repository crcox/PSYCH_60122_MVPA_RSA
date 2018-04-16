% 2ND ORDER CORRELATIONS

% It may be useful to keep the following in mind: if two vetors exhibit a
% high correlation, that ignores the magnitude of the individual values.

x = randn(100,1);
y = x;

disp(corr(x,y));
disp(corr(x,y*0.001));
disp(corr(x,y*10000));

% 
x = randn(100,1);
y = x;
z = x;

ix = randperm(100,50);
r = randn(50,1);
y(ix) = r;
z(ix) = r;

disp(corr([x,y,z]));
