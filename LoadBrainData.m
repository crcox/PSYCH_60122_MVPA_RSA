function [Brain,bySubject] = LoadBrainData(DemoDataDir)
    filename = fullfile(DemoDataDir,'92_brainRDMs.mat');
    VariablesToLoad = {
        'RDMs'
    };
    tmp = load(filename,VariablesToLoad{:});
    bySubject.RDMs = averageRDMs_subjectSession(tmp.RDMs, 'session');    
    bySubject.filename = filename;

    Brain.RDMs = averageRDMs_subjectSession(bySubject.RDMs, 'subject');
    Brain.filename = filename;
end