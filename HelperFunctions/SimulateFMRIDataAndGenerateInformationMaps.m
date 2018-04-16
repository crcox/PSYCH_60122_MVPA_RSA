function [ ] = SimulateFMRIDataAndGenerateInformationMaps( nsubjects, models, mask, simulationOptions, searchlightOptions, userOptions )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    MapsDir = fullfile(userOptions.rootPath,'Maps');
    createOutputDirectory(MapsDir);
    for subI = 1:nsubjects
        fprintf('simulating fullBrain volumes for subject %d \n',subI)
        [~,MaskFromSimulation,~, fMRI_sub] = ...
            simulateClusteredfMRIData_fullBrain(simulationOptions); %#ok<ASGLU>
        fprintf('\n');
        B_noisy = fMRI_sub.B;
        singleSubjectVols = B_noisy';
        fprintf('computing correlation maps for subject %d \n',subI)
        rs = searchlightMapping_fMRI( ...
            singleSubjectVols, ...
            models, ...
            mask, ...
            userOptions, ...
            searchlightOptions); %#ok<NASGU>
        fprintf('\n');
        save(fullfile(MapsDir,sprintf('rs_subject%d.mat',subI)),'rs');
    end
    fMRI_sub.B = [];
    fMRI_sub.Y = [];
    save(fullfile(MapsDir,'SimulationMetadata.mat'), ...
        'MaskFromSimulation','fMRI_sub', ...
        'simulationOptions','searchlightOptions','userOptions');
end

