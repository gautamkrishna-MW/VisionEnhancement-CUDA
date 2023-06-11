

#ifndef PROCESS_IMAGE_HEADER
#define PROCESS_IMAGE_HEADER

#include <opencv2/opencv.hpp>
#include <iostream>

#include "visionUtility.hpp"
#include "processFrameClass.hpp"

#define DELAY_MS 5
#define RAW_FRAME

class processImageClass : public processFrameClass
{
private:
    cv::Mat whiteImage;
    double gainFactor = 100.0;

    const std::string leftWindowName = "Left Frame";
    const std::string rightWindowName = "Right Frame";

    uint16_t *leftFrameData = nullptr;
    uint16_t *rightFrameData = nullptr;

    cv::Mat leftImageMat;
    cv::Mat rightImageMat;

    bool isGPUInitialized;

public:

    /* Constructor */
    processImageClass(const char* WBImagePath = "./data/whitePatc.png");

    // Frame Processing functions
    void processLeftFrame(uint16_t* inpLeftFramePtr, void* userContext) override;
    void processRightFrame(uint16_t* inpRightFramePtr, void* userContext) override;

    /* AWB Functions */
    cv::Mat generateWhitePatchForAWB();
    bool processAWBFrame(uint16_t* rawFramePtr, void* userContext) override;
    void updateAWBImage(uint16_t* inputFramePtr = NULL);
    
    /* Display Functions */
    void displayImage(const char* title, cv::Mat inpImg);
    ~processImageClass();
};

#endif