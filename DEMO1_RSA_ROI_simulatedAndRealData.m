% DEMO1_RSA_ROI_simulatedAndRealData
%
% This function computes the results in the main Figures of 
% Nili et al. (PLoS Comp Biol 2013)

% Please note that there is a Glossary.m file that contains explanations of
% several Matlab functions that are less obvious.

%% SETUP
% Add RSA Toolbox components to the path. This will allow matlab to find
% the functions defined within the toolbox when we ask to use them.
rootDir = pwd();
addpath(fullfile(rootDir,'rsatoolbox','Engines'));
addpath(fullfile(rootDir,'rsatoolbox','Modules'));
addpath(fullfile(rootDir,'HelperFunctions'));
addpath(fullfile(rootDir,'Patches'));

% Some of the important Network RSA functions reference a unified set of
% "User Options". This helper-function will get us started.
userOptions = BarebonesRSASetup('DEMO1');

% Let's define the path to the Demo Data distributed with the RSA Toolbox.
DemoDataDir = fullfile('rsatoolbox','Demos','92imageData');

%% LOAD DATA
Metadata = LoadImageMetadata(DemoDataDir);

[Brain,BrainBySubject] = LoadBrainData(DemoDataDir);
showRDMs(Brain.RDMs,1);
showRDMs(BrainBySubject.RDMs,2);

Handmade = BuildHandmadeData(Metadata);
showRDMs(Handmade.RDMs',3);

[Behaviour,BehaviourBySubject] = LoadBehaviourData(DemoDataDir);
disp(struct2table(BehaviourBySubject.RDMs));
showRDMs(BehaviourBySubject.RDMs,4)
showRDMs(Behaviour.RDMs,5)

Model = LoadModelData(DemoDataDir);
showRDMs(Model.RDMs',6);
% Place the model RDMs in cells in order to pass them to
% compareRefRDM2candRDMs as candidate RDMs
ModelRDMs_cell = num2cell(Model.RDMs);

%% Set Cosmetic Options for Plotting
userOptions.conditionColours = SetConditionColours(Metadata);
userOptions.blankConditionLabels = cell(1, Metadata.nitems);
[userOptions.blankConditionLabels{:}] = deal(' ');

%% Subject-averaged MDS
avgRDM = selectbyfield(Brain.RDMs,'name','hIT');
avgRDM.name = 'subject-averaged RDM';
avgRDM.color = [0 0 0];

MDSConditions(avgRDM, userOptions,struct('titleString','subject-averaged MDS',...
    'fileName','ssMDS', 'figureNumber',7));

dendrogramConditions(avgRDM, userOptions, struct( ...
    'titleString', 'Dendrogram of the subject-averaged RDM', ...
    'figureNumber', 8));

%% One-subject MDS
singleSubjectRDM = selectbyfield(BrainBySubject.RDMs,'name','hIT | BE');
singleSubjectRDM.name = 'hIT-BE';

MDSConditions(singleSubjectRDM, userOptions,struct('titleString','sample subject MDS',...
    'fileName','single-subject RDM','figureNumber',9));

%% Set 2nd Order Correlation metric
% Picking the right metric is important! It is worth revisiting how each
% correlation metric is computed.
% Pearson
% =======
% A linear correlation metric. It is the covariance between two vectors,
% normalized by the product of the standard deviation of those two vectors.
% It is sensitive to the magnitude of the differences between vectors and
% between vector elements.
%
% Spearman
% ========
% A nonlinear rank-correlation metric. Actually, it is the Pearson
% correlation after rank-transforming the elements of each vector. It is
% sensive to the order of vector elements, and larger discrepencies are
% penalized more. It is useful when the variables you are comparing may be
% on different scales.
%
% Kendall's Tau A
% ===============
% Recommended when any of the RDM's being compared to the reference RDM are
% categorical. It is the proportion of pairs of values that are
% consistently ordered in both variables. It is easiest to understand
% Kendall's Tau with and example. Check out:
%
%     StatsExamples/KendallTauExample.m
%
% In the paper published along with this RSA Toolbox, the authors discuss
% these metrics a bit.
%     https://doi.org/10.1371/journal.pcbi.1003553

% With the concepts out of the way, it comes to actually expressing your
% decision to the RSA Toolbox. Here... there is a bit of confusion. For a
% full digression, run my notes function. For now, just note that
% RDMcorrelationType and distanceMeasure are somewhat redundant, but it may
% be it may be important to set both if you are using anything other than
% 'Kendall_taua'.
userOptions.RDMcorrelationType = 'Kendall_taua';
userOptions.distanceMeasure = '';
ReadChrisNotesAbout('userOptions.distanceMeasure');

%% RDM correlation matrix and MDS
pairwiseCorrelateRDMs({avgRDM, Model.RDMs}, userOptions, struct( ...
    'figureNumber', 11, ...
    'fileName','RDMcorrelationMatrix'));

MDSRDMs({avgRDM, Model.RDMs}, userOptions, struct( ...
    'titleString', 'MDS of different RDMs', ...
    'figureNumber', 12, ...
    'fileName','2ndOrderMDSplot'));

%% Finally: the anaysis! (human IT RDM from Kriegeskorte et al. (Neuron 2008) as the reference RDM
% One of the final figures is not displaying properly with conditions
% lables! Oops. Let's strip them before we begin.
for i = 1:numel(ModelRDMs_cell)
    ModelRDMs_cell{i}.name = num2str(i);
end
% Because some of the reference RDMs are categorical, the prescription from
% Nili et al. (PLoS Comp Biol 2013) is to use 'Kendall_taua'. However, it
% should only inflate effects in the categorical cases if we use Spearman
% instead (which runs *MUCH* faster). So, I've put Spearman in here. But
% you are welcome to also try Kendall Tau A!
userOptions.RDMcorrelationType='Spearman';
% userOptions.RDMcorrelationType='Kendall_taua';

% The default test of relatedness is the (one-sided) Wilcoxon Signed Rank
% Test. Check out StatsExamples/WilcoxonExample.m
userOptions.RDMrelatednessTest = 'randomisation';
userOptions.RDMrelatednessThreshold = 0.05;
userOptions.RDMrelatednessMultipleTesting = 'none';%'FWE'
userOptions.candRDMdifferencesTest = 'conditionRFXbootstrap';
userOptions.candRDMdifferencesMultipleTesting = 'FDR';
userOptions.plotpValues = '*';
userOptions.nRandomisations = 100;
userOptions.nBootstrap = 100;
userOptions.candRDMdifferencesThreshold = 0.05;
userOptions.candRDMdifferencesMultipleTesting = 'FDR';
userOptions.figure1filename = 'compareRefRDM2candRDMs_barGraph_hITasRef';
userOptions.figure2filename = 'compareRefRDM2candRDMs_pValues_hITasRef';
userOptions.figureIndex = [13 14];
stats_p_r=compareRefRDM2candRDMs(BrainBySubject.RDMs, ModelRDMs_cell, userOptions);
