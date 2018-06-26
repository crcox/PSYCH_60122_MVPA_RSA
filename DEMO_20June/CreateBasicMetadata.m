% Setup Basic Metadata
% NOTE: This requires the nifti toolbox and my helper functions to be on
% the path.
indir = 'Maps';
outdir = 'Metadata';
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

SimulationMetadata = load(fullfile(indir, 'SimulationMetadata.mat'));
nii = SimulatedMAT2Nifti(SimulationMetadata.MaskFromSimulation, 1);
save_nii(nii, fullfile(outdir, 'LocationOfSimulatedEffect.nii'));
csvwrite(fullfile(outdir,'FeatureVectors.csv'), SimulationMetadata.fMRI_sub.groundTruth);

[U,S,~] = svd(cov(SimulationMetadata.fMRI_sub.groundTruth'));
stem(diag(S));
csvwrite(fullfile(outdir,'Components.csv'), U(:,1:4));