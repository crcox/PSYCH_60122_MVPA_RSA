% DISTRIBUTED REPRESENTATION DEMO 1
% Distributed reprepresention, or population coded content, involves
% collections of interlated pieces of information that are interpretted as
% a coherent pattern. When either the term "population code" or
% "distributed representation" are used, it usually implies that we do not
% have clear insight into what the individual pieces encode independently.
% Typically, it also implies an openness to the idea that individual pieces
% in fact cannot be interpretted out of the context of the rest of the
% pattern.
%
% How, then, are population codes to be interpretted and studied? One
% common solution is to consider the relationships among the various
% patterns. This relational structure may reveal key components of variance
% that provide insight into what is being encoded. Or, as is done in RSA,
% the relational structure encoded in a population code can be compared to
% a structure that you do understand. To the extent that they share
% structure, that is a way of explaining at least some of the structure
% that is expressed by the population code.
%
% In the following, we are going to take some known representations
% (information encoded in RGB format) and generate a "population code"
% based on that information. The objective is to show that even though it
% may not be obviously clear that the RGB features are present in the
% relationships among the distributed RGB information, the red and blue
% channels (the only two with variance in this example) can be recovered
% from the distance matrix.

%% Setup RGB codes
% These are our ground-truth color representations. Note that the green
% channel is constant. This is just to facilitate plotting our
% representations in 2 dimensions.
[r,g,b] = ndgrid(linspace(0,1,10),0.5,linspace(0,1,10));
rgb = [r(:),g(:),b(:)];

%% Plot the R and B coordinates, and color them in
scatter(r(:),b(:),2000,rgb,'s','filled')
xlim([-0.1,1.1]);
ylim([-0.1,1.1]);

%% Summarize RGB as a distance matrix
% Let's imagine 

D = pdist(rgb);

imagesc(squareform(D))
xy = cmdscale(D,2);

xy = bsxfun(@minus, xy, min(xy));
rgb_recovered = [xy(:,1)/max(xy(:,1)),repmat(0.5,100,1),xy(:,2)/max(xy(:,2))];
scatter(r(:),b(:),2000,rgb_recovered,'s','filled')
xlim([-0.1,1.1]);
ylim([-0.1,1.1]);

[coeff,score,latent] = pca(X);

subplot(1,2,1)
imagesc(X);
subplot(1,2,2)
imagesc(score);