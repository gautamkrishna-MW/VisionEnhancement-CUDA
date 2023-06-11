

function [outFrameLeft, outFrameRight, gainFactor] = stg_lumaGain(frameLeft, frameRight, prevGainFactor)
%#codegen

%% GPU Pragmas
coder.gpu.kernelfun;

%% Compute sizes and declaring constants
[frameRows,frameCols,~] = size(frameLeft);
numBins = 4096;

%% Compute Luminance
frameLeft = cast(frameLeft,"double");
frameRight = cast(frameRight,"double");
rightLum = uint16(round(0.2126*frameRight(:,:,1) + 0.7152*frameRight(:,:,2) + 0.0722*frameRight(:,:,3)));
leftLum = uint16(round(0.2126*frameLeft(:,:,1) + 0.7152*frameLeft(:,:,2) + 0.0722*frameLeft(:,:,3)));

%% Histogram Computation
if isempty(coder.target)
    % Simulation Code
    combinedFrame = [rightLum;leftLum];
    globalHistogram = zeros(numBins,1,"uint64");
    for pixIter = 1:numel(combinedFrame)
        globalHistogram(combinedFrame(pixIter)+1) = globalHistogram(combinedFrame(pixIter)+1) + 1;
    end
else
    % GPU Codegen: Block-wise histogram computation

    blockSize = [frameRows/2,frameCols/2];
    rowBlocks = frameRows/blockSize(1);
    colBlocks = frameCols/blockSize(2);

    % Histogram per block is stored in the local histogram matrix
    localHistogram = zeros(numBins,rowBlocks,colBlocks,"uint64");
    coder.gpu.kernel([rowBlocks,colBlocks,1],[blockSize(1),blockSize(2),1]);
    for colBlockIter = 1:blockSize(2):frameCols
        for rowBlockIter = 1:blockSize(1):frameRows
            histRow = ((rowBlockIter-1)/blockSize(1)) + 1;
            histCol = ((colBlockIter-1)/blockSize(2)) + 1;
            for colIter = 0:blockSize(2)-1
                for rowIter = 0:blockSize(1)-1
                    pixVal = rightLum(rowBlockIter + rowIter, colBlockIter + colIter);
                    localHistogram(pixVal+1,histRow,histCol) = ...
                        gpucoder.atomicAdd(localHistogram(pixVal+1,histRow,histCol),uint64(1));

                    pixVal = leftLum(rowBlockIter + rowIter, colBlockIter + colIter);
                    localHistogram(pixVal+1,histRow,histCol) = ...
                        gpucoder.atomicAdd(localHistogram(pixVal+1,histRow,histCol),uint64(1));
                end
            end
        end
    end
    
    % Local histograms are added to create the final global histogram
    globalHistogram = zeros(numBins,1,"uint64");
    coder.gpu.kernel;
    for colBlockIter = 1:colBlocks
        for rowBlockIter = 1:rowBlocks
            for pixIter = 1:numBins
                globalHistogram(pixIter) = gpucoder.atomicAdd(globalHistogram(pixIter), ...
                    localHistogram(pixIter,rowBlockIter,colBlockIter));
            end
        end
    end    
end

%% Histogram equalization

% Cumulative histogram values
integrateHist = cumsum(globalHistogram);

% Identify 90-th percentile bin and computing the smoothing factor
binVal = numBins;
numPixels = frameRows*frameCols*2;
kFactor = 0.95;
bin90Percent = 0;

% Dummy kernel invocation: This is a technique to keep the data on GPU
% while processing the loop with a single CUDA thread. This is a GPU Coder
% artifact.
coder.gpu.kernel;
for i = 1:2 % Dummy Kernel call
    while(integrateHist(binVal) > 0.9*numPixels)
        bin90Percent = binVal;
        binVal = binVal - 1;
    end
    gainFactor = prevGainFactor*(1 - kFactor) + (kFactor*bin90Percent*1000)/4095; % Use 4095 and 12-bit histogram
end

% Gain lookup table for 12-bit intensity image
pixelGainLUT = zeros(numBins,1);
tmpVal = 1024/gainFactor;
coder.gpu.kernel;
for iterVal = 0:numBins-1
    pixelGainLUT(iterVal+1) = 4096*((1-exp((-iterVal*tmpVal)/4095)) / (1 - exp(-tmpVal)));
end

% Apply gain to all pixels of present frame
outFrameLeft = coder.nullcopy(zeros(size(frameLeft),"uint16"));
outFrameRight = coder.nullcopy(zeros(size(frameRight),"uint16"));

% Note: We can do an in-place operation instead of writing the output into
% new memory locations, but this destroys the original frame data, which
% could be later used to write to disk. This can be changed to in-place
% operation if needed.

% Note2: Conditional statements (if-else) create thread divergences. To
% avoid thread divergence, we transform the following if-else code patterns
% to addition statements
% Code:
%   if (condition)
%       outValue = statement_1;
%   else
%       outValue = statement_2;
%   end
% 
% Optimization:
%   outValue = (condition == true)*statement_1 + (condition == false)*statement_2

coder.gpu.kernel;
for pixIter = 1:numel(outFrameLeft)
    pixVal = frameLeft(pixIter);
    pixVal = uint16(pixVal == 0)*1 + uint16(pixVal > 0)*pixVal;
    outFrameLeft(pixIter) = uint16(round(pixelGainLUT(pixVal)));

    outFrameLeft(pixIter) = uint16(outFrameLeft(pixIter) >= 4095)*4095 + ...
        uint16(outFrameLeft(pixIter) < 4095)*outFrameLeft(pixIter);

    pixVal = frameRight(pixIter);
    pixVal = uint16(pixVal == 0)*1 + uint16(pixVal > 0)*pixVal;
    outFrameRight(pixIter) = uint16(round(pixelGainLUT(pixVal)));

    outFrameRight(pixIter) = uint16(outFrameRight(pixIter) >= 4095)*4095 + ...
        uint16(outFrameRight(pixIter) < 4095)*outFrameRight(pixIter);
end
end