function [p_fdr, p_bnf] = PlotSearchlightResults( pMap, StatType, SLMetadata, userOptions, varargin )
    p = inputParser();
    addRequired(p, 'pMap',@isnumeric);
    addRequired(p, 'StatType',@ischar);
    addRequired(p, 'SLMetadata',@isstruct);
    addRequired(p, 'userOptions',@isstruct);
    addParameter(p, 'PlotSimulatedEffect', false, @islogical);
    addParameter(p, 'FigureNumber', 99, @isscalar);
    addParameter(p, 'SimFigureNumber', 100, @isscalar);
    parse(p, pMap, StatType, SLMetadata, userOptions, varargin{:});

    switch lower(StatType)
        case 'ttest'
            figurelabel = 't-test, E(FDR) < .05';
            filename = strjoin({'results',userOptions.analysisName,'tTest'},'_');
            
        case {'signrank','signedrank'}
            figurelabel = 'signrank, E(FDR) < .05';
            filename = strjoin({'results',userOptions.analysisName,'signRank'},'_');
    end
    
    % apply FDR correction
    disp(StatType);
    p_fdr = rsa.stat.FDRthreshold(pMap,0.05,SLMetadata.mask);
    p_bnf = 0.05/sum(SLMetadata.mask(:));
    % mark the suprathreshold voxels in yellow
    supraThreshMarked = zeros(size(pMap));
    supraThreshMarked(pMap <= p_fdr) = 1;

    if p.Results.PlotSimulatedEffect
        % display the location where the effect was inserted (in green):
        brainVol = rsa.fmri.addRoiToVol(rsa.util.map2vol(SLMetadata.anatVol),rsa.util.mask2roi(SLMetadata.mask),[1 0 0],2);
        brainVol_effectLoc = rsa.fmri.addBinaryMapToVol(brainVol,SLMetadata.MaskFromSimulation.*SLMetadata.mask,[0 1 0]);
        rsa.fig.showVol(brainVol_effectLoc,'simulated effect [green]',p.Results.SimFigureNumber);
        rsa.fig.handleCurrentFigure(fullfile(userOptions.rootPath,'results_DEMO4_simulatedEffectRegion'),userOptions);
    end

    % display the FDR-thresholded maps on a sample anatomy
    brainVol = rsa.fmri.addRoiToVol(rsa.util.map2vol(SLMetadata.anatVol),rsa.util.mask2roi(SLMetadata.mask),[1 0 0],2);
    brainVol_t = rsa.fmri.addBinaryMapToVol(brainVol,supraThreshMarked.*SLMetadata.mask,[1 1 0]);
    rsa.fig.showVol(brainVol_t,figurelabel,p.Results.FigureNumber)
    rsa.fig.handleCurrentFigure(fullfile(userOptions.rootPath,filename),userOptions);
    fprintf('\n');
end

