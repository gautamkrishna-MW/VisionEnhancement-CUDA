
#include "processImage.hpp"

#ifndef RAW_FRAME
#include "visionPipeline.h"
#include "stg_chkImageSaturation.h"
#include "visionPipeline_terminate.h"
#include "stg_chkImageSaturation_terminate.h"
#endif

processImageClass::processImageClass(const char* WBImagePath)
{
    cv::Mat inpWhiteImg;
    inpWhiteImg = cv::imread(WBImagePath, cv::ImreadModes::IMREAD_ANYDEPTH);
    if (!inpWhiteImg.data)
    {
        inpWhiteImg = processImageClass::generateWhitePatchForAWB();
    }

    cv::Mat inpWhiteImg_16u;
    if (inpWhiteImg.type() != CV_16U)
    {
        inpWhiteImg.convertTo(inpWhiteImg_16u, CV_16U);
    }
    else
    {
        inpWhiteImg_16u = inpWhiteImg;
    }

    whiteImage = cv::Mat(cv::Size(FRAME_WIDTH/2, FRAME_HEIGHT/2), CV_16U);
    cv::resize(inpWhiteImg_16u, whiteImage, cv::Size(FRAME_WIDTH/2, FRAME_HEIGHT/2));

    processFrameClass::setLeftFramePtr(leftFrameData);
    processFrameClass::setRightFramePtr(rightFrameData);
    
    leftFrameData = (uint16_t*)malloc(FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t));
    rightFrameData = (uint16_t*)malloc(FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t));

    leftImageMat = cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16UC3, leftFrameData);
    rightImageMat = cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16UC3, rightFrameData);
    isGPUInitialized = false;
}

void processImageClass::processLeftFrame(uint16_t* inpLeftFramePtr, void* userContext)
{
#ifdef RAW_FRAME
    memcpy(leftFrameData, inpLeftFramePtr, FRAME_HEIGHT * FRAME_WIDTH * sizeof(uint16_t));
    leftImageMat = cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16U, leftFrameData);
#else
    visionPipeline(inpLeftFramePtr, (uint16_t*) whiteImage.data, &gainFactor, leftFrameData);
    isGPUInitialized = true;
#endif
    displayImage(leftWindowName.c_str(), leftImageMat);
}

void processImageClass::processRightFrame(uint16_t* inpRightFramePtr, void* userContext)
{
#ifdef RAW_FRAME
    memcpy(rightFrameData, inpRightFramePtr, FRAME_HEIGHT * FRAME_WIDTH * sizeof(uint16_t));
    rightImageMat = cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16U, rightFrameData);
#else
    visionPipeline(inpRightFramePtr, (uint16_t*) whiteImage.data, &gainFactor, rightFrameData);
    isGPUInitialized = true;
#endif
    displayImage(rightWindowName.c_str(), rightImageMat);
}

bool processImageClass::processAWBFrame(uint16_t* rawFramePtr, void* userContext)
{
#ifndef RAW_FRAME
    bool isSaturated = (bool)stg_chkImageSaturation(rawFramePtr);
#else
    bool isSaturated = false;
#endif
    isGPUInitialized = true;
    if (!isSaturated)
    {
        updateAWBImage(rawFramePtr);
        displayImage("White Frame", cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16U, rawFramePtr));
    }
    return isSaturated;
}

void processImageClass::updateAWBImage(uint16_t* inputFramePtr)
{
    if (inputFramePtr != NULL)
    {
        ERRLOG("FramePtr is NULL, unable to update the white image for AWB");
        LOG("Using existing white image as input pointer is NULL");
        return;
    }
    cv::Mat inpFrame = cv::Mat(FRAME_HEIGHT + BLACK_EST_ROWS, FRAME_WIDTH, CV_16U, inputFramePtr);
    cv::resize(inpFrame, whiteImage, cv::Size(FRAME_WIDTH/2, FRAME_HEIGHT/2));
    LOG("Updated the white image for AWB");
}

cv::Mat processImageClass::generateWhitePatchForAWB()
{
    return cv::Mat::ones(cv::Size(FRAME_WIDTH/2,FRAME_HEIGHT/2), CV_16U);
}

void processImageClass::displayImage(const char* title, cv::Mat inpImg)
{
    cv::Mat dispImg;
    if (inpImg.type() == CV_16U)
    {
        inpImg.convertTo(dispImg, CV_8U, 0.25);
    }
    else if (inpImg.type() == CV_16UC3)
    {
        inpImg.convertTo(dispImg, CV_8UC3, 0.25);
    }
    else
    {
        inpImg.copyTo(dispImg);
    }

    cv::imshow(title, dispImg);
    cv::waitKey(DELAY_MS);
}

processImageClass::~processImageClass()
{
    LOG("Freeing CPU Memory!");
    free(leftFrameData);
    free(rightFrameData);
#ifndef RAW_FRAME
    LOG("Freeing GPU Memory!");
    if (isGPUInitialized)
        visionPipeline_terminate();
#endif
};