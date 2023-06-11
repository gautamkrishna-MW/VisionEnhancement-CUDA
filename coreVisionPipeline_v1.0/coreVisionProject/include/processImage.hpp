

#ifndef PROCESS_IMAGE_HEADER
#define PROCESS_IMAGE_HEADER

#include <opencv2/opencv.hpp>
#include <iostream>

#include "kayaUtility.hpp"
#include "visionPipeline.h"
#include "visionPipeline_terminate.h"

#include "stg_chkImageSaturation.h"
#include "stg_chkImageSaturation_terminate.h"

#define DELAY_MS 1

class processImageClass
{
private:
    cv::Mat whiteImage;
    double gainFactor = 100.0;

    const std::string leftWindowName = "Left Frame";
    const std::string rightWindowName = "Right Frame";

    uint16_t leftFrameData[FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS] = {0};
    uint16_t rightFrameData[FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS] = {0};

    cv::Mat leftImageMat;
    cv::Mat rightImageMat;

public:
    processImageClass(std::string WBImagePath = std::string("data/WhitePatch.png"));
    void updateWhiteImageForAWB(uint16_t* inputFramePtr = NULL);

    // Frame Processing functions
    void processLeftFrame(uint16_t* inpLeftFramePtr, void* userContext);
    void processRightFrame(uint16_t* inpRightFramePtr, void* userContext);
    void displayRawFrame(uint16_t* rawFramePtr, void* userContext);
    bool isFrameSaturated(uint16_t* rawFramePtr, void* userContext);

    void displayImage(const char* title, cv::Mat inpImg);
    ~processImageClass();
};

#endif