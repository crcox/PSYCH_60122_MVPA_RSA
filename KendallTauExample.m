% KENDALL'S TAU EXAMPLE
% We will compute the Tau between vectors of rank-transformed data.

% Preparation
% -----------
% ix = randperm(10);
% T = table([1:10]',[2,1,4,3,6,5,8,7,10,9]',zeros(10,1),zeros(10,1), ...
%     'VariableNames',{'x','y','Concordant','Discordant'});
% T = T(ix,:);
% save('KendallExample.mat','T');
%
% This example is based on the one used by How2Stats.com on YouTube. Kind
% of a crappy video, but it held my hand enough so that I could
% understand... https://youtu.be/oXVxaSoY94k

%% Step 0: Load the example data.
load('KendallExample.mat', 'T');
disp(T);

%% Step 1: Sort by one of the two variables
T = sortrows(T,'x');
disp(T);

%% Step 2: Compute the number of Concordant pairs.
% Starting in the first row of the 'y' column, count the number of ranks
% further down in the column that are higher than the current rank value.
%
% The first y value is 2, and there are 10 total elements in the 'y'
% column. Out of the 9 remaining values, 8 are larger than 2. So the number
% of concordant pairs at the first row is 8.
%
% We simply repeat this logic, marching down the 'y' column.
% Programmatically:
for i = 1:10
    currentValue = T.y(i);
    remainingValues = T.y((i+1):10);
    C = sum(remainingValues > currentValue);
    T.Concordant(i) = C;
end
disp(T);

%% Step 3: Compute the number of Discordant pairs.
% Starting in the first row of the 'y' column, count the number of ranks
% further down in the column that are LOWER than the current rank value.
%
% The first y value is 2, and there are 10 total elements in the 'y'
% column. Out of the 9 remaining values, only 1 is smaller than 2. So the
% number of discordant pairs at the first row is 1.
%
% We simply repeat this logic, marching down the 'y' column.
% Programmatically:
for i = 1:10
    currentValue = T.y(i);
    remainingValues = T.y((i+1):10);
    D = sum(remainingValues < currentValue);
    T.Discordant(i) = D;
end
disp(T);

%% Step 4: Compute Kendall's Tau using the Concordant and Discordant counts
Ktau = (sum(T.Concordant) - sum(T.Discordant)) ./ (sum(T.Concordant) + sum(T.Discordant));
disp(Ktau);

%% Step 5: Check our work!
Ktau_check = corr(T.x,T.y,'type','Kendall');
disp(Ktau_check);

%% Extra Credit: Spearman correlation
% The Spearman correlation for these same vectors is notably higher.
rs = corr(T.x,T.y,'type','Spearman');
disp(rs);

% This highlights a difference in emphasis between the two methods. Because
% all of the mistakes are small (the rank error is just 1 in all cases),
% the Spearman correlaiton is quite high. Kendall's Tau is a little more
% severe, because it penalizes for things not being exactly right, despite
% being close. Here's another example:

TT = table((1:10)', [10,2:9,1]','VariableNames',{'x','y'});
disp(TT);

r = struct(...
    'Spearman', corr(TT.x,TT.y,'type','Spearman'), ...
    'Kendall', corr(TT.x,TT.y,'type','Kendall'));
disp(r);

% In this case, Spearman reports a much lower correlation than Kendall.
% This is because, even though there is only 1 mistake, it is a GIANT
% mistake. Kendall on the other hand deemphasizes the severity of that
% single error.
