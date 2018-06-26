% Create Nifti Maps
% NOTE: This requires the nifti toolbox and my helper functions to be on
% the path.
indir = 'Maps';
outdir = 'Nifti';
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
Nsubjects = 20;

%% correlation maps
for i = 1:Nsubjects
    fprefix = sprintf('rs_subject%d', i);
    inpath = fullfile(indir, strcat(fprefix, '.mat'));
    outpath = fullfile(outdir, strcat(fprefix, '.nii'));
    tmp = load(inpath, 'rs');
    nii = SimulatedMAT2Nifti(tmp.rs);
    save_nii(nii, outpath);
end

%% betas
nii_mask = load_nii(fullfile('Nifti','brainmask.nii'));
ind = find(nii_mask.img(:) > 0);
z = nii_mask.img(:) > 0;
for i = 1:Nsubjects
    fprefix = sprintf('beta_subject%d', i);
    inpath = fullfile(indir, strcat(fprefix, '.mat'));
    outpath = fullfile(outdir, strcat(fprefix, '.nii'));
    tmp = load(inpath, 'singleSubjectVols');
    [~, hdr] = SimulatedMAT2Nifti(tmp.singleSubjectVols);
    hdr.dime.dim = [5, 64, 64, 32, 1, 40, 1, 1];
    WriteToNifti( hdr, outpath, tmp.singleSubjectVols(z,:), ind );
end