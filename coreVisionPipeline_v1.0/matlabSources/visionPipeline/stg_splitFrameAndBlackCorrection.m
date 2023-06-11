

function [frameLeft, frameRight] = stg_splitFrameAndBlackCorrection(inpFrame)
%#codegen

coder.gpu.kernelfun;

%% Constants:
% Rows for black correction cropping
blackCorrection = 18;
% Rows for black level estimation
blackValueEstimate = 10;

%% Compute the size of full frame
[frameRows,frameCols] = size(inpFrame);

%% Splitting the frames
frameLeftWithBlackRows = inpFrame(1:round(frameRows/2),:);
frameRightWithBlackRows = inpFrame(round(frameRows/2)+1:end,:);

%% Estimating the black value in both the frames
blackEstRowsLeft = frameLeftWithBlackRows(1:blackValueEstimate,:);
blackEstRowsRight = frameRightWithBlackRows(1:blackValueEstimate,:);

meanBlackValueLeft = mean(blackEstRowsLeft(:));
meanBlackValueRight = mean(blackEstRowsRight(:));

% Subtract mean black and remove the crop the blackCorrection rows
frameLeft = frameLeftWithBlackRows(blackCorrection+1:end,:) - meanBlackValueLeft;
frameRight = frameRightWithBlackRows(blackCorrection+1:end,:) - meanBlackValueRight;

frameLeft(frameLeft < 0) = 0;
frameRight(frameRight < 0) = 0;