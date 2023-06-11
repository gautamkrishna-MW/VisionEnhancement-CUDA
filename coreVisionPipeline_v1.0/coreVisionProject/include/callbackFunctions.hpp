
#ifndef CALLBACK_HEADER
#define CALLBACK_HEADER

#include "kayaFrameGrab.hpp"
#include "processImage.hpp"

extern processImageClass* processFrameObj;

namespace callbackFunctions
{
    void rightCameraCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext);
    void leftCameraCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext);
};

#endif