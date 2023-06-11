
%% Despeckle Algorithm Caller
function [frameLeft_despeckled, frameRight_despeckled] = stg_despeckle(frameLeft, frameRight)
%#codegen

if isempty(coder.target)
    frameLeft_despeckled = frameLeft;
    frameLeft_despeckled(:,:,1) = medfilt2(frameLeft(:,:,1));
    frameLeft_despeckled(:,:,2) = medfilt2(frameLeft(:,:,2));
    frameLeft_despeckled(:,:,3) = medfilt2(frameLeft(:,:,3));

    frameRight_despeckled = frameRight;
    frameRight_despeckled(:,:,1) = medfilt2(frameRight(:,:,1));
    frameRight_despeckled(:,:,2) = medfilt2(frameRight(:,:,2));
    frameRight_despeckled(:,:,3) = medfilt2(frameRight(:,:,3));

else
    % Function handle to stencil kernel
    fh = @(inpArr) medfiltKernel(inpArr);

    % Despeckle Left Frame
    frameLeft_despeckled = coder.nullcopy(frameLeft);
    frameLeft_despeckled(:,:,1) = stencilfun(fh,frameLeft(:,:,1),[3,3], Shape = 'same');
    frameLeft_despeckled(:,:,2) = stencilfun(fh,frameLeft(:,:,2),[3,3], Shape = 'same');
    frameLeft_despeckled(:,:,3) = stencilfun(fh,frameLeft(:,:,3),[3,3], Shape = 'same');

    % Despeckle Right Frame
    frameRight_despeckled = coder.nullcopy(frameRight);
    frameRight_despeckled(:,:,1) = stencilfun(fh,frameRight(:,:,1),[3,3], Shape = 'same');
    frameRight_despeckled(:,:,2) = stencilfun(fh,frameRight(:,:,2),[3,3], Shape = 'same');
    frameRight_despeckled(:,:,3) = stencilfun(fh,frameRight(:,:,3),[3,3], Shape = 'same');
end
end

%% Median filter stencil kernel implementation.
function outVal = medfiltKernel(inpArr)

midIdx = 5;
midVal = inpArr(midIdx);
sensitivityVal = 3;

% Apply median filter only when the mid-value is beyond sensitivity level.
lowerThanMidVal = 0;
higherThanMidVal = 0;
for i = 1:9
    if (i ~= midIdx)
        lowerThanMidVal = lowerThanMidVal + (inpArr(i) < midVal);
        higherThanMidVal = higherThanMidVal + (inpArr(i) >= midVal);
    end
end

if (midIdx - sensitivityVal > lowerThanMidVal+1) && (midIdx + sensitivityVal < lowerThanMidVal+1)
    outVal = inpArr(midIdx);
    return;
end

% Sort values and replace mid-value with median
for iter = 1:9
    for jter = iter+1:9
        if inpArr(jter) < inpArr(iter)
            [inpArr(jter),inpArr(iter)] = swapVal(inpArr(jter),inpArr(iter));
        end
    end
end
outVal = inpArr(midIdx);

end

% Function to swap values
function [b,a] = swapVal(a,b)
end