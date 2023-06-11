

function [planarFrameData, resBinString] = getPlanarData(inpBinString, frameSize)

planarFrameData = 255*ones(1,frameSize,'uint8');
compressedFrameSize = typecast(inpBinString(1:4),'int32');
srcDataPtr = 5;
dstDataPtr = 1;

while (srcDataPtr < compressedFrameSize)
    intVal = typecast(inpBinString(srcDataPtr:srcDataPtr+3),'int32');
    if intVal > 0 % Repeat
        sectionSize = 1;
        planarFrameData(dstDataPtr:dstDataPtr+intVal-1) = inpBinString(srcDataPtr+4);
    elseif intVal < 0 % Copy
        sectionSize = abs(intVal);
        for byteIter = 1:abs(intVal)
            planarFrameData(dstDataPtr+byteIter-1) = inpBinString(srcDataPtr+3+byteIter);
        end
    end   
    srcDataPtr = srcDataPtr + 4 + sectionSize;
    dstDataPtr = abs(intVal) + dstDataPtr;
end
resBinString = inpBinString(srcDataPtr:end);