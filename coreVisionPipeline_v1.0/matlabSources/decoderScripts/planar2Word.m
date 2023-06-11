
function outFrames = planar2Word(planarFrames,imgWidth, imgHeight)

numFrames = size(planarFrames,1);
outFrames = zeros(imgHeight,imgWidth,numFrames,'int16');

% Planar to 12-bit word conversion
for frameIter = 1:numFrames
    frameData = planarFrames(frameIter,:);
    bitsArray = flipud(transpose(dec2bin(frameData)));
    bitsArray = reshape(bitsArray,[],12);
    pixelArray = cast(bin2dec(bitsArray),'int16');
    
    for pixelIter = 1:length(pixelArray)
        if pixelArray(pixelIter) > 2047
            pixVal = pixelArray(pixelIter);
            pixVal = bitxor(pixVal,int16(0x07FF));
            pixelArray(pixelIter) = pixVal;
        end
    end
    outFrames(:,:,frameIter) = transpose(reshape(pixelArray,imgWidth,imgHeight));
end