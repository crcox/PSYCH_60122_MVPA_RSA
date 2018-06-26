%% DEMO4_RSAsearchlight_sim
% simulates fMRI data for a number of subjects and runs searchlight
% analysis using RSA, computes the similarity maps for each subject
% and does group level inference.

%% SETUP
% Add RSA Toolbox components to the path. This will allow matlab to find
% the functions defined within the toolbox when we ask to use them.
rootDir = pwd();
addpath(fullfile(rootDir,'rsatoolbox-develop'));
addpath(fullfile(rootDir,'rsatoolbox-develop','DEMOS'));
addpath(fullfile(rootDir,'HelperFunctions'));
addpath(fullfile(rootDir,'Patches'));

% Some of the important Network RSA functions reference a unified set of
% "User Options". This helper-function will get us started.
userOptions = BarebonesRSASetup('DEMO_20June');
userOptions.voxelSize = [3 3 3];

% Define the path to the Demo Data distributed with the RSA Toolbox.
DemoSupplementalDataDir = fullfile(rootDir,'rsatoolbox','Demos');

% Generate a simulationOptions structure
% --------------------------------------
% I pre-ran all the data simulation and searchlights to save time. We'll
% jump in at the point of having "information maps" that can be submitted
% to statistical analysis.
simulationOptions = simulationOptions_demo_SL();

% Generate a searchlightOptions structure
% ---------------------------------------
userOptions.searchlightRadius = 9;
searchlightOptions.monitor = false;
searchlightOptions.fisher = true;
searchlightOptions.nSessions = 1;
searchlightOptions.nConditions = 40;

nii = load_nii(fullfile(userOptions.rootPath,'Nifti','brainmask.nii'));
SLMetadata.mask = nii.img > 0;

nii = load_nii(fullfile(userOptions.rootPath,'Nifti','T1.nii'));
SLMetadata.anatVol = nii.img;

Nsubjects = 20;

%% Second-order analysis
% Which similarity-measure is used for the second-order comparison.
userOptions.distanceMeasure = 'Spearman';
ReadChrisNotesAbout('userOptions.distanceMeasure');

% How many permutations should be used to test the significance of the fits?  (10,000 highly recommended.)
userOptions.significanceTestPermutations = 1000; % for the sake of time

% Should RDMs' entries be rank transformed into [0,1] before they're displayed?
userOptions.rankTransform = true;

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

%% Generate a categorical RDM
tmp = modelRDMs_SL_sim();
x = csvread(fullfile('DEMO_20June','Metadata','FeatureVectors.csv'));
tmp.features = squareform(pdist(x, 'cosine'));
x = csvread(fullfile('DEMO_20June','Metadata','Components.csv'));
tmp.components = squareform(pdist(x, 'cosine'));
Models = rsa.constructModelRDMs(tmp, userOptions);

%% display the design matrix, model RDMs and simulated RDMs and the SL
load(fullfile(userOptions.rootPath,'RDMs','DEMO_20June_Models.mat'),'Models');
load(fullfile(userOptions.rootPath,'Maps','SimulationMetadata.mat'), 'fMRI_sub');

rsa.fig.showRDMs(Models);
PlotSimulationDesign( fMRI_sub.X, fMRI_sub.groundTruth, Models(1), userOptions, simulationOptions );

%% If we were to run the searchlights, it would look something like this:
mask = SLMetadata.mask;
userOptions.searchlightRadius = 9;
for i = 1 %:Nsubjects
    fname = sprintf('beta_subject%d.nii', i);
    nii = load_nii(fullfile(userOptions.rootPath,'Nifti',fname));
    singleSubjectVols = reshape(nii.img, numel(mask), size(nii.img, 5));
    fprintf('computing correlation maps for subject %d \n', i)
    [rs, ps, ns, searchlightRDMs.(i)] = rsa.fmri.searchlightMapping_fMRI(singleSubjectVols, Models, mask, userOptions, searchlightOptions);
    %     save(['rs_',subject,'.mat'],'rs');
end

%% load the previously computed rMaps and concatenate across subjects
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