% DEMO1_RSA_ROI_simulatedAndRealData
%
% This function computes the results in the main Figures of 
% Nili et al. (PLoS Comp Biol 2013)

% Please note that there is a Glossary.m file that contains explanations of
% several Matlab functions that are less obvious.

%% SETUP
% Add RSA Toolbox components to the path. This will allow matlab to find
% the functions defined within the toolbox when we ask to use them.
addpath(fullfile('rsatoolbox','Engines'));
addpath(fullfile('rsatoolbox','Modules'));

% Some of the important Network RSA functions reference a unified set of
% "User Options". This helper-function will get us started.
userOptions = BarebonesRSASetup('DEMO1');

% Let's define the path to the Demo Data distributed with the RSA Toolbox.
% The datasets we will be referencing involve 92 images, so let's just set
% that number into a variable for consistency and ease of reference later.
DemoDataDir = fullfile('rsatoolbox','Demos','92imageData');
nitems = 92;

%% LOAD DATA
Metadata = LoadImageMetadata(DemoDataDir);

Brain = LoadBrainData(DemoDataDir);
showRDMs(Brain.RDMs,1);

Handmade = BuildHandmadeData(Metadata);
showRDMs(Handmade.RDMs,2);

[Behaviour,BehaviourBySubject] = LoadBehaviourData(DemoDataDir);
disp(struct2table(BehaviourBySubject.RDMs));
showRDMs(BehaviourBySubject.RDMs,3)
showRDMs(Behaviour.RDMs,4)

Model = LoadModelData(DemoDataDir);
showRDMs(Model.RDMs',5);
% Place the model RDMs in cells in order to pass them to
% compareRefRDM2candRDMs as candidate RDMs
ModelRDMs_cell = num2cell(Model.RDMs);

%% activity pattern MDS
categoryIs=[5 6 7 8];
categoryCols=[0 0 0
              0 0 0
              0 0 0
              0 0 0
              1 0.5 0
              1 0 0
              0 1 0
              0 0.5 1];
          
blankConditionLabels = cell(1, nitems);
[blankConditionLabels{:}] = deal(' ');

userOptions.conditionColours = [];
userOptions.distanceMeasure = 'Spearman';
userOptions.RDMcorrelationType = 'Kendall_taua';
userOptions.conditionLabels = blankConditionLabels;
for condI = 1:nitems
    for catI = 1:numel(categoryIs)
        if Metadata.categoryVectors(condI,categoryIs(catI))
            userOptions.conditionColours(condI,:) = categoryCols(categoryIs(catI),:);
        end
    end
end
avgRDM = selectbyfield(brain.RDMs,'name','hITvisStim_316vx');
avgRDM.name = 'subject-averaged RDM';
avgRDM.color = [0 0 0];


%% subject-averaged MDS

MDSConditions(avgRDM, userOptions,struct('titleString','subject-averaged MDS',...
    'fileName','ssMDS', 'figureNumber',8));
% subject-averaged Dendrogram
dendrogramConditions(avgRDM, userOptions, struct( ...
    'titleString', 'Dendrogram of the subject-averaged RDM', ...
    'useAlternativeConditionLabels', true, ...
    'alternativeConditionLabels', ...
    {blankConditionLabels}, ...
    'figureNumber', 9));

%% one-subject MDS
hIT_bySubjectAndSession.filename = fullfile(DemoDataDir,'92_brainRDMs.mat');
VariablesToLoad = {
    'RDMs'
};
hIT_bySubjectAndSession = load(hIT_bySubjectAndSession.filename,VariablesToLoad{:});
hIT_bySubject.RDMs = averageRDMs_subjectSession(hIT_bySubjectAndSession.RDMs, 'session');

singleSubjectRDM = hIT_bySubject.RDMs(1);
singleSubjectRDM.name = 'hIT-BE';
MDSConditions(singleSubjectRDM, userOptions,struct('titleString','sample subject MDS',...
    'fileName','single-subject RDM','figureNumber',10));
% 
% % one-subject Dendrogram
% rsa.dendrogramConditions(rsa.rdm.wrapAndNameRDMs(subjectRDMs(:,:,3),{'single-subject RDM'}), userOptions,...
% struct('titleString', 'Dendrogram of a single-subject RDM', 'useAlternativeConditionLabels', true, 'alternativeConditionLabels', {blankConditionLabels}, 'figureNumber', 11));



%% RDM correlation matrix and MDS
% 2nd order correlation matrix
userOptions.RDMcorrelationType='Kendall_taua';

pairwiseCorrelateRDMs({avgRDM, models.RDMs}, userOptions, struct( ...
    'figureNumber', 12, ...
    'fileName','RDMcorrelationMatrix'));

% 2nd order MDS
MDSRDMs({avgRDM, models.RDMs}, userOptions, struct( ...
    'titleString', 'MDS of different RDMs', ...
    'figureNumber', 13, ...
    'fileName','2ndOrderMDSplot'));


%% Finally: the anaysis! (human IT RDM from Kriegeskorte et al. (Neuron 2008) as the reference RDM
% userOptions.RDMcorrelationType='Kendall_taua';
userOptions.RDMcorrelationType='Spearman';

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
userOptions.figureIndex = [16 17];
stats_p_r=compareRefRDM2candRDMs(hIT_bySubject.RDMs, ModelRDMs_cell, userOptions);
