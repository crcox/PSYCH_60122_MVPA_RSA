% DEMO1_RSA_ROI_simulatedAndRealData
%
% This function computes the results in the main Figures of 
% Nili et al. (PLoS Comp Biol 2013)

addpath('rsatoolbox/Engines');
addpath('rsatoolbox/Modules');
DemoDir = fullfile('rsatoolbox','Demos');
userOptions = defineUserOptions;
outputDir = 'DEMO1';
if ~(exist(outputDir,'dir') == 7)
    mkdir(outputDir);
end
userOptions.rootPath = fullfile(pwd,'DEMO1');
userOptions.analysisName = 'DEMO1';

nitems = 92;

%% load RDMs and category definitions from Kriegeskorte et al. (Neuron 2008)
brain.filename = fullfile(DemoDir,'92imageData','Kriegeskorte_Neuron2008_supplementalData.mat');
VariablesToLoad = {
    'categoryLabels'
    'RDMs_mIT_hIT_fig1'
    'categoryVectors'
    'stimuli_92objs'
};
tmp = load(brain.filename, VariablesToLoad{:});
brain.RDMs = tmp.RDMs_mIT_hIT_fig1;
Metadata = rmfield(tmp,'RDMs_mIT_hIT_fig1');
showRDMs(brain.RDMs,1);


%% define categorical model RDMs
[binRDM_animacy, ~] = categoricalRDM(Metadata.categoryVectors(:,1),3,true);
ITemphasizedCategories=[1 2 5 6]; % animate, inanimate, face, body
[binRDM_cats, nCatCrossingsRDM]=categoricalRDM(Metadata.categoryVectors(:,ITemphasizedCategories),4,true);
handmade.filename = '';
handmade.RDMs = [
    struct('RDM',binRDM_animacy,'color',[0,0,0],'name','animacy')
    struct('RDM',binRDM_cats,'color',[0,0,0],'name','facebody_inanimate')
];

%% load behavioural RDM from Mur et al. (Frontiers Perc Sci 2013)
behaviour.filename = fullfile(DemoDir,'92imageData','92_behavRDMs.mat');
VariablesToLoad = {
    'rdms_behav_92'
};
tmp = load(behaviour.filename, VariablesToLoad{:});
disp(struct2table(tmp.rdms_behav_92));
showRDMs(tmp.rdms_behav_92)
% Average over subjects. Note that averageRDMs_subjectSession() infers how
% to group by subjects based on the ordering of RDMs in the array. The
% array must have at most 3 dimensions, and the dimensions are interpretted
% as [RDMs, Subjects, Sessions]. So, check out our structure:
disp(size(tmp.rdms_behav_92));

% This will be interpretted as containing 1 RDM for each of 16 subjects,
% which only have 1 session recorded. That is the appropriate
% interpretation, so we can go ahead and run averageRDMs_subjectSession():
behaviour.RDMs = averageRDMs_subjectSession(tmp.rdms_behav_92, 'subject');

%% load RADON and silhouette models and human early visual RDM
models.filename = cell(2,1);
models.filename{1} = fullfile(DemoDir,'92imageData','92_modelRDMs.mat');
VariablesToLoad = {
    'Models'
};
tmp = load(models.filename{1}, VariablesToLoad{:});
models.RDMs = reshape(tmp.Models([2,4,7,8]),4,1);


%% load RDMs for V1 model and HMAX model with natural image patches from Serre et al. (Computer Vision and Pattern Recognition 2005)
models.filename{2} = fullfile(DemoDir,'92imageData','rdm92_V1model.mat');
VariablesToLoad = {
    'RDMs'
    'V1modelSimMat'
    'modelSimMat_HMAXwithNatImPatchExt'
    'validConditionsLOG'
    'rdm92_V1model'
    'rdm92_HMAXnatImPatch'
};
tmp = load(models.filename{2}, VariablesToLoad{:});
models.RDMs = [
    models.RDMs
    struct('RDM',tmp.rdm92_V1model,'color',[0,0,0],'name','V1model')
    struct('RDM',tmp.rdm92_HMAXnatImPatch,'color',[0,0,0],'name','HMAXnatImPatch')
];
showRDMs(models.RDMs',5);

%% concatenate and name the modelRDMs
% place the model RDMs in cells in order to pass them to
% compareRefRDM2candRDMs as candidate RDMs
modelRDMs_cell = num2cell(models.RDMs);

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
for condI = 1:92
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
hIT_bySubjectAndSession.filename = fullfile(DemoDir,'92imageData','92_brainRDMs.mat');
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
stats_p_r=compareRefRDM2candRDMs(hIT_bySubject.RDMs, modelRDMs_cell, userOptions);
