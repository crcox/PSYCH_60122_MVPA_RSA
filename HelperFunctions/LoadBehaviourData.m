function [Behaviour,bySubject] = LoadBehaviourData(DemoDataDir)
    %% load behavioural RDM from Mur et al. (Frontiers Perc Sci 2013)
    filename = fullfile(DemoDataDir,'92_behavRDMs.mat');
    VariablesToLoad = {
        'rdms_behav_92'
    };
    tmp = load(filename, VariablesToLoad{:});
    bySubject.RDMs = tmp.rdms_behav_92;
    bySubject.filename = filename;
    
    % Average over subjects. Note that averageRDMs_subjectSession() infers how
    % to group by subjects based on the ordering of RDMs in the array. The
    % array must have at most 3 dimensions, and the dimensions are interpretted
    % as [RDMs, Subjects, Sessions]. So, check out our structure:
    
    % disp(size(tmp.rdms_behav_92));

    % This will be interpretted as containing 1 RDM for each of 16 subjects,
    % which only have 1 session recorded. That is the appropriate
    % interpretation, so we can go ahead and run averageRDMs_subjectSession():
    Behaviour.RDMs = averageRDMs_subjectSession(tmp.rdms_behav_92, 'subject');
    Behaviour.filename = filename;
end