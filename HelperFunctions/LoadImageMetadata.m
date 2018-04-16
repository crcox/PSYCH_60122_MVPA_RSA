function Metadata = LoadImageMetadata(DemoDataDir)
    %% load RDMs and category definitions from Kriegeskorte et al. (Neuron 2008)
    filename = fullfile(DemoDataDir,'Kriegeskorte_Neuron2008_supplementalData.mat');
    VariablesToLoad = {
        'categoryLabels'
        'categoryVectors'
        'stimuli_92objs'
    };
    tmp = load(filename, VariablesToLoad{:});
    Metadata = tmp;
    Metadata.nitems = numel(Metadata.stimuli_92objs);
    Metadata.filename = filename;
end