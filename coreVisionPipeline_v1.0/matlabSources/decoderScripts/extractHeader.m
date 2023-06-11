

function [headerStruct, resBinString] = extractHeader(binString)

headerStruct.versionNum = typecast(binString(1:4),'int32');
headerStruct.xValue = typecast(binString(5:8),'int32');
headerStruct.yValue = typecast(binString(9:12),'int32');
headerStruct.numImages = typecast(binString(13:16),'int32');

headerStruct.whiteBal = [typecast(binString(17:18),'int16'), typecast(binString(19:20),'int16'), ...
    typecast(binString(21:22),'int16'), typecast(binString(23:24),'int16')];

headerStruct.paddedZeros = binString(25:32);
resBinString = binString(33:end);