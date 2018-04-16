% WILCOXON SIGNED RANK TEST EXAMPLE

%% Setup
x = [
    125	110
    135	122
    130	125
    140	120
    140	140
    115	124
    140	123
    135	137
    140	135
    145	145
];
zz = zeros(10,1);
T = table((1:10)', x(:,1), x(:,2), zz, zz, zz, zz, zz, ...
    'VariableName',{'id','x','y','diff','sign','absdiff','rank','signed_rank'});

%% Compute the difference between x and y
T.diff = T.x - T.y;

%% Identify the sign of the difference.
T.sign = sign(T.diff);

%% Sort by the magnitude of the difference
T.absdiff = abs(T.diff);
T = sortrows(T,'absdiff');

%% Rank the absolute differences
% If there are ties, take the mean of the rank positions being spanned. So,
% if there is a tie for Rank 1 among 2 differences, then take the average
% of 1 and 2 and assigned 1.5 to both.
% Rows with absolute difference == 0 are excluded and not ranked!
z = T.absdiff > 0;
n = nnz(z);
T.rank(z) = 1:n;
tab = tabulate(T.absdiff(z));
ties = find(tab(:,2) > 1);
for i = 1:numel(ties)
    t = ties(i);
    z = T.absdiff == t;
    T.rank(z) = mean(T.rank(z));
end

%% Compute the signed rank (multiply rank and sign)
T.signed_rank = T.rank .* T.sign;

%% Compute the sum of signed ranks
W = sum(T.signed_rank(T.sign>0));
disp(W);

% After all this we find that our Wilcoxon Signed Rank statistic is W = 31.
%
% Let's confirm that we got the right test statistic, and let Matlab
% evalute it for us.
[p,h,stats] = signrank(T.x,T.y);
disp(struct('pval',p, 'rejectNull', h, 'signedrank', stats.signedrank));

% By a two-tailed test, we fail to reject the null hypothesis... but we got
% the test statistic correct!

% In the RSA Toolbox, they actually compute 1-tailed tests because they
% only care about differences in one direction. To get the 1-tailed p, just
% divide by two:
disp(p / 2);

% Of course, you need to make decisions about your statistical procedure
% BEFORE you start running tests. ;)
