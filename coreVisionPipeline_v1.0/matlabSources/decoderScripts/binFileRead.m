
clearMEX;

%% Read binary data
% fileName = '02 2Sensor.bin';
fileName = '14 Lymph Node.bin';
outputFile = [fileName(1:end-4),' output.mat'];

fp = fopen(['../Dataset/',fileName],"r");
compressedData = uint8(fread(fp,'uint8'));
fclose(fp);

% Computing Frame size
imgWidth = 1920;
imgHeight = 2196;
numPixels = imgWidth*imgHeight;
bitsPerPixel = 12;
bitsPerByte = 8;
frameSize = (numPixels*bitsPerPixel)/bitsPerByte;

% Extract Header
[headerStruct, resBinString] = extractHeader(compressedData);

% Extract Num frames
numFrames = getNumFrames(resBinString);

% Extract Planar data
planarFrames = 255*ones(numFrames,frameSize,'uint8');
counter = 0;
while(~isempty(resBinString))
    [planarFrames(counter+1,:), resBinString] = getPlanarData(resBinString, frameSize);
    counter = counter + 1;
end

% Planar to frames
outDiffFrames = planar2Word(planarFrames, imgWidth, imgHeight);
outFrames = genFramesFromDiffs(outDiffFrames);
save(['../Dataset/', outputFile],'outFrames',"headerStruct");