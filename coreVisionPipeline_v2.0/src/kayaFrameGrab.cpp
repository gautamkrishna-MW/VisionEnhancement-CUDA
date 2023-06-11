
#ifndef KAYA_FG_SOURCE
#define KAYA_FG_SOURCE

#include "kayaFrameGrab.hpp"

/* Flag for Ctrl+C callback */
volatile sig_atomic_t stopLoop = false;
void inthand(int signum) { stopLoop = 1; }

/* Instantiating extern variables */
void (*leftCamCallBckPtr)(STREAM_BUFFER_HANDLE, void*) = nullptr;
void (*rightCamCallBckPtr)(STREAM_BUFFER_HANDLE, void*) = nullptr;

/* Singleton class static pointer */
kayaFrameGrabber* kayaFrameGrabber::instancePtr = NULL;

/* Constructor */
kayaFrameGrabber::kayaFrameGrabber()
{
    /* Handle initializations */
    numCamerasDetected = 0;
    physicalFGHandle = INVALID_FGHANDLE;

    exposureRegisterValues[0] = 0x00000000;
    exposureRegisterValues[1] = 0x00100000;
    exposureRegisterValues[2] = 0x00200000;
    exposureRegisterValues[3] = 0x00210000;
    exposureRegisterValues[4] = 0x00218000;

    leftCamCallBckPtr = &kayaFrameGrabber::leftCameraCallback;
    rightCamCallBckPtr = &kayaFrameGrabber::rightCameraCallback;
}

kayaFrameGrabber* kayaFrameGrabber::getInstance()
   {
      if (instancePtr == NULL)
      {
         instancePtr = new kayaFrameGrabber();        
      }
      return instancePtr;
   }

/* Library Initialization */
void kayaFrameGrabber::initializeKayaLib(uint32_t kayaVersionInput)
{
    /* Kaya Initialization */
    KYFGLib_InitParameters kyInit;
    kyInit.version = kayaVersionInput;
    kyInit.concurrency_mode = 0;
    kyInit.logging_mode = 0;
    kayaErrchk(KYFGLib_Initialize(&kyInit));
    LOG("Successful Kaya Library Initialization");
}

/* Identifies the connected Kaya devices and opens a physical FG */
int32_t kayaFrameGrabber::detectPhysicalFGAndConnect()
{
    /* Scan for devices connected */
    int numDevices = 0;
    kayaErrchk(KY_DeviceScan(&numDevices));
    if (numDevices <= 0)
    {
        ERRLOG("No Kaya Device found");
        return -1;
    }

    /* Get info about connected devices */
    std::vector<FGHANDLE> fgHandleVect(numDevices);
    std::vector<KY_DEVICE_INFO> devInfoArray(numDevices);
    int physicalFGHandleIdx = -1;

    LOG(numDevices << " Available Devices: Name {PID, isVirtual}\n");
    for (int i=0; i<numDevices; i++)
    {
        fgHandleVect[i] = i;
        devInfoArray[i].version = KY_MAX_DEVICE_INFO_VERSION;
        kayaErrchk(KY_DeviceInfo(fgHandleVect[i], &devInfoArray[i]));
        LOG(i << ". " << devInfoArray[i].szDeviceDisplayName << " {" << devInfoArray[i].DevicePID << ',' << (bool)devInfoArray[i].isVirtual << "}\n");
        if (!devInfoArray[i].isVirtual)
            physicalFGHandleIdx = i;
    }

    /* Open physical FG Link */
    physicalFGHandle = KYFG_Open(physicalFGHandleIdx);
    if (physicalFGHandle <= 0)
    {
        ERRLOG("No physical FG Device found");
        return -1;
    }

    /* Check for queued buffer support */
    int64_t queuedBufferCapable = 0;
    queuedBufferCapable = KYFG_GetGrabberValueInt(physicalFGHandle, DEVICE_QUEUED_BUFFERS_SUPPORTED);
    if (queuedBufferCapable != 1)
    {
        ERRLOG("Queue Buffers are not supported on the selected device or the device is busy");
        return -1;
    }
    
    LOG("Connection to FG established with queued buffers enabled");
    return 0;
}

/* Detect connected cameras */
int32_t kayaFrameGrabber::detectConnectedCameras()
{
    kayaErrchk(KYFG_CameraScan(physicalFGHandle, camHandleArr, &numCamerasDetected));
    if (numCamerasDetected <= 0)
    {
        ERRLOG("No cameras detected");
        return -1;
    }
    LOG("Num cameras detected: " << numCamerasDetected);
    return numCamerasDetected;
}

/* Register settings */
void fillRegMapping(std::map<std::string, std::pair<uint64_t, uint32_t>> &regMapping)
{
    regMapping["Acq Start"]             = std::make_pair(0x601C,swap_uint32(0));
    regMapping["Master Host Link ID"]   = std::make_pair(0x4008,swap_uint32(0x000000de));
    regMapping["Stream Size"]           = std::make_pair(0x4010,swap_uint32(0x00000400));
    regMapping["Pixel Format (B-GB12)"] = std::make_pair(0x6008,swap_uint32(0x00000323));
    regMapping["Port Frame Rate"]       = std::make_pair(0x6024,swap_uint32(0x42700000));
    regMapping["Port Width"]            = std::make_pair(0x6000,swap_uint32(FRAME_WIDTH));
    regMapping["Port Height"]           = std::make_pair(0x6004,swap_uint32(FRAME_HEIGHT + BLACK_EST_ROWS));
    regMapping["Port Sensor Ctrl 0"]    = std::make_pair(0x6028,swap_uint32(0));
    regMapping["Port Sensor Ctrl 1"]    = std::make_pair(0x602C,swap_uint32(0));
    regMapping["Continious Acq Mode"]   = std::make_pair(0x6018,swap_uint32(0));
    regMapping["Test Pattern"]          = std::make_pair(0x6030,swap_uint32(TEST_PATTERN));
}

/* Modifying FG Params for dual stream */
int32_t kayaFrameGrabber::modifyFGForDualStream()
{
    /* Register value settings */
    fillRegMapping(regMapping);
    
    std::map<std::string, std::pair<uint64_t, uint32_t>>::iterator mapIter;
    for (mapIter = regMapping.begin(); mapIter != regMapping.end(); ++mapIter)
    {
        KYFG_WritePortReg(physicalFGHandle, 0, mapIter->second.first, mapIter->second.second);
    }

    /* Modifying the frame grabber parameters for dual-streaming */
    static const uint64_t cameraConnectionSpeedRegAddr = 0x4014;
    uint32_t cameraConnectionSpeedRegValue = 0;
    kayaErrchk(KYFG_ReadPortReg(physicalFGHandle, 0, cameraConnectionSpeedRegAddr, &cameraConnectionSpeedRegValue)); 
    cameraConnectionSpeedRegValue = swap_uint32(cameraConnectionSpeedRegValue); // BigEndian to LittleEndian

    /* Grabber settings for each camera stream */
    const uint64_t fgRegBase = 0x402064;
    const uint64_t fgRegStep = 0x1000;
    const uint32_t fgRegValue = 0;
    for (int iCam = 0; iCam < MAXSTREAMS; iCam++)
    {
        
        kayaErrchk(KYFG_DeviceDirectHardwareWrite(physicalFGHandle, fgRegBase + fgRegStep * iCam, &fgRegValue, sizeof(fgRegValue)));
        kayaErrchk(KYFG_SetGrabberValueInt(physicalFGHandle, "CameraSelector", iCam));
        kayaErrchk(KYFG_SetGrabberValueEnum_ByValueName(physicalFGHandle, "ManualCameraMode", "On"));
        kayaErrchk(KYFG_SetGrabberValueEnum(physicalFGHandle, "ManualCameraConnectionConfig", cameraConnectionSpeedRegValue));
        kayaErrchk(KYFG_SetGrabberValueInt(physicalFGHandle, "ManualCameraChannelSelector", 0));
        kayaErrchk(KYFG_SetGrabberValueInt(physicalFGHandle, "ManualCameraFGLink", 0));
        kayaErrchk(KYFG_SetGrabberValueInt(physicalFGHandle, "Image1StreamID", iCam + 1));
    }

    kayaErrchk(KYFG_CameraScan(physicalFGHandle, camHandleArr, &numCamerasDetected));
    LOG("Num cameras detected after manual connection mode: " << numCamerasDetected);
    if (numCamerasDetected != 2)
    {
        ERRLOG("Stereo streams could not be established");
        return -1;
    }

    LOG("Dual Stream setup successful");
    return numCamerasDetected;
}

void kayaFrameGrabber::setupVirtualCamerasAndRegisterCallback()
{
    for (int camIter = 0; camIter < numCamerasDetected; camIter++)
    {
        kayaErrchk(KYFG_CameraOpen2(camHandleArr[camIter], NULL));
        kayaErrchk(KYFG_SetGrabberValueEnum_ByValueName(physicalFGHandle, "TransferControlMode", "UserControlled"));
        kayaErrchk(KYFG_StreamCreate(camHandleArr[camIter], &camStreamHandle[camIter], 0));
        
        // Retrieve information about required frame buffer size and alignment 
        size_t frameDataSize, frameDataAligment;
        kayaErrchk(KYFG_StreamGetInfo(camStreamHandle[camIter],KY_STREAM_INFO_PAYLOAD_SIZE,&frameDataSize,NULL, NULL));
        
        // Allocate memory for frames
        for (int iFrame = 0; iFrame < MAXBUFFERS; iFrame++)
        {
            kayaErrchk(KYFG_BufferAllocAndAnnounce(camStreamHandle[camIter], frameDataSize, NULL, &streamBufferHandle[camIter][iFrame]));
        }
    }

    /* Reset frame height to original value */
    KYFG_WritePortReg(physicalFGHandle, 0, regMapping["Port Height"].first, swap_uint32(FRAME_HEIGHT));

    /* Register Callbacks and queue buffers for Camera 0 */
    kayaErrchk(KYFG_StreamBufferCallbackRegister(camStreamHandle[0], leftCamCallBckPtr, (void*)this));
    kayaErrchk(KYFG_BufferQueueAll(camStreamHandle[0], KY_ACQ_QUEUE_UNQUEUED, KY_ACQ_QUEUE_INPUT));

    /* Register Callbacks and queue buffers for Camera 1 */
    kayaErrchk(KYFG_StreamBufferCallbackRegister(camStreamHandle[1], rightCamCallBckPtr, (void*)this));
    kayaErrchk(KYFG_BufferQueueAll(camStreamHandle[1], KY_ACQ_QUEUE_UNQUEUED, KY_ACQ_QUEUE_INPUT));

    /* Acquisition start commands */
    KYFG_CameraStart(camHandleArr[0], camStreamHandle[0], 0);
    KYFG_CameraStart(camHandleArr[1], camStreamHandle[1], 0);
    KYFG_WritePortReg(physicalFGHandle, 0, regMapping["Acq Start"].first, swap_uint32(1)); // Start Physical camera
    LOG("Callback registered, starting frame acquisition...");
}

void kayaFrameGrabber::runAcquisitionLoopUntilStop()
{
    AWBRegisterValue = 0;
    uint32_t tmpVal = 0;
    KYFG_ReadPortReg(physicalFGHandle, 0, 0x805C, &AWBRegisterValue);
    uint32_t exposureTimePos = 0;
    
    signal(SIGINT, inthand);
    while(!stopLoop)
    {
        KYFG_ReadPortReg(physicalFGHandle, 0, 0x805C, &tmpVal);
        if (tmpVal != AWBRegisterValue)
        {
            AWBRegisterValue = tmpVal;
            processFrameObjPtr->runAWB = true;
            sleep(2);
            while (isLeftFrameSaturated || isRightFrameSaturated)
            {
                isLeftFrameSaturated = 0; isRightFrameSaturated = 0;
                KYFG_WritePortReg(physicalFGHandle, 0, 0x601C, 0);
                KYFG_WritePortReg(physicalFGHandle, 0, 0x6028, exposureRegisterValues[exposureTimePos % 5]);
                KYFG_WritePortReg(physicalFGHandle, 0, 0x602C, exposureRegisterValues[exposureTimePos % 5]);
                sleep(5);
                KYFG_WritePortReg(physicalFGHandle, 0, 0x601C, 1);
                exposureTimePos++;
                sleep(2);
            }
            processFrameObjPtr->runAWB = false;
        }
    }
}

/* Main call to setup Kaya FG and Start aquisition */
int32_t kayaFrameGrabber::setupFGAndStartAquisition(uint32_t inpKayaVersion)
{
    initializeKayaLib(inpKayaVersion);
    int fgStatus = detectPhysicalFGAndConnect();
    if (fgStatus < 0)
    {
        return -1;
    }
    int numCam = detectConnectedCameras();
    if (numCam < 0)
    {
        return -1;
    }

    int multStreamStatus = modifyFGForDualStream();
    if (multStreamStatus < 0)
    {
        return -1;
    }
    setupVirtualCamerasAndRegisterCallback();
    runAcquisitionLoopUntilStop();

    return 0;
}

/* Class Destructor */
kayaFrameGrabber::~kayaFrameGrabber()
{
    for (int iCam = 0; iCam < numCamerasDetected; ++iCam)
    {
        // Stop all streams coming from the camera
        KYFG_CameraExecuteCommand(camHandleArr[iCam], "AcquisitionStop");
        KYFG_CameraStop(camHandleArr[iCam]);
        LOG("Acquisition stopped on camera: " << iCam);
    }

    KYFG_Close(physicalFGHandle);
    LOG("Closing camera and FG. Exiting!");
}


/* Call back functions */
void kayaFrameGrabber::rightCameraCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext)
{
    /* Return if no stream data found */
    if (streamBufferHandle == 0)
    {
        ERRLOG("Received NULL on stream buffer handle.");
        return;
    }

    kayaFrameGrabber* fgObj = (kayaFrameGrabber*) userContext;

    /* Get frame pointer */
    unsigned char* frMemPtr = nullptr;
    KY_DATA_TYPE frType = KY_DATATYPE_SIZET;
    size_t frSize = 8;
    uint32_t frameId = 0;
    KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_BASE, &frMemPtr, &frSize, &frType);
    kayaErrchk(KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_ID, &frameId, NULL, NULL));
    
    /* Process frame */
    // LOG("Right Frame: " << "\n\tFramePtr: " << frMemPtr << "\n\tFrameID: " << frameId);
    LOG("Process Frame Functor (Right): " << fgObj->processFrameObjPtr);
    if (fgObj->processFrameObjPtr != nullptr)
    {
        if (fgObj->processFrameObjPtr->runAWB)
        {
            LOG("AWB on Right Frame");
            fgObj->isRightFrameSaturated = fgObj->processFrameObjPtr->processAWBFrame((uint16_t*) frMemPtr, userContext);
        }
        else
        {
            LOG("Processing Right Frame: " << "\n\tFramePtr: " << frMemPtr << "\n\tFrameID: " << frameId);
            fgObj->processFrameObjPtr->processRightFrame((uint16_t*) frMemPtr, userContext);
        }
    }
    
    /* Return stream buffer to input queue */
    KYFG_BufferToQueue(streamBufferHandle, KY_ACQ_QUEUE_INPUT);
}

void kayaFrameGrabber::leftCameraCallback(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext)
{
    /* Return if no stream data found */
    if (streamBufferHandle == 0)
    {
        ERRLOG("Received NULL on stream buffer handle.");
        return;
    }

    kayaFrameGrabber* fgObj = (kayaFrameGrabber*) userContext;
            
    /* Get frame pointer */
    unsigned char* frMemPtr = nullptr;
    KY_DATA_TYPE frType = KY_DATATYPE_SIZET;
    size_t frSize = 8;
    uint32_t frameId = 0;
    KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_BASE, &frMemPtr, &frSize, &frType);
    kayaErrchk(KYFG_BufferGetInfo(streamBufferHandle, KY_STREAM_BUFFER_INFO_ID, &frameId, NULL, NULL));
    
    /* Process frame */
    // LOG("Left Frame: " << "\n\tFramePtr: " << frMemPtr << "\n\tFrameID: " << frameId);
    LOG("Process Frame Functor (Left): " << fgObj->processFrameObjPtr);
    if (fgObj->processFrameObjPtr != nullptr)
    {
        if (fgObj->processFrameObjPtr->runAWB)
        {
            LOG("AWB on Left Frame");
            fgObj->isLeftFrameSaturated = fgObj->processFrameObjPtr->processAWBFrame((uint16_t*) frMemPtr, userContext);
        }
        else
        {
            LOG("Processing Left Frame: " << "\n\tFramePtr: " << frMemPtr << "\n\tFrameID: " << frameId);
            fgObj->processFrameObjPtr->processLeftFrame((uint16_t*) frMemPtr, userContext);
        }
    }
    
    /* Return stream buffer to input queue */
    KYFG_BufferToQueue(streamBufferHandle, KY_ACQ_QUEUE_INPUT);
}

#endif