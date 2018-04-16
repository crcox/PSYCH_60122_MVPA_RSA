function [ p_ttest, p_signedrank] = TestAllVoxels( rMaps, SLMetadata )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% concatenate across subjects
    
    % Each cell in the input is 4-D array that is x,y,z,model for a single
    % subject. It would be more useful to have x,y,z,subject for each
    % model.
    rMaps = cat(5,rMaps{:}); % Concatenate cell contents into a 5-D array x,y,z,model,subject.
    rMaps = permute(rMaps, [1,2,3,5,4]); % permute the 4th and 5th dimensions (x,y,z,subject,model)
    [nx,ny,nz,~,nmodels] = size(rMaps);
    
    for modelI = 1:nmodels
        p_ttest = nan(nx,ny,nz);
        p_signedrank = nan(nx,ny,nz);
        for x=1:nx
            nchar = fprintf('Testing Voxels: %d%%', floor((x/nx)*100));
            for y=1:ny
                for z=1:nz
                    if SLMetadata.mask(x,y,z) == 1
                        [~, p_ttest(x,y,z)] = ttest(squeeze(rMaps(x,y,z,:,modelI)),0,0.05,'right');
                        [p_signedrank(x,y,z)] = signrank_onesided(squeeze(rMaps(x,y,z,:,modelI)));
                    end
                end
            end
            erase(nchar);
        end
    end
    fprintf('Testing Voxels: 100%%\n');
end

function erase(n)
    x = repmat('\b',1,n);
    fprintf(x);
end