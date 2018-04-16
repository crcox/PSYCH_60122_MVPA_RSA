%% DEMO4_RSAsearchlight_sim
% simulates fMRI data for a number of subjects and runs searchlight
% analysis using RSA, computes the similarity maps for each subject
% and does group level inference.

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
userOptions = BarebonesRSASetup('DEMO4');
userOptions.voxelSize = [3 3 3];

% userOptions.betaPath = fullfile(rootDir,'demoTest','[[subjectName]]','[[betaIdentifier]]');
ReadChrisNotesAbout('userOptions.betaPath');

% userOptions.distance = 'correlation';
ReadChrisNotesAbout('userOptions.distance');

% Define the path to the Demo Data distributed with the RSA Toolbox.
DemoDataDir = fullfile(rootDir,'rsatoolbox','Demos','92imageData');
DemoSupplementalDataDir = fullfile(rootDir,'rsatoolbox','Demos');


% Generate a simulationOptions structure
% --------------------------------------
% I pre-ran all the data simulation and searchlights to save time. We'll
% jump in at the point of having "information maps" that can be submitted
% to statistical analysis.
simulationOptions = simulationOptions_demo_SL();

% Generate a searchlightOptions structure
% ---------------------------------------
% I pre-ran all the data simulation and searchlights to save time. We'll
% jump in at the point of having "information maps" that can be submitted
% to statistical analysis.
userOptions.searchlightRadius = 9;
searchlightOptions.monitor = false;
searchlightOptions.fisher = true;
searchlightOptions.nSessions = 1;
searchlightOptions.nConditions = 40;
tmp = load(fullfile(DemoSupplementalDataDir,'sampleMask_org.mat'), 'm');
SLMetadata.mask = tmp.m;
tmp = load(fullfile(DemoSupplementalDataDir,'anatomy.mat'), 'anatVol');
SLMetadata.anatVol = tmp.anatVol;
Nsubjects = 20;

% Generate a warpFlags structure
% ---------------------------------------
% I pre-ran all the data simulation and searchlights to save time. We'll
% jump in at the point of having "information maps" that can be submitted
% to statistical analysis.
warpFlags.interp = 1;
warpFlags.wrap = [0 0 0];
warpFlags.vox = userOptions.voxelSize; % [3 3 3.75]
warpFlags.bb = [-78 -112 -50; 78 76 85];
warpFlags.preserve = 0;

% Set paths for output files that help document the analysis
% ----------------------------------------------------------
mapsFilename = strjoin({userOptions.analysisName, 'fMRISearchlight_Maps.mat'}, '_');
RDMsFilename = strjoin({userOptions.analysisName, 'fMRISearchlight_RDMs.mat'}, '_');
DetailsFilename = strjoin({userOptions.analysisName, 'fMRISearchlight_Details.mat'}, '_');

%% Second-order analysis
% Which similarity-measure is used for the second-order comparison.
userOptions.distanceMeasure = 'Spearman';
ReadChrisNotesAbout('userOptions.distanceMeasure');

% How many permutations should be used to test the significance of the fits?  (10,000 highly recommended.)
userOptions.significanceTestPermutations = 1000; % should be 10000

% Should RDMs' entries be rank transformed into [0,1] before they're displayed?
userOptions.rankTransform = true;

% RDM Colourscheme
% userOptions.colourScheme = jet(64);
% 
% % Should rubber bands be shown on the MDS plot?
% userOptions.rubberbands = true;
% 
% % What criterion shoud be minimised in MDS display?
% userOptions.criterion = 'metricstress';

% How should figures be output?
userOptions.displayFigures = true;
userOptions.saveFiguresPDF = true;
userOptions.saveFiguresFig = false;
userOptions.saveFiguresPS = false;
userOptions.saveFiguresEps = false;

% Bootstrap options
userOptions.nResamplings = 1000;
userOptions.resampleSubjects = true;
userOptions.resampleConditions = true;

userOptions.RDMname = 'referenceRDM';
userOptions.plottingStyle = 2;

%% simulate the data and compute the correlation maps per subject
% % Takes about 15 minutes to run ...
% t = tic();
% Models = constructModelRDMs(modelRDMs_SL_sim(), userOptions);
% SimulateFMRIDataAndGenerateInformationMaps( ...
%     Nsubjects, ...
%     Models, ...
%     SLMetadata.mask, ...
%     simulationOptions, ...
%     searchlightOptions, ...
%     userOptions);
% 
% TimeToSimulateAndMap = toc(t);

%% display the design matrix, model RDMs and simulated RDMs and the SL
load(fullfile(userOptions.rootPath,'RDMs','DEMO4_Models.mat'),'Models');
load(fullfile(userOptions.rootPath,'Maps','SimulationMetadata.mat'), 'fMRI_sub');

PlotSimulationDesign( fMRI_sub.X, fMRI_sub.groundTruth, Models(1), userOptions, simulationOptions );

%% load the previously computed rMaps and concatenate across subjects
% prepare the rMaps:
rMaps = cell(Nsubjects,1);
for subjectI = 1:Nsubjects
    load(fullfile(userOptions.rootPath,'Maps',sprintf('rs_subject%d.mat',subjectI)))
    rMaps{subjectI} = rs;
    fprintf('loading the correlation maps for subject %d\n',subjectI);
end

%% Run statistical tests at each voxel
[pMap_ttest, pMap_signrank] = TestAllVoxels(rMaps,SLMetadata);

%% Plot solutions
load(fullfile(userOptions.rootPath,'Maps','SimulationMetadata.mat'), 'MaskFromSimulation');
SLMetadata.MaskFromSimulation = MaskFromSimulation;

PlotSearchlightResults( pMap_ttest, 'ttest', SLMetadata, userOptions, 'PlotSimulatedEffect', true, 'SimFigureNumber',2, 'FigureNumber',3);
PlotSearchlightResults( pMap_signrank, 'signedrank', SLMetadata, userOptions, 'PlotSimulatedEffect', false,'FigureNumber',4 );