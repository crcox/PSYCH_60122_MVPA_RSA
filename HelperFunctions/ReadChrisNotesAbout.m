function [] = ReadChrisNotesAbout(topic)
    switch topic
        case 'userOptions.distance'
            help('ReadChrisNotesAbout>userOptionsDistance');
        case 'userOptions.betaPath'
            help('ReadChrisNotesAbout>userOptionsBetaPath');
        case 'userOptions.RDMcorrelationType'
            help('ReadChrisNotesAbout>userOptionsRDMcorrelationType');
        case 'userOptions.distanceMeasure'
            help('ReadChrisNotesAbout>userOptionsRDMcorrelationType');
    end
end

function [] = userOptionsDistance() %#ok<DEFNU>
% userOptionsDistance
%
% Which distance measure to use when calculating first-order RDMs. This
% option was not relevant to DEMO1 because all the RDMs were provided. In
% DEMO4, the RDM for each searchlight will be computed on the fly based on
% the beta maps (which are in turn based on simulated fMRI data). It is
% referenced by Modules/constructRDMs(), but that function is not used by
% any of the "Engines".
%
% ** BUG ALERT ** 
% This is probably a bug in the toolbox. This option is not used by
% Engines/searchlightMapping_fMRI(). At the relevant point in the code,
% pdist(...,'correlation') is hard coded in. So whatever you assigned to
% userOptions.distance would be ignored! May as well not set this variable.
end

function [] = userOptionsBetaPath() %#ok<DEFNU>
% userOptionsBetaPath
%
% This is an important option which is not actually used in the context of
% this DEMO script because the data are simulated and not read from disk.
% BUT! In the context of a real study, you would use this option to tell
% the functions where to read your beta maps from. [[subjectName]] will be
% replaced with each of the subject codes, and [[betaIdentifier]] will be
% replaced by each of the beta identifiers passed to the
% fMRIDataPreparation() function (which is also not used in DEMO4). Of
% course, you can prepare the data yourself, and then you do not need this
% function at all, and by extension you may not need to set this variable.
% But it may be a useful convenience, especially if you did the first level
% analysis (itemwise GLM) with SPM.
end

function [] = userOptionsRDMcorrelationType()
% userOptionsRDMcorrelationType
%
% Here... there is a bit of confusion. RDMcorrelationType and
% distanceMeasure do the same thing in different places. But only
% RDMcorrelationType supports Kendall Tau A, and so may supersede
% distanceMeasure. Without a thorough analysis of the codebase, it is hard
% to say for sure.
%
% This is the risk with applying experimental, cutting-edge analyses. The
% code is experimental and cutting-edge as well! (Which means there will be
% some rough spots.) In this case, it looks like they may be in the
% middle of moving to a new set of keywords. ANYWAY. For now, it may be
% important to set both if you are using anything other than
% 'Kendall_taua'.
end