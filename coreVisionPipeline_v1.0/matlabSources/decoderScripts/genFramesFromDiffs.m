

function outFrames = genFramesFromDiffs(outFrames)

for frIter = 2:size(outFrames,3)
    outFrames(:,:,frIter) = bitand(outFrames(:,:,frIter) + outFrames(:,:,frIter-1),int16(0xFFF));
end

end