function [ StackedMatrix ] = stackLowerTriangles( RDMs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if isstruct(RDMs)
        m = numel(RDMs);
        n = size(RDMs(1).RDM,1);
        StackedMatrix = preallocateStackedMatrix(m,n);
        for i = 1:m
            StackedMatrix(i,:) = squareform(RDMs(i).RDM,'tovector');
        end
    elseif isnumeric(RDMs)
        m = size(RDMs,3);
        n = size(RDMs,1);
        StackedMatrix = preallocateStackedMatrix(m,n);
        for i = 1:m
            StackedMatrix(i,:) = squareform(RDMs(:,:,i),'tovector');
        end
    end
end

function EmptyStackedMatrix = preallocateStackedMatrix(m,n)
    N = ((n.^2) - n) ./ 2;
    EmptyStackedMatrix = zeros(m,N);
end
