function [ userOptions ] = BarebonesRSASetup( analysisName )
%BAREBONESRSASETUP The bare minimum to begin any project with RSA Toolbox
%
% Some of the important Network RSA functions reference a unified set of
% "User Options". This list of options and their default values are
% accessed using the defineUserOptions() function.
    userOptions = defineUserOptions();

% The values can then be set one by one. Two essential values that must be
% rest when beginning any project are the "rootPath" and the
% "analysisName". These govern where some of the primary functions in the
% RSA Toolbox will write figures and statistics.
% *** IMPORTANT ***
% The rootPath should be defined as an "absolute path". This means that it
% is a path that defines the position of the target directory relative to
% the root of the drive (on Windows) or filesystem (on Mac and Linux). On
% Windows, absolute paths begin with C:/ (or D:/, or E:/ ... or Z:/). On
% Mac and Linux, absolute paths start with /. 
    userOptions.rootPath = fullfile(pwd(),analysisName);
    userOptions.analysisName = analysisName;
    createOutputDirectory(userOptions.rootPath);
end

function [] = createOutputDirectory( outputDir )
%CREATEOUTPUTDIRECTORY Creates the output directory if it does not exist
%   This function simply avoids the warning associated with trying to
%   create a directory that already exists.
    if ~(exist(outputDir,'dir') == 7)
        mkdir(outputDir);
    end
end

