

function [outFrameLeft,outFrameRight] = stg_sharpenImage(frameLeft, frameRight)
%#codegen

%% GPU Pragmas
coder.gpu.kernelfun;

%% Gaussian filter coeff computation (Zero-mean, unit variance)
filterSize = 9;
filterVar = 1;
filterMat_9x1 = coder.const(fspecial('gaussian',[filterSize,1],sqrt(filterVar)));
filterMat_1x9 = coder.const(transpose(filterMat_9x1));

%% Apply the smoothing filter
fhVert = @(img)applyFilterVert(img,filterMat_9x1);
fhHorz = @(img)applyFilterHorz(img,filterMat_1x9);

if isempty(coder.target)
    smoothLeft = imfilter(frameLeft(:,:,1),filterMat_9x1*filterMat_1x9);
    smoothRight = imfilter(frameRight(:,:,1),filterMat_9x1*filterMat_1x9);
else
    filtOutTemp = stencilfun(fhVert,frameLeft(:,:,1),[filterSize,1], Shape = "same");
    smoothLeft = stencilfun(fhHorz,filtOutTemp,[1,filterSize], Shape = "same");

    filtOutTemp = stencilfun(fhVert,frameRight(:,:,1),[filterSize,1], Shape = "same");
    smoothRight = stencilfun(fhHorz,filtOutTemp,[1,filterSize], Shape = "same");
end

%% Sharpening the image
gammaVal = 0.5;
outFrameLeft = frameLeft;
outFrameRight = frameRight;
outFrameLeft(:,:,1) = frameLeft(:,:,1) - uint16(gammaVal*smoothLeft);
outFrameRight(:,:,1) = frameRight(:,:,1) - uint16(gammaVal*smoothRight);

end

% function outVal = applyFilterVert(img,filt)
%     outVal = img(1)*filt(1) + img(2)*filt(2) + img(3)*filt(3) + ...
%         img(4)*filt(4) + img(5)*filt(5) + img(6)*filt(6) + ...
%         img(7)*filt(7) + img(8)*filt(8) + img(9)*filt(9);
% end
% 
% function outVal = applyFilterHorz(img,filt)
% outVal = img(1)*filt(1) + img(2)*filt(2) + img(3)*filt(3) + ...
%         img(4)*filt(4) + img(5)*filt(5) + img(6)*filt(6) + ...
%         img(7)*filt(7) + img(8)*filt(8) + img(9)*filt(9);
% end

function outVal = applyFilterVert(img,filt)
    outVal = single(0);
    for i = 1:9
        outVal = outVal + single(img(i))*filt(i);
    end
end

function outVal = applyFilterHorz(img,filt)
    outVal = single(0);
    for i = 1:9
        outVal = outVal + single(img(i))*filt(i);
    end
end