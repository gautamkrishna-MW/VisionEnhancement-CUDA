
function [outFrameLeft,outFrameRight,gainFactor] = visionPipeline(inputFrame, whitePatch, gainFactor)
%#codegen

coder.gpu.kernelfun;

%% Split Frame and Black Correction
[frameLeftStg1, frameRightStg1] = stg_splitFrameAndBlackCorrection(inputFrame);

%% Debayer
[frameLeftStg2, frameRightStg2] = stg_debayer(frameLeftStg1, frameRightStg1);

%% Despeckle
[frameLeftStg3, frameRightStg3] = stg_despeckle(frameLeftStg2, frameRightStg2);

%% White Balance
[frameLeftStg4, frameRightStg4] = stg_whiteBalance(frameLeftStg3, frameRightStg3, whitePatch);

%% Luma Gain
[frameLeftStg5, frameRightStg5, gainFactor] = stg_lumaGain(frameLeftStg4, frameRightStg4, gainFactor);

outFrameLeft = frameLeftStg5;
outFrameRight = frameRightStg5;

%% RGB to YCbCr
% [frameLeftStg6, frameRightStg6] = stg_rgbToYCbCrConversion(frameLeftStg5, frameRightStg5);

%% Image Sharpening
% [outFrameLeft,outFrameRight] = stg_sharpenImage(frameLeftStg6, frameRightStg6);

if isempty(coder.target)
    dispImage(frameLeftStg1, frameRightStg1, "Stage-1");
    dispImage(frameLeftStg2, frameRightStg2, "Stage-2");
    dispImage(frameLeftStg3, frameRightStg3, "Stage-3");
    dispImage(frameLeftStg4, frameRightStg4, "Stage-4");
    dispImage(frameLeftStg5, frameRightStg5, "Stage-5");
    dispImage(frameLeftStg6, frameRightStg6, "Stage-6");
    dispImage(outFrameLeft, outFrameRight, "Final Output");
end
end