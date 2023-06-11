
#ifndef PROCESS_FRAME_HEADER
#define PROCESS_FRAME_HEADER

#include <iostream>
#include <stdint.h>

/* Abstract frame processing class */
/* The kayaFrameGrabber class talks to a custom image processing class through
this processFrameAbstractClass member variable. This class should be inherited by any
class which wishes to process the frame. */

class processFrameAbstractClass
{
public:
    uint16_t* leftFramePtr = nullptr;
    uint16_t* rightFramePtr = nullptr;
    uint16_t** frameBufferArray = nullptr;

    bool runAWB = false;

    virtual void processRightFrame(uint16_t* inputFramePointer, void* userContext) = 0;
    virtual void processLeftFrame(uint16_t* inputFramePointer, void* userContext) = 0;
    virtual bool processAWBFrame(uint16_t* inputFramePointer, void* userContext) = 0;

    /* Setters */
    void setLeftFramePtr(uint16_t* leftPtr = NULL) { leftFramePtr = leftPtr; }
    void setRightFramePtr(uint16_t* rightPtr = NULL) { rightFramePtr = rightPtr; }
};

#endif