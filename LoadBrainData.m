function Brain = LoadBrainData(DemoDataDir)
    %% load RDMs and category definitions from Kriegeskorte et al. (Neuron 2008)
    filename = fullfile(DemoDataDir,'Kriegeskorte_Neuron2008_supplementalData.mat');
    VariablesToLoad = {
        'RDMs_mIT_hIT_fig1'
    };
    tmp = load(filename, VariablesToLoad{:});
    Brain.RDMs = tmp.RDMs_mIT_hIT_fig1;
    Brain.filename = filename;
end