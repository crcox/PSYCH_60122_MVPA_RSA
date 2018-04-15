function Model  = LoadModelData(DemoDataDir)
    %% load RADON and silhouette models and human early visual RDM
    filename = cell(2,1);
    filename{1} = fullfile(DemoDataDir,'92_modelRDMs.mat');
    VariablesToLoad = {
        'Models'
    };
    tmp = load(filename{1}, VariablesToLoad{:});
    Model.RDMs = reshape(tmp.Models([2,4,7,8]),4,1);


    %% load RDMs for V1 model and HMAX model with natural image patches from Serre et al. (Computer Vision and Pattern Recognition 2005)
    filename{2} = fullfile(DemoDataDir,'rdm92_V1model.mat');
    VariablesToLoad = {
        'RDMs'
        'V1modelSimMat'
        'modelSimMat_HMAXwithNatImPatchExt'
        'validConditionsLOG'
        'rdm92_V1model'
        'rdm92_HMAXnatImPatch'
    };
    tmp = load(filename{2}, VariablesToLoad{:});
    Model.RDMs = [
        Model.RDMs
        struct('RDM',tmp.rdm92_V1model,'color',[0,0,0],'name','V1model')
        struct('RDM',tmp.rdm92_HMAXnatImPatch,'color',[0,0,0],'name','HMAXnatImPatch')
    ];
    Model.filename = filename;
end