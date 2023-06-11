
%% Function to call debayer algorithm on left and right images.
function [outFrameLeft, outFrameRight] = stg_debayer(frameLeft, frameRight)
%#codegen

coder.gpu.kernelfun;

%% Sizes and constants
bayerPattern = 'RGGB';

[frameRows,frameCols] = size(frameLeft);
singleFrame = coder.nullcopy(zeros(frameRows,frameCols*2,'like',frameLeft));
singleFrame(:,1:frameCols) = frameLeft;
singleFrame(:,frameCols+1:end) = frameRight;

if isempty(coder.target)
    outFrameLeft = demosaic(uint16(frameLeft),'gbrg');
    outFrameRight = demosaic(uint16(frameRight),'gbrg');
else
    [outFrameLeft, outFrameRight] = debayerFrame(singleFrame, bayerPattern);
end

end

%% Debayer Function
function [outFrameLeft,outFrameRight] = debayerFrame(inpFrame, bayerPattern)
%#codegen
coder.gpu.kernelfun;

stencilMat = ones(3,'single');

%% Convolve image with masks
fh = @(X)applyStencil(X,stencilMat,stencilMat,stencilMat,stencilMat,stencilMat);
[plane1,plane2,plane3,plane4,plane5] = stencilfun(fh,inpFrame,[3,3],"Shape","same");

[inpRows,inpCols] = size(inpFrame);
outFrameLeft = coder.nullcopy(zeros(inpRows,inpCols/2,3,'uint16'));
outFrameRight = coder.nullcopy(zeros(inpRows,inpCols/2,3,'uint16'));

%% Plane Ordering

% Since stencil kernel performs 
% BayerFormat = [(R-plane,G-plane,B-plane)->(Row coord, Col coord)]

switch(bayerPattern)
    % GBRG = [(5,1,4)->(1,1), (3,2,1)->(1,2); (1,2,3)->(2,1), (4,1,5)->(2,2)]
    case 'GBRG'
        for colIter = 1:2:inpCols/2
            for rowIter = 1:2:inpRows
                outFrameLeft(rowIter,colIter,:) = [plane5(rowIter,colIter),plane1(rowIter,colIter),plane4(rowIter,colIter)];
                outFrameLeft(rowIter,colIter+1,:) = [plane3(rowIter,colIter+1),plane2(rowIter,colIter+1),plane1(rowIter,colIter+1)];
                outFrameLeft(rowIter+1,colIter,:) = [plane1(rowIter+1,colIter),plane2(rowIter+1,colIter),plane3(rowIter+1,colIter)];
                outFrameLeft(rowIter+1,colIter+1,:) = [plane4(rowIter+1,colIter+1),plane1(rowIter+1,colIter+1),plane5(rowIter+1,colIter+1)];

                newColIter = inpCols/2 + colIter;
                outFrameRight(rowIter,colIter,:) = [plane5(rowIter,newColIter),plane1(rowIter,newColIter),plane4(rowIter,newColIter)];
                outFrameRight(rowIter,colIter+1,:) = [plane3(rowIter,newColIter+1),plane2(rowIter,newColIter+1),plane1(rowIter,newColIter+1)];
                outFrameRight(rowIter+1,colIter,:) = [plane1(rowIter+1,newColIter),plane2(rowIter+1,newColIter),plane3(rowIter+1,newColIter)];
                outFrameRight(rowIter+1,colIter+1,:) = [plane4(rowIter+1,newColIter+1),plane1(rowIter+1,newColIter+1),plane5(rowIter+1,newColIter+1)];
            end
        end

    % BGGR = [(3,2,1)->(1,1), (5,1,4)->(1,2); (4,1,5)->(2,1), (1,2,3)->(2,2)]
    case 'BGGR'
        % Following the BGGR bayer format
        for colIter = 1:2:inpCols/2
            for rowIter = 1:2:inpRows
                outFrameLeft(rowIter,colIter,:) = [plane3(rowIter,colIter),plane2(rowIter,colIter),plane1(rowIter,colIter)];
                outFrameLeft(rowIter,colIter+1,:) = [plane5(rowIter,colIter+1),plane1(rowIter,colIter+1),plane4(rowIter,colIter+1)];
                outFrameLeft(rowIter+1,colIter,:) = [plane4(rowIter+1,colIter),plane1(rowIter+1,colIter),plane5(rowIter+1,colIter)];
                outFrameLeft(rowIter+1,colIter+1,:) = [plane1(rowIter+1,colIter+1),plane2(rowIter+1,colIter+1),plane3(rowIter+1,colIter+1)];

                newColIter = inpCols/2 + colIter;
                outFrameRight(rowIter,colIter,:) = [plane3(rowIter,newColIter),plane2(rowIter,newColIter),plane1(rowIter,newColIter)];
                outFrameRight(rowIter,colIter+1,:) = [plane5(rowIter,newColIter+1),plane1(rowIter,newColIter+1),plane4(rowIter,newColIter+1)];
                outFrameRight(rowIter+1,colIter,:) = [plane4(rowIter+1,newColIter),plane1(rowIter+1,newColIter),plane5(rowIter+1,newColIter)];
                outFrameRight(rowIter+1,colIter+1,:) = [plane1(rowIter+1,newColIter+1),plane2(rowIter+1,newColIter+1),plane3(rowIter+1,newColIter+1)];
            end
        end

    % RGGB = [(1,2,3)->(1,1), (4,1,5)->(1,2); (5,1,4)->(2,1), (3,2,1)->(2,2)]
    case 'RGGB'
        % Following the RGGB bayer format
        for colIter = 1:2:inpCols/2
            for rowIter = 1:2:inpRows
                outFrameLeft(rowIter,colIter,:) = [plane1(rowIter,colIter),plane2(rowIter,colIter),plane3(rowIter,colIter)];
                outFrameLeft(rowIter,colIter+1,:) = [plane4(rowIter,colIter+1),plane1(rowIter,colIter+1),plane5(rowIter,colIter+1)];
                outFrameLeft(rowIter+1,colIter,:) = [plane5(rowIter+1,colIter),plane1(rowIter+1,colIter),plane4(rowIter+1,colIter)];
                outFrameLeft(rowIter+1,colIter+1,:) = [plane3(rowIter+1,colIter+1),plane2(rowIter+1,colIter+1),plane1(rowIter+1,colIter+1)];

                newColIter = inpCols/2 + colIter;
                outFrameRight(rowIter,colIter,:) = [plane1(rowIter,newColIter),plane2(rowIter,newColIter),plane3(rowIter,newColIter)];
                outFrameRight(rowIter,colIter+1,:) = [plane4(rowIter,newColIter+1),plane1(rowIter,newColIter+1),plane5(rowIter,newColIter+1)];
                outFrameRight(rowIter+1,colIter,:) = [plane5(rowIter+1,newColIter),plane1(rowIter+1,newColIter),plane4(rowIter+1,newColIter)];
                outFrameRight(rowIter+1,colIter+1,:) = [plane3(rowIter+1,newColIter+1),plane2(rowIter+1,newColIter+1),plane1(rowIter+1,newColIter+1)];
            end
        end

    % GRBG = [(4,1,5)->(1,1), (1,2,3)->(1,2); (3,2,1)->(2,1), (5,1,4)->(2,2)]
    case 'GRBG'
        % Following the GRBG bayer format
        for colIter = 1:2:inpCols/2
            for rowIter = 1:2:inpRows
                outFrameLeft(rowIter,colIter,:) = [plane4(rowIter,colIter),plane1(rowIter,colIter),plane5(rowIter,colIter)];
                outFrameLeft(rowIter,colIter+1,:) = [plane1(rowIter,colIter+1),plane2(rowIter,colIter+1),plane3(rowIter,colIter+1)];
                outFrameLeft(rowIter+1,colIter,:) = [plane3(rowIter+1,colIter),plane2(rowIter+1,colIter),plane1(rowIter+1,colIter)];
                outFrameLeft(rowIter+1,colIter+1,:) = [plane5(rowIter+1,colIter+1),plane1(rowIter+1,colIter+1),plane4(rowIter+1,colIter+1)];

                newColIter = inpCols/2 + colIter;
                outFrameRight(rowIter,colIter,:) = [plane4(rowIter,newColIter),plane1(rowIter,newColIter),plane5(rowIter,newColIter)];
                outFrameRight(rowIter,colIter+1,:) = [plane1(rowIter,newColIter+1),plane2(rowIter,newColIter+1),plane3(rowIter,newColIter+1)];
                outFrameRight(rowIter+1,colIter,:) = [plane3(rowIter+1,newColIter),plane2(rowIter+1,newColIter),plane1(rowIter+1,newColIter)];
                outFrameRight(rowIter+1,colIter+1,:) = [plane5(rowIter+1,newColIter+1),plane1(rowIter+1,newColIter+1),plane4(rowIter+1,newColIter+1)];
            end
        end
end
end

%% Stencil function
function [out1,out2,out3,out4,out5] = applyStencil(X,Mat_1,Mat_2,Mat_3,Mat_4,Mat_5)
% out1 = [0,0,0;0,1,0;0,0,0] // Center
% out2 = [0,1,0;1,0,1;0,1,0] // LRTB
% out3 = [1,0,1;0,0,0;1,0,1] // Corner
% out4 = [0,0,0;1,0,1;0,0,0] // LR
% out5 = [0,1,0;0,0,0;0,1,0] // TB

    out1 = uint16(X(2,2));
    out2 = uint16(single(X(1,2) + X(2,1) + X(2,3) + X(3,2))*0.25);
    out3 = uint16(single(X(1,1) + X(1,3) + X(3,1) + X(3,3))*0.25);
    out4 = uint16(single(X(2,1) + X(2,3))*0.5);
    out5 = uint16(single(X(1,2) + X(3,2))*0.5);
end