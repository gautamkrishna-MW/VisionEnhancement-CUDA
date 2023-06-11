
#ifndef KAYA_FG_SOURCE
#define KAYA_FG_SOURCE

#include "kayaFrameGrab.hpp"

STREAM_BUFFER_HANDLE streamBufferHandle[MAXSTREAMS][MAXBUFFERS] = {INVALID_STREAM_BUFFER_HANDLE};
kayaFrameGrabberClass* kayaFrameGrabberClass::alreadyInitialized = NULL;

uint32_t AWBRegValue = 0;
bool isLeftFrameSaturated = false;
bool isRightFrameSaturated = false;
bool checkSaturation = false;

uint32_t exposureTimePos = 0;

kayaFrameGrabberClass* kayaFrameGrabberClass::getInstance(uint32_t kayaVersion)
{
    if (alreadyInitialized == NULL)
    {
        alreadyInitialized = new kayaFrameGrabberClass(kayaVersion);        
    }
    return alreadyInitialized;
}

/* Constructor */
kayaFrameGrabberClass::kayaFrameGrabberClass(uint32_t kayaVersion)
{
    initializeKayaLib(kayaVersion);
    DEBUG("FG Interface Setup");
}

/* Library Initialization */
void kayaFrameGrabberClass::initializeKayaLib(uint32_t kayaVersion)
{
    /* Kaya Initialization */
    KYFGLib_InitParameters kyInit;
    kyInit.version = kayaVersion;
    kyInit.concurrency_mode = 0;
    kyInit.logging_mode = 0;
    kayaErrchk(KYFGLib_Initialize(&kyInit));
}

void kayaFrameGrabberClass::setupCallbackFunctions(callbackPtr leftCamPtr, callbackPtr rightCamPtr)
{
    leftCameraCallback = leftCamPtr;
    rightCameraCallback = rightCamPtr;
}

/* Identifies the connected Kaya devices and opens a physical FG */
void kayaFrameGrabberClass::detectPhysicalFGAndConnect()
{
    /* Scan for devices connected */
    int numDevices = 0;
    kayaErrchk(KY_DeviceScan(&numDevices));
    assertChk(numDevices > 0, "No Kaya Device found");

    /* Get info about connected devices */
    std::vector<FGHANDLE> fgHandleVect(numDevices);
    std::vector<KY_DEVICE_INFO> devInfoArray(numDevices);
    int physicalFGHandleIdx = -1;

    DEBUG(numDevices << " Available Devices: Name {PID, isVirtual}\n");
    for (int i=0; i<numDevices; i++)
    {
        fgHandleVect[i] = i;
        devInfoArray[i].version = KY_MAX_DEVICE_INFO_VERSION;
        kayaErrchk(KY_DeviceInfo(fgHandleVect[i], &devInfoArray[i]));
        DEBUG(devInfoArray[i].szDeviceDisplayName << " {" << devInfoArray[i].DevicePID << ',' << (bool)devInfoArray[i].isVirtual << "}\n");
        if (!devInfoArray[i].isVirtual)
            physicalFGHandleIdx = i;
    }

    // Open and reset FG Link
    physicalFGHandle = KYFG_Open(physicalFGHandleIdx);
    assertChk(physicalFGHandle != 0, "Found a physical FG Device");
    // KYFG_WritePortReg(physicalFGHandle, 0, 0x00004000, swap_uint32(0));

    /* Check for queued buffer support */
    int64_t queuedBufferCapable = 0;
    queuedBufferCapable = KYFG_GetGrabberValueInt(physicalFGHandle, DEVICE_QUEUED_BUFFERS_SUPPORTED);
    DEBUG("Is Queue Buffer Capable? : " << queuedBufferCapable);
    assertChk(queuedBufferCapable == 1, "Queue Buffers are not supported");
}

/* Detect connected cameras */
void kayaFrameGrabberClass::detectConnectedCameras()
{
    kayaErrchk(KYFG_CameraScan(physicalFGHandle, camHandleArr, &numCamerasDetected));
    assertChk(numCamerasDetected > 0, "No cameras detected");
    DEBUG("Num cameras detected: " << numCamerasDetected);
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
void kayaFrameGrabberClass::modifyFGForDualStream()
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
    DEBUG("Num cameras detected after manual connection mode: " << numCamerasDetected);
    assertChk(numCamerasDetected == 2, "Stereo camera system not detected");
}

void kayaFrameGrabberClass::setupVirtualCamerasAndRegisterCallback()
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
    kayaErrchk(KYFG_StreamBufferCallbackRegister(camStreamHandle[0], leftCameraCallback, &physicalFGHandle));
    kayaErrchk(KYFG_BufferQueueAll(camStreamHandle[0], KY_ACQ_QUEUE_UNQUEUED, KY_ACQ_QUEUE_INPUT));

    /* Register Callbacks and queue buffers for Camera 1 */
    kayaErrchk(KYFG_StreamBufferCallbackRegister(camStreamHandle[1], rightCameraCallback, &physicalFGHandle));
    kayaErrchk(KYFG_BufferQueueAll(camStreamHandle[1], KY_ACQ_QUEUE_UNQUEUED, KY_ACQ_QUEUE_INPUT));

    /* Acquisition start commands */
    KYFG_CameraStart(camHandleArr[0], camStreamHandle[0], 0);
    KYFG_CameraStart(camHandleArr[1], camStreamHandle[1], 0);
    KYFG_WritePortReg(physicalFGHandle, 0, regMapping["Acq Start"].first, swap_uint32(1)); // Start Physical camera
    DEBUG("Frame acquisition started");
}

void kayaFrameGrabberClass::runAcquisitionLoopUntilStop()
{
    AWBRegValue = 0;
    uint32_t tmpVal = 0;
    KYFG_ReadPortReg(physicalFGHandle, 0, 0x805C, &tmpVal);
    AWBRegValue = tmpVal;

    signal(SIGINT, inthand);
    while(!stopLoop)
    {
        KYFG_ReadPortReg(physicalFGHandle, 0, 0x805C, &tmpVal);
        checkSaturation = (tmpVal != AWBRegValue);
        AWBRegValue = tmpVal;
        if (checkSaturation)
        {
            sleep(2);
            while (isLeftFrameSaturated || isRightFrameSaturated)
            {
                isLeftFrameSaturated = 0; isRightFrameSaturated = 0;
                KYFG_WritePortReg(physicalFGHandle, 0, 0x601C, 0);
                KYFG_WritePortReg(physicalFGHandle, 0, 0x6028, registerExposureSettings[exposureTimePos%5]);
                KYFG_WritePortReg(physicalFGHandle, 0, 0x602C, registerExposureSettings[exposureTimePos%5]);
                sleep(5);
                KYFG_WritePortReg(physicalFGHandle, 0, 0x601C, 1);
                exposureTimePos++;
                sleep(2);
            }
        }
    }
}

/* Main call to setup Kaya FG and Start aquisition */
void kayaFrameGrabberClass::setupFGAndStartAquisition()
{
    detectPhysicalFGAndConnect();
    DEBUG("Physical FG detection successful");
    detectConnectedCameras();
    DEBUG("Camera detection successful");
    modifyFGForDualStream();
    DEBUG("Dual Stream setup successful");
    setupVirtualCamerasAndRegisterCallback();
    DEBUG("Virtual Camera setup and callback registration successful");
}

/* Class Destructor */
kayaFrameGrabberClass::~kayaFrameGrabberClass()
{
    for (int iCam = 0; iCam < numCamerasDetected; ++iCam)
    {
        // Stop all streams coming from the camera
        KYFG_CameraExecuteCommand(camHandleArr[iCam], "AcquisitionStop");
        KYFG_CameraStop(camHandleArr[iCam]);
        DEBUG("Acquisition stopped on camera: " << iCam);
    }

    /* KYFG_StreamBufferCallbackUnregister(camStreamHandle[0], leftCameraCallback);
    KYFG_StreamBufferCallbackUnregister(camStreamHandle[1], rightCameraCallback);

    KYFG_StreamDelete(camStreamHandle[0]);
    KYFG_StreamDelete(camStreamHandle[1]);
    KYFG_CameraClose(camHandleArr[0]);
    KYFG_CameraClose(camHandleArr[1]); */

    KYFG_Close(physicalFGHandle);
    DEBUG("Closing camera and FG. Exiting!");
}
#endif