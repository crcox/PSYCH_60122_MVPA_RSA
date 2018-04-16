% GLOSSARY OF MATLAB FUNCTIONS

% addpath() is how you add directories to Matlab's search path. Every time
% you ask Matlab to execute a function, it looks for the definition of that
% function. It doesn't hold everything in memory all the time, but instead
% looks up how to do the things it needs to do in response to being asked.
% The search path is the list of places it will look for the instructions
% needed to fullfill your commands. This means that, in order for Matlab to
% be aware of a brand new Toolbox you download from the internet, you need
% to add the location of that Toolbox to the search path. Otherwise, Matlab
% will fail to locate the instructions it needs to execute your commands
% that are based on that new toolbox.
addpath(fullfile(pwd(),'rsatoolbox','Engines'));
addpath(fullfile(pwd(),'rsatoolbox','Modules'));

% fullfile() is a way to combine strings into a path in a platform-
% independent way. If you have worked with both Mac and PC computers, you
% may have noticed that Windows uses back-slashes and Mac uses
% forward-slashes when specifying file paths. fullfile() will use the
% appropriate syntax for whatever OS is currently running your code. Also,
% it is a convenient way to construct a file name from variables. No loops
% or string substitution required! Example:
rootdir = 'letters';
subdirectories = {'a';'b';'c'};
disp(fullfile(rootdir,subdirectories));

% pwd() is a function that returns the absolute path to your current
% working directory in a way that will work no matter what
% platform/operating system you are working on, so it is a great way to
% help build absolute paths.
% Example:
disp(pwd());

% strjoin() is a programatic way to combine a bunch of substrings into one
% long string. The substrings should be passed as a cell array. You are
% also able to specify a "delimiter", which is just the string that will be
% inserted between each of your substrings when building the big string.
% It's generally a better approach than manual string combination methods.
disp(strjoin({'a';'b';'c'},'_'));
disp(strjoin({'a';'b';'c'},','));
disp(strjoin({'a';'b';'c'},'_BRAINS_'));



