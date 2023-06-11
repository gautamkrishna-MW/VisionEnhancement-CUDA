

function [frameLeft, frameRight] = stg_whiteBalance(frameLeft,frameRight,bayerPatch)
%#codegen

coder.gpu.kernelfun;

% Compute the mean of RGB channels in the bayer patch
numPixels = numel(bayerPatch);
[numRows,numCols] = size(bayerPatch);

rMat = coder.nullcopy(zeros(numRows/2,numCols/2,'single'));
gMat = coder.nullcopy(zeros(numRows/2,numCols/2,'single'));
bMat = coder.nullcopy(zeros(numRows/2,numCols/2,'single'));

coder.gpu.kernel;
for colIter = 1:2:size(bayerPatch,2)
    coder.gpu.kernel;
    for rowIter = 1:2:size(bayerPatch,1)
        newRIter = floor(rowIter/2)+1;
        newCIter = floor(colIter/2)+1;
        
        rMat(newCIter,newRIter) = bayerPatch(rowIter,colIter);
        bMat(newCIter,newRIter) = bayerPatch(rowIter+1,colIter+1);
        gMat(newCIter,newRIter) = bayerPatch(rowIter,colIter+1) + bayerPatch(rowIter+1,colIter);
    end
end

meanRChannel = gpucoder.reduce(rMat,@computeSum)/numPixels;
meanGChannel = 1.2*gpucoder.reduce(gMat,@computeSum)/numPixels;
meanBChannel = gpucoder.reduce(bMat,@computeSum)/numPixels;

% Create dummy kernel to keep the data on GPU
coder.gpu.kernel;
for i = 1:2
    maxVal = max(meanRChannel,max(meanGChannel,meanBChannel));
    gainRChannel = maxVal/meanRChannel;
    gainGChannel = maxVal/meanGChannel;
    gainBChannel = maxVal/meanBChannel;
end

[imgRows,imgCols,~] = size(frameLeft);
max12Bit = single(2^12 - 1);

coder.gpu.kernel;
for colIter = 1:imgCols
    for rowIter = 1:imgRows
        % Frame left
        pixVal = single(frameLeft(rowIter,colIter,1)).*gainRChannel;
        pixVal = single(pixVal >= max12Bit)*max12Bit + single(pixVal < max12Bit)*pixVal;
        frameLeft(rowIter,colIter,1) = uint16(pixVal);

        pixVal = single(frameLeft(rowIter,colIter,2)).*gainGChannel;
        pixVal = single(pixVal >= max12Bit)*max12Bit + single(pixVal < max12Bit)*pixVal;
        frameLeft(rowIter,colIter,2) = uint16(pixVal);

        pixVal = single(frameLeft(rowIter,colIter,3)).*gainBChannel;
        pixVal = single(pixVal >= max12Bit)*max12Bit + single(pixVal < max12Bit)*pixVal;
        frameLeft(rowIter,colIter,3) = uint16(pixVal);

        % Frame right
        pixVal = single(frameRight(rowIter,colIter,1)).*gainRChannel;
        pixVal = single(pixVal >= max12Bit)*max12Bit + single(pixVal < max12Bit)*pixVal;
        frameRight(rowIter,colIter,1) = uint16(pixVal);

        pixVal = single(frameRight(rowIter,colIter,2)).*gainGChannel;
        pixVal = single(pixVal >= max12Bit)*max12Bit + single(pixVal < max12Bit)*pixVal;
        frameRight(rowIter,colIter,2) = uint16(pixVal);

        pixVal = single(frameRight(rowIter,colIter,3)).*gainBChannel;
        pixVal = single(pixVal >= max12Bit)*max12Bit + single(pixVal < max12Bit)*pixVal;
        frameRight(rowIter,colIter,3) = uint16(pixVal);
    end
end

end

function c = computeSum(a,b)
    c = a+b;
end