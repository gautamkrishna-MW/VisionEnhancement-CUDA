
#include "kayaFrameGrab.hpp"
#include "processImage.hpp"

void testLeftCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext)
{
    std::cout << "Test Left Callback" << std::endl;
    unsigned char* frMemPtr = nullptr;
    KY_DATA_TYPE frType = KY_DATATYPE_SIZET;
    int frID = -1;
    size_t frSize = 8;
    uint32_t frameId = 0;
    KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_BASE, &frMemPtr, &frSize, &frType);
    // KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_USER_PTR, &frMemPtr, NULL, NULL);
    KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_ID, &frID, NULL, NULL);
    std::cout << "Frame ID: " << frID << " Frame Ptr: " << frMemPtr << std::endl;
    /* Return stream buffer to input queue */
    KYFG_BufferToQueue(streamBufferHandle, KY_ACQ_QUEUE_INPUT);
}

void testRightCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext)
{
    std::cout << "Test Right Callback" << std::endl;
    unsigned char* frMemPtr = nullptr;
    KY_DATA_TYPE frType = KY_DATATYPE_SIZET;
    int frID = -1;
    size_t frSize = 8;
    uint32_t frameId = 0;
    KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_BASE, &frMemPtr, &frSize, &frType);
    // KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_USER_PTR, &frMemPtr, NULL, NULL);
    KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_ID, &frID, NULL, NULL);
    std::cout << "Frame ID: " << frID << " Frame Ptr: " << frMemPtr << std::endl;
    /* Return stream buffer to input queue */
    KYFG_BufferToQueue(streamBufferHandle, KY_ACQ_QUEUE_INPUT);
}

int main()
{
    /* Create Frame-Grabber class instance */
    int kayaVersion = 2;
    kayaFrameGrabber* fgObjectPtr = kayaFrameGrabber::getInstance();

    /* Creating the instance of frame processing class */
    processImageClass frameProcess;
    // Point the abstract class pointer to frame processing class
    fgObjectPtr->processFrameObjPtr = &frameProcess; 

    /* Run the application */
    int32_t retVal = fgObjectPtr->setupFGAndStartAquisition(kayaVersion);
    if (retVal < 0)
    {
        ERRLOG("Error encountered in Frame Grabber object.");
    }
    delete fgObjectPtr;
}
