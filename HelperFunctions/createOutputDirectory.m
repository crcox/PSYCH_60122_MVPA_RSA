function [] = createOutputDirectory( outputDir )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    if ~(exist(outputDir,'dir') == 7)
        mkdir(outputDir);
    end
end

