

clearMEX;

%% Load Frame
loadedVar = load("../Dataset/14 Lymph Node output.mat");
frame = uint16(loadedVar.outFrames(:,:,25));

%% White balance test patch creation
loadedVarWB = load("../Dataset/wbFrame.mat");
wbFrame = uint16(loadedVarWB.wbFrame);

rectCoords = [481, 271, 1440, 810];
rectSize = [rectCoords(3)-rectCoords(1)+1,rectCoords(4)-rectCoords(2)+1];
testWhitePatch = wbFrame(rectCoords(2):rectCoords(4),rectCoords(1):rectCoords(3));

%% Luma gain factor
gainFactor = 340;

%% Codegen
cdrConfig = coder.gpuConfig('exe');
cdrConfig.GpuConfig.EnableMemoryManager = 1;
cdrArgs = {coder.typeof(frame,'Gpu',true),coder.typeof(testWhitePatch,'Gpu',true),gainFactor};
codegen -config cdrConfig visionPipeline -args cdrArgs -report -o gpuMEX -c