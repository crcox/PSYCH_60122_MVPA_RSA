function [ StackedMatrix ] = stackLowerTriangles( RDMs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if isstruct(RDMs)
        m = numel(RDMs);
        n = size(RDMs(1).RDM,1);
        StackedMatrix = preallocateStackedMatrix(m,n);
        z = defineLowerTriangleMask(n);
        for i = 1:m
            StackedMatrix(i,:) = RDMs(i).RDM(z);
        end
    elseif isnumeric(RDMs)
        m = size(RDMs,3);
        n = size(RDMs,1);
        StackedMatrix = preallocateStackedMatrix(m,n);
        z = defineLowerTriangleMask(n);
        for i = 1:m
            tmp = RDMs(:,:,i);
            StackedMatrix(i,:) = tmp(z);
        end
    end
end

function EmptyStackedMatrix = preallocateStackedMatrix(m,n)
    N = ((n.^2) - n) ./ 2;
    EmptyStackedMatrix = zeros(m,N);
end

function LowerTriangleMask = defineLowerTriangleMask(n)
    LowerTriangleMask = tril(true(n),-1);
end
