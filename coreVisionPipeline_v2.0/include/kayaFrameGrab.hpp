#ifndef KAYA_FG_HEADER
#define KAYA_FG_HEADER

#include <vector>
#include <map>

#include "KYFGLib.h"
#include "visionUtility.hpp"
#include "processFrameClass.hpp"

/* KAYA Specific defines */
#define MAXSTREAMS 2
#define MAXBUFFERS 2
#define TEST_PATTERN 0

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

/* Function pointers to the static callback functions of the kayaFrameGrabber class. */
extern void (*leftCamCallBckPtr)(STREAM_BUFFER_HANDLE, void*);
extern void (*rightCamCallBckPtr)(STREAM_BUFFER_HANDLE, void*);

/* Singleton class to access the frame grabber */
class kayaFrameGrabber
{
protected:
   static void leftCameraCallback(STREAM_BUFFER_HANDLE, void*);
   static void rightCameraCallback(STREAM_BUFFER_HANDLE, void*);

private:
   
   // Pointer to the instance of the class
   static kayaFrameGrabber* instancePtr;

   // Kaya specific variables
   uint32_t AWBRegisterValue = 0;
   bool isLeftFrameSaturated = false;
   bool isRightFrameSaturated = false;
   int32_t numCamerasDetected = 0;
   uint32_t exposureRegisterValues[5] = {0};
   std::map<std::string, std::pair<uint64_t, uint32_t>> regMapping;
   
   KYFGLib_InitParameters kyInit;
   FGHANDLE physicalFGHandle = INVALID_FGHANDLE;
   CAMHANDLE camHandleArr[KY_MAX_CAMERAS] = {INVALID_CAMHANDLE};
   STREAM_HANDLE camStreamHandle[2] = {INVALID_STREAMHANDLE};
   STREAM_BUFFER_HANDLE streamBufferHandle[MAXSTREAMS][MAXBUFFERS] = {INVALID_STREAM_BUFFER_HANDLE};


   //////////* Private methods *//////////
   /* Singleton Class Contructor */
   kayaFrameGrabber();
   /* Initialize library */
   void initializeKayaLib(uint32_t kayaVersion);
   /* Identify and connect to a Physical FG */
   int32_t detectPhysicalFGAndConnect();
   /* First check for connected cameras */
   int32_t detectConnectedCameras();
   /* FG Parameter settings */
   int32_t modifyFGForDualStream();
   /* Camera Setup and registering callback */
   void setupVirtualCamerasAndRegisterCallback();
   /* Loop for continious acquisition */
   void runAcquisitionLoopUntilStop();

public:
   /* Pointer to frame processing abstract image class */
   processFrameClass* processFrameObjPtr = nullptr;

   /* Method to create the singleton class */
   static kayaFrameGrabber* getInstance();
   
   /* Main call to setup Kaya FG and Start aquisition */
   int32_t setupFGAndStartAquisition(uint32_t kayaVersion = KY_MAX_INIT_VERSION);
   /* Destructor */
   ~kayaFrameGrabber();

   /* Deleted copy constructors */
   kayaFrameGrabber(const kayaFrameGrabber&) = delete;
   kayaFrameGrabber& operator=(const kayaFrameGrabber&) = delete;
};


#endif