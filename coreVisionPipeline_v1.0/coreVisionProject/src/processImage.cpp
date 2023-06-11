
#include "processImage.hpp"

processImageClass::processImageClass(std::string WBImagePath)
{
    cv::Mat inpImage = cv::imread(WBImagePath, cv::ImreadModes::IMREAD_ANYDEPTH);
    assertChk(inpImage.type() == CV_16U, "White patch should be a 16-bit unsigned image");
    cv::resize(inpImage, whiteImage, cv::Size(FRAME_WIDTH, FRAME_HEIGHT));

    leftImageMat = cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16UC3, leftFrameData);
    rightImageMat = cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16UC3, rightFrameData);
}

void processImageClass::updateWhiteImageForAWB(uint16_t* inputFramePtr)
{
    assertChk(inputFramePtr != NULL, "NULL image pointer encountered");
    cv::Mat inpFrame = cv::Mat(FRAME_HEIGHT + BLACK_EST_ROWS, FRAME_WIDTH, CV_16U, inputFramePtr);
    cv::resize(inpFrame, whiteImage, cv::Size(FRAME_WIDTH, FRAME_HEIGHT));
}

void processImageClass::processLeftFrame(uint16_t* inpLeftFramePtr, void* userContext)
{
    visionPipeline(inpLeftFramePtr, (uint16_t*) whiteImage.data, &gainFactor, leftFrameData);
    displayImage(leftWindowName.c_str(), leftImageMat);
}

void processImageClass::processRightFrame(uint16_t* inpRightFramePtr, void* userContext)
{
    visionPipeline(inpRightFramePtr, (uint16_t*) whiteImage.data, &gainFactor, rightFrameData);
    displayImage(rightWindowName.c_str(), rightImageMat);
}

void processImageClass::displayRawFrame(uint16_t* rawFramePtr, void* userContext)
{
    displayImage("Original Frame", cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16U, rawFramePtr));
}

bool processImageClass::isFrameSaturated(uint16_t* rawFramePtr, void* userContext)
{
    bool isSaturated = (bool)stg_chkImageSaturation(rawFramePtr);
    displayImage("White Frame", cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16U, rawFramePtr));
    return isSaturated;
}

void processImageClass::displayImage(const char* title, cv::Mat inpImg)
{
    cv::imshow(title, inpImg*16);
    cv::waitKey(DELAY_MS);
}

processImageClass::~processImageClass()
{
    DEBUG("Freeing GPU Memory!");
    visionPipeline_terminate();
};