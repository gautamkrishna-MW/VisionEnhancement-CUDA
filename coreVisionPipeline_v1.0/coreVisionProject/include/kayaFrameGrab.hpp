#ifndef KAYA_FG_HEADER
#define KAYA_FG_HEADER

#include "KYFGLib.h"
#include "kayaUtility.hpp"

/* KAYA Specific defines */
#define MAXSTREAMS 2
#define MAXBUFFERS 32
#define TEST_PATTERN 0

/* Global Variables */
extern STREAM_BUFFER_HANDLE streamBufferHandle[MAXSTREAMS][MAXBUFFERS];
extern uint32_t AWBRegValue;
extern bool isLeftFrameSaturated;
extern bool isRightFrameSaturated;
extern bool checkSaturation;

/* Callback function pointer typedef */
typedef void(*callbackPtr) (STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext);

/* KAYA Error check and assert */
#define kayaErrchk(ans) { kayaAssert((ans), __FILE__, __LINE__); }
inline void kayaAssert(FGSTATUS code, const char *file, int line, bool abort=true)
{
   if (code != FGSTATUS_OK) 
   {
      fprintf(stderr,"KAYA Error: ID: 0x%x, FILE: %s, LINE: %d\n", code, file, line);
      fprintf(stderr,"Refer \"KYFG_ErrorCodes.h\" for more information on the error\n");
      if (abort) 
        exit(code);
   }
}

class kayaFrameGrabberClass
{
public:
   /* Method to create the singleton class */
   static kayaFrameGrabberClass* getInstance(uint32_t kayaVersion);

   /* Set-up callback functions */
   void setupCallbackFunctions(callbackPtr leftCamPtr, callbackPtr rightCamPtr);

   /* Main call to setup Kaya FG and Start aquisition */
   void setupFGAndStartAquisition();

   /* Loop for continious acquisition */
   void runAcquisitionLoopUntilStop();

   kayaFrameGrabberClass(const kayaFrameGrabberClass&) = delete;
   kayaFrameGrabberClass& operator=(const kayaFrameGrabberClass&) = delete;

   ~kayaFrameGrabberClass();

private:

   static kayaFrameGrabberClass* alreadyInitialized;
   
   KYFGLib_InitParameters kyInit;

   STREAM_HANDLE camStreamHandle[2] = {INVALID_STREAMHANDLE};
   FGHANDLE physicalFGHandle = INVALID_FGHANDLE;
   CAMHANDLE camHandleArr[KY_MAX_CAMERAS] = {INVALID_CAMHANDLE};
   int numCamerasDetected = 0;
   std::map<std::string, std::pair<uint64_t, uint32_t>> regMapping;

   uint32_t registerExposureSettings[5] = {0x00000000, 0x00100000, 0x00200000, 0x00210000, 0x00218000};
   
   StreamBufferCallback leftCameraCallback;
   StreamBufferCallback rightCameraCallback;
   // void (*leftCameraCallback)(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext) = nullptr;
   // void (*rightCameraCallback)(STREAM_BUFFER_HANDLE streamBufferHandle, void* userContext) = nullptr;

   /* Singleton Class */
   kayaFrameGrabberClass(uint32_t kayaVersion = KY_MAX_INIT_VERSION);
   
   /* Initialize library */
   void initializeKayaLib(uint32_t kayaVersion);

   /* Identify and connect to a Physical FG */
   void detectPhysicalFGAndConnect();

   /* First check for connected cameras */
   void detectConnectedCameras();

   /* FG Parameter settings */
   void modifyFGForDualStream();

   /* Camera Setup and registering callback */
   void setupVirtualCamerasAndRegisterCallback();
};

#endif