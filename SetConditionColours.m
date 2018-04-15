function [ conditionColours ] = SetConditionColours( Metadata )
    orange = [1, 0.5, 0];
    red    = [1,   0, 0];
    green  = [0,   1, 0];
    blue   = [0, 0.5, 1];
    colours = {orange;red;green;blue};
    categories = Metadata.categoryLabels(5:8);
    colourKey = cell2struct(colours, categories);
    
    conditionColours = zeros(Metadata.nitems, 3);
    
    for i = 1:numel(categories)
        C = categories{i};
        z = strcmp(Metadata.categoryLabels,C);
        categoryFilter = logical(Metadata.categoryVectors(:,z));
        n = nnz(categoryFilter);
        conditionColours(categoryFilter,:) = repmat(colourKey.(C), n, 1);
    end
end