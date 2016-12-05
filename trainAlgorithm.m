function [ output_args ] = trainAlgorithm(trainDataDirArg, kernelFuncArg, boxConstraintArg )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    %The following variables are needed to allow generateSoundData() to
    %run... though it will need to be cleaned up (i.e. no global
    %variables)
    trainDataDir = trainDataDirArg;
    timeSpan = 8; %why?

    [X, t, normalization] = generateSoundData();
    dim = size(X);
    n = dim(2);
    svm = fitcsvm(X, t, 'KernelFunction', kernelFuncArg, ...
        'BoxConstraint', boxConstraintArg, 'ClassNames', [-1, 1]);
    save parameters.mat svm normalization
    
end

