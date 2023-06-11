
#include "callbackFunctions.hpp"

#include <chrono>
using std::chrono::high_resolution_clock;
using std::chrono::duration_cast;
using std::chrono::duration;
using std::chrono::milliseconds;

void callbackFunctions::rightCameraCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext)
{
    /* Return if no stream data found */
    if (streamBufferHandle == 0)
    {
        DEBUG("Received NULL on stream buffer handle.");
        return;
    }

    // Frame Meta data
    unsigned char* frMemPtr = nullptr;
    KY_DATA_TYPE frType = KY_DATATYPE_SIZET;
    size_t frSize = 8;    
    uint32_t frameId = 0;
    KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_BASE, &frMemPtr, &frSize, &frType);
    kayaErrchk(KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_ID, &frameId, NULL, NULL));
    
    FGHANDLE* fghandle = (FGHANDLE *) userContext;
    DEBUG("AWBRegValue: " << std::hex << AWBRegValue);
    if (checkSaturation)
    {
        DEBUG("Auto-White Balancing Right Frame");
        isRightFrameSaturated = processFrameObj->isFrameSaturated((uint16_t*)frMemPtr, userContext);
        DEBUG("Right Frame is Saturated: " << (int)isRightFrameSaturated);
        if (!isRightFrameSaturated)
        {
            processFrameObj->updateWhiteImageForAWB((uint16_t*)frMemPtr);
            DEBUG("Updating white image");
            checkSaturation = false;
            AWBRegValue = 0xABCD0000;
        }
    }
    else
    {
        DEBUG("Right Frame: " << "\n\tFrame Ptr: " << (size_t)frMemPtr << "\n\tFrame Id: " << frameId << "\n\tFrame DataType: " << frType << "\n\tFrame Size: " << frSize);
        // Process the Frame
        auto tStart = high_resolution_clock::now();
        processFrameObj->processRightFrame((uint16_t*)frMemPtr, userContext);
        auto tStop = high_resolution_clock::now();
        auto funExec = duration_cast<milliseconds>(tStop - tStart);
        DEBUG("Right Frame Processing Time (in ms): " << funExec.count());
    }
    
    // Return stream buffer to input queue
    KYFG_BufferToQueue(streamBufferHandle, KY_ACQ_QUEUE_INPUT);
}

void callbackFunctions::leftCameraCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext)
{
    /* Return if no stream data found */
    if (streamBufferHandle == 0)
    {
        DEBUG("Received NULL on stream buffer handle.");
        return;
    }
            
    // Frame Meta data
    unsigned char* frMemPtr = nullptr;
    KY_DATA_TYPE frType = KY_DATATYPE_SIZET;
    size_t frSize = 8;
    uint32_t frameId = 0;
    KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_BASE, &frMemPtr, &frSize, &frType);
    kayaErrchk(KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_ID, &frameId, NULL, NULL));
    
    FGHANDLE* fghandle = (FGHANDLE *) userContext;
    DEBUG("AWBRegValue: " << std::hex << AWBRegValue);
    if (checkSaturation)
    {
        DEBUG("Auto-White Balancing Left Frame");
        isLeftFrameSaturated = processFrameObj->isFrameSaturated((uint16_t*)frMemPtr, userContext);
        DEBUG("Left Frame is Saturated: " << (int)isLeftFrameSaturated);
        if (!isLeftFrameSaturated)
        {
            processFrameObj->updateWhiteImageForAWB((uint16_t*)frMemPtr);
            DEBUG("Updating white image");
            checkSaturation = false;
            AWBRegValue = 0xABCD0000;
        }
    }
    else
    {
        DEBUG("Left Frame: " << "\n\tFrame Ptr: " << (size_t)frMemPtr << "\n\tFrame Id: " << frameId << "\n\tFrame DataType: " << frType << "\n\tFrame Size: " << frSize);
        // Process the Frame
        auto tStart = high_resolution_clock::now();
        processFrameObj->processLeftFrame((uint16_t*)frMemPtr, userContext);
        auto tStop = high_resolution_clock::now();
        auto funExec = duration_cast<milliseconds>(tStop - tStart);
        DEBUG("Left Frame Processing Time (in ms): " << funExec.count());
    }
    
    // Return stream buffer to input queue
    KYFG_BufferToQueue(streamBufferHandle, KY_ACQ_QUEUE_INPUT);
}