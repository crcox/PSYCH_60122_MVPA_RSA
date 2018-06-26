function [] = PlotSimulationDesign( DesignMatrix, GroundTruth, Model, userOptions, simulationOptions )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    rsa.fig.selectPlot(1);
    subplot(321);imagesc(DesignMatrix);axis square
    ylabel('scans','FontWeight','bold');xlabel('regressors','FontWeight','bold')
    title('design matrix','FontWeight','bold')

    subplot(322);plot(DesignMatrix(:,12:14))
    xlabel('scans');title('regressors for 3 example conditions','FontWeight','bold')

    subplot(323);
    image(rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(squareform(pdist(GroundTruth)),1)),'CDataMapping','scaled','AlphaData',~isnan(squareform(pdist(GroundTruth))));
    axis square off
    title('simulated ground truth RDM','FontWeight','bold')

    subplot(324);
    image(rsa.util.scale01(rsa.util.rankTransform_equalsStayEqual(Model.RDM,1)),'CDataMapping','scaled','AlphaData',~isnan(Model.RDM));
    axis square off
    colormap(rsa.fig.RDMcolormap())
    title('tested model RDM','FontWeight','bold')

    relRoi = rsa.fmri.sphericalRelativeRoi(userOptions.searchlightRadius,userOptions.voxelSize);
    nVox_searchlight = size(relRoi,1);
    rsa.fig.showVoxObj(relRoi+repmat(simulationOptions.effectCen,[nVox_searchlight,1]),1,[3 2 5],1,struct('x','x','y','y','z','z'),[0   0.5   0.25  1 0.4])
    title(sprintf('searchlight with %d voxels', nVox_searchlight), 'FontWeight','bold');
    rsa.fig.handleCurrentFigure(fullfile(userOptions.rootPath,'SLsimulationSettings'),userOptions);

end

