%% DEMO4_RSAsearchlight_sim
% simulates fMRI data for a number of subjects and runs searchlight
% analysis using RSA, computes the similarity maps for each subject
% and does group level inference.

% demo of the searchlight analysis

%% SETUP
% Add RSA Toolbox components to the path. This will allow matlab to find
% the functions defined within the toolbox when we ask to use them.
addpath(fullfile('rsatoolbox','Engines'));
addpath(fullfile('rsatoolbox','Modules'));

% Some of the important Network RSA functions reference a unified set of
% "User Options". This helper-function will get us started.
userOptions = BarebonesRSASetup('DEMO4');
userOptions.betaPath = fullfile(pwd(),'demoTest','[[subjectName]]','[[betaIdentifier]]');
% Which distance measure to use when calculating first-order RDMs.
userOptions.distance = 'Correlation';

% Let's define the path to the Demo Data distributed with the RSA Toolbox.
DemoDataDir = fullfile('rsatoolbox','Demos','92imageData');
rootDir = pwd;

% Generate a simulationOptions structure.
simulationOptions = simulationOptions_demo_SL();

searchlightOptions.monitor = false;
searchlightOptions.fisher = true;
searchlightOptions.nSessions = 1;
searchlightOptions.nConditions = 40;
load([rootDir,filesep,'sampleMask_org.mat'])
load([rootDir,filesep,'anatomy.mat']);% load the resliced structural image
% models = constructModelRDMs(modelRDMs_SL_sim, userOptions);
load(fullfile('DEMO4','RDMs','DEMO4_Models.mat'),'Models');
load(fullfile('DEMO4','exampleSimulatedSubject_DesignMatrix.mat'), 'fMRI_sub');
nCond = searchlightOptions.nConditions;
Nsubjects = 20;

warpFlags.interp = 1;
warpFlags.wrap = [0 0 0];
userOptions.voxelSize = [3 3 3];
warpFlags.vox = userOptions.voxelSize; % [3 3 3.75]
warpFlags.bb = [-78 -112 -50; 78 76 85];
warpFlags.preserve = 0;
mapsFilename = [userOptions.analysisName, '_fMRISearchlight_Maps.mat'];
RDMsFilename = [userOptions.analysisName, '_fMRISearchlight_RDMs.mat'];
DetailsFilename = [userOptions.analysisName, '_fMRISearchlight_Details.mat'];

%% Second-order analysis
% Which similarity-measure is used for the second-order comparison.
userOptions.distanceMeasure = 'Spearman';

% How many permutations should be used to test the significance of the fits?  (10,000 highly recommended.)
userOptions.significanceTestPermutations = 1000; % should be 10000

% Should RDMs' entries be rank transformed into [0,1] before they're displayed?
userOptions.rankTransform = true;

% RDM Colourscheme
userOptions.colourScheme = jet(64);

% Should rubber bands be shown on the MDS plot?
userOptions.rubberbands = true;

% What criterion shoud be minimised in MDS display?
userOptions.criterion = 'metricstress';

% How should figures be outputted?
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
% 
% for subI = 1:Nsubjects
%     subject = ['subject',num2str(subI)];
%     maskName = 'mask';
%     fprintf(['simulating fullBrain volumes for subject %d \n'],subI)
%     [B_true,Mask,Y_true, fMRI_sub] = simulateClusteredfMRIData_fullBrain(simulationOptions);
%     B_noisy = fMRI_sub.B;
%     singleSubjectVols = B_noisy';
%     userOptions.searchlightRadius = 9;mask = m;
%     fprintf(['computing correlation maps for subject %d \n'],subI)
%     [rs, ps, ns, searchlightRDMs.(subject)] = searchlightMapping_fMRI(singleSubjectVols, models, mask, userOptions, searchlightOptions);
%     gotoDir(userOptions.rootPath, 'Maps');
%     save(['rs_',subject,'.mat'],'rs');
%     clear rs searchlightRDMs
%     cd(rootDir)
% end
%% display the design matrix, model RDMs and simulated RDMs and the SL
selectPlot(1);
subplot(321);imagesc(fMRI_sub.X);axis square
ylabel('\bfscans');xlabel('\bfregressors')
title('\bfdesign matrix')

subplot(322);plot(fMRI_sub.X(:,12:14))
xlabel('scans');title('\bfregressors for 3 example conditions')

subplot(323);
image(scale01(rankTransform_equalsStayEqual(squareform(pdist(fMRI_sub.groundTruth)),1)),'CDataMapping','scaled','AlphaData',~isnan(squareform(pdist(fMRI_sub.groundTruth))));
axis square off
title('\bfsimulated ground truth RDM')

subplot(324);
image(scale01(rankTransform_equalsStayEqual(Models(1).RDM,1)),'CDataMapping','scaled','AlphaData',~isnan(Models(1).RDM));
axis square off
colormap(RDMcolormap)
title('\bftested model RDM')


relRoi = sphericalRelativeRoi(userOptions.searchlightRadius,userOptions.voxelSize);
nVox_searchlight = size(relRoi,1);
showVoxObj(relRoi+repmat(simulationOptions.effectCen,[nVox_searchlight,1]),1,[3 2 5],1,struct('x','x','y','y','z','z'),[0   0.5   0.25  1 0.4])
title(['\bf searchlight with ',num2str(nVox_searchlight),' voxels'])
handleCurrentFigure([rootDir,filesep,'DEMO4',filesep,'SLsimulationSettings'],userOptions);

%% load the previously computed rMaps and concatenate across subjects
% prepare the rMaps:
for subjectI = 1:Nsubjects
    load([userOptions.rootPath,filesep,'Maps',filesep,'rs_subject',num2str(subjectI),'.mat'])
    rMaps{subjectI} = rs;
    fprintf(['loading the correlation maps for subject %d \n'],subjectI);
end
% concatenate across subjects
for modelI = 1:numel(Models)
    for subI = 1:Nsubjects
        thisRs = rMaps{subI};
        thisModelSims(:,:,:,subI) = thisRs(:,:,:,modelI);
    end
    % obtain a pMaps from applying a 1-sided signrank test and also t-test to
    % the model similarities:
    for x=1:size(thisModelSims,1)
        for y=1:size(thisModelSims,2)
            for z=1:size(thisModelSims,3)
                if mask(x,y,z) == 1
                    [h p1(x,y,z)] = ttest(squeeze(thisModelSims(x,y,z,:)),0,0.05,'right');
                    [p2(x,y,z)] = signrank_onesided(squeeze(thisModelSims(x,y,z,:)));
                else
                    p1(x,y,z) = NaN;
                    p2(x,y,z) = NaN;
                end
            end
        end
        disp(x)
    end
    % apply FDR correction
    pThrsh_t = FDRthreshold(p1,0.05,mask);
    pThrsh_sr = FDRthreshold(p2,0.05,mask);
    p_bnf = 0.05/sum(mask(:));
    % mark the suprathreshold voxels in yellow
    supraThreshMarked_t = zeros(size(p1));
    supraThreshMarked_t(p1 <= pThrsh_t) = 1;
    supraThreshMarked_sr = zeros(size(p2));
    supraThreshMarked_sr(p2 <= pThrsh_sr) = 1;
    
    % display the location where the effect was inserted (in green):
    brainVol = addRoiToVol(map2vol(anatVol),mask2roi(mask),[1 0 0],2);
    brainVol_effectLoc = addBinaryMapToVol(brainVol,Mask.*mask,[0 1 0]);
    showVol(brainVol_effectLoc,'simulated effect [green]',2);
    handleCurrentFigure([rootDir,filesep,'DEMO4',filesep,'results_DEMO4_simulatedEffectRegion'],userOptions);
    
    % display the FDR-thresholded maps on a sample anatomy (signed rank test) :
    brainVol = addRoiToVol(map2vol(anatVol),mask2roi(mask),[1 0 0],2);
    brainVol_sr = addBinaryMapToVol(brainVol,supraThreshMarked_sr.*mask,[1 1 0]);
    showVol(brainVol_sr,'signrank, E(FDR) < .05',3)
    handleCurrentFigure([rootDir,filesep,'DEMO4',filesep,'results_DEMO4_signRank'],userOptions);
    
    % display the FDR-thresholded maps on a sample anatomy (t-test) :
    brainVol = addRoiToVol(map2vol(anatVol),mask2roi(mask),[1 0 0],2);
    brainVol_t = addBinaryMapToVol(brainVol,supraThreshMarked_t.*mask,[1 1 0]);
    showVol(brainVol_t,'t-test, E(FDR) < .05',4)
    handleCurrentFigure([rootDir,filesep,'DEMO4',filesep,'results_DEMO2_tTest'],userOptions);
end
cd(rootDir);

