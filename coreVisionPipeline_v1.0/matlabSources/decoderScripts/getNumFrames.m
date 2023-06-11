

function numFrames = getNumFrames(inpBinString)

startPtr = 1;
numFrames = 0;

while (startPtr < length(inpBinString))
    compressedFrameSize = typecast(inpBinString(startPtr:startPtr+3),'int32');
    numFrames = numFrames+1;
    startPtr = startPtr + compressedFrameSize;
end
