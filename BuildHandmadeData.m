function Handmade = BuildHandmadeData(Metadata)
    %% define categorical model RDMs
    [binRDM_animacy, ~] = categoricalRDM(Metadata.categoryVectors(:,1),3,true);
    ITemphasizedCategories=[1 2 5 6]; % animate, inanimate, face, body
    [binRDM_cats, nCatCrossingsRDM]=categoricalRDM(Metadata.categoryVectors(:,ITemphasizedCategories),4,true);
    Handmade.RDMs = [
        struct('RDM',binRDM_animacy,'color',[0,0,0],'name','animacy')
        struct('RDM',binRDM_cats,'color',[0,0,0],'name','facebody_inanimate')
    ];
    Handmade.filename = '';
end