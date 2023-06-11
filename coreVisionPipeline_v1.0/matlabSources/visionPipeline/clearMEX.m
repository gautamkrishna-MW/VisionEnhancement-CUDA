
clear mex;

if exist('./codegen', 'dir') == 7
    rmdir('./codegen', 's');
end

if ispc
   delete *.mexw64
else
    delete *.mexa64
end

delete *.asv

clc; clear all;
close all hidden;