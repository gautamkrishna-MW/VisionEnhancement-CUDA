
#include "kayaFrameGrab.hpp"
#include "processImage.hpp"

void testLeftCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext)
{
    std::cout << "Test Left Callback" << std::endl;
    /* Return stream buffer to input queue */
    KYFG_BufferToQueue(streamBufferHandle, KY_ACQ_QUEUE_INPUT);
}

void testRightCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext)
{
    std::cout << "Test Right Callback" << std::endl;
    /* Return stream buffer to input queue */
    KYFG_BufferToQueue(streamBufferHandle, KY_ACQ_QUEUE_INPUT);
}

int main()
{
    processImageClass frameProcess;

    int kayaVersion = 2;
    kayaFrameGrabber* fgObjectPtr = kayaFrameGrabber::getInstance();
    fgObjectPtr->processFrameObjPtr = &frameProcess;

    // leftCamCallBckPtr = &testLeftCallback;
    // rightCamCallBckPtr = &testRightCallback;

    int32_t retVal = fgObjectPtr->setupFGAndStartAquisition(kayaVersion);
    
    if (retVal < 0)
    {
        ERRLOG("Error encountered in Frame Grabber object.");
    }
    delete fgObjectPtr;
}
