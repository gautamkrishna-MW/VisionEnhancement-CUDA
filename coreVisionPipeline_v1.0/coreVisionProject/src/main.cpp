
#include "kayaFrameGrab.hpp"
#include "callbackFunctions.hpp"
#include "processImage.hpp"

processImageClass* processFrameObj = new processImageClass("./data/whitePatch.png");

int main(int argc, const char** argv)
{
    FILE* loggerFp = freopen("visionPipeLog.txt","w",stderr);
    void(*leftCamPtr)(STREAM_BUFFER_HANDLE,void*) = &callbackFunctions::leftCameraCallback;
    void(*rightCamPtr)(STREAM_BUFFER_HANDLE,void*) = &callbackFunctions::rightCameraCallback;
    
    int kayaVersion = 2;
    kayaFrameGrabberClass* fgObjectPtr = kayaFrameGrabberClass::getInstance(kayaVersion);
    fgObjectPtr->setupCallbackFunctions(leftCamPtr, rightCamPtr);
    fgObjectPtr->setupFGAndStartAquisition();
    fgObjectPtr->runAcquisitionLoopUntilStop();
    
    delete fgObjectPtr;
    delete processFrameObj;
    fclose(loggerFp);
}