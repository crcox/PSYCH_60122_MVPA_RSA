function Metadata = LoadImageMetadata()
    %% load RDMs and category definitions from Kriegeskorte et al. (Neuron 2008)
    filename = fullfile(DemoDataDir,'Kriegeskorte_Neuron2008_supplementalData.mat');
    VariablesToLoad = {
        'categoryLabels'
        'categoryVectors'
        'stimuli_92objs'
    };
    tmp = load(filename, VariablesToLoad{:});
    Metadata = tmp;
    Metadata.filename = filename;
end