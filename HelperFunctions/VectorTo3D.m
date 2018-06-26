function [ X ] = VectorTo3D( hdr, x, ind )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
    X = zeros(hdr.dime.dim(2:4));
    X(ind) = x;
end

