

#ifndef PROCESS_IMAGE_HEADER
#define PROCESS_IMAGE_HEADER

#include <iostream>
#include <opencv2/opencv.hpp>
#include <cuda_runtime_api.h>

#include "visionUtility.hpp"
#include "processFrameAbstractClass.hpp"

#define DELAY_MS 2
// #define RAW_FRAME

class processImageClass : public processFrameAbstractClass
{
private:
    float *awbGain = nullptr;    
    const std::string leftWindowName = "Left Frame";
    const std::string rightWindowName = "Right Frame";
    
    uint16_t *leftFrameData = nullptr;
    uint16_t *rightFrameData = nullptr;
    uint16_t *devPtr_leftFrameData = nullptr;
    uint16_t *devPtr_rightFrameData = nullptr;
    uint16_t *devPtr_whiteFrame = nullptr;
    
    cv::Mat leftImageMat;
    cv::Mat rightImageMat;
    uint16_t* frBuffArray[MAXSTREAMS*MAXBUFFERS] = {nullptr};

public:

    /* Constructor */
    processImageClass();

    /* Allocate buffers to store frame data */
    void createFrameBufferArray();

    /* Frame Processing functions */
    void processLeftFrame(uint16_t* inpLeftFramePtr, void* userContext) override;
    void processRightFrame(uint16_t* inpRightFramePtr, void* userContext) override;

    /* AWB Functions */
    bool processAWBFrame(uint16_t* rawFramePtr, void* userContext) override;
    
    /* Display Functions */
    void displayImage(const char* title, cv::Mat inpImg);
    ~processImageClass();
};

#endif