

function [outFrameLeft, outFrameRight] = stg_rgbToYCbCrConversion(frameLeft, frameRight)
%#codegen

coder.gpu.kernelfun;

outFrameLeft = coder.nullcopy(frameLeft);
outFrameRight = coder.nullcopy(frameRight);

[frameRows,frameCols,~] = size(outFrameRight);

if isempty(coder.target)
    outFrameLeft = rgb2ycbcr(frameLeft);
    outFrameRight = rgb2ycbcr(frameRight);
else
    coder.gpu.kernel;
    for colIter = 1:frameCols
        for rowIter = 1:frameRows
            % Left
            pixRGB_uint16 = frameLeft(rowIter,colIter,:);
            pixRGB = double(pixRGB_uint16);
            
            pixVal = uint16( 0.2126*pixRGB(1) + 0.7152*pixRGB(2) + 0.0722*pixRGB(3));
            outFrameLeft(rowIter,colIter,1) = uint16(pixVal < 4095)*pixVal + uint16(pixVal >= 4095)*uint16(4095);
            
            pixVal = uint16(-0.1146*pixRGB(1) - 0.3854*pixRGB(2) + 0.5000*pixRGB(3) + 2048);
            outFrameLeft(rowIter,colIter,2) = uint16(pixVal < 4095)*pixVal + uint16(pixVal >= 4095)*uint16(4095);
            
            pixVal = uint16( 0.5000*pixRGB(1) - 0.4542*pixRGB(2) - 0.0458*pixRGB(3) + 2048);
            outFrameLeft(rowIter,colIter,3) = uint16(pixVal < 4095)*pixVal + uint16(pixVal >= 4095)*uint16(4095);

            % Right
            pixRGB_uint16 = frameRight(rowIter,colIter,:);
            pixRGB = double(pixRGB_uint16);

            pixVal = uint16( 0.2126*pixRGB(1) + 0.7152*pixRGB(2) + 0.0722*pixRGB(3));
            outFrameRight(rowIter,colIter,1) = uint16(pixVal < 4095)*pixVal + uint16(pixVal >= 4095)*uint16(4095);
            
            pixVal = uint16(-0.1146*pixRGB(1) - 0.3854*pixRGB(2) + 0.5000*pixRGB(3) + 2048);
            outFrameRight(rowIter,colIter,2) = uint16(pixVal < 4095)*pixVal + uint16(pixVal >= 4095)*uint16(4095);
            
            pixVal = uint16( 0.5000*pixRGB(1) - 0.4542*pixRGB(2) - 0.0458*pixRGB(3) + 2048);
            outFrameRight(rowIter,colIter,3) = uint16(pixVal < 4095)*pixVal + uint16(pixVal >= 4095)*uint16(4095);
        end
    end
end
% Self Note: Try converting this to a matrix multiplication problem through
% GPU coder is having it's limitiations as of now. Will have to improvise
% once the issues are fixed.
end