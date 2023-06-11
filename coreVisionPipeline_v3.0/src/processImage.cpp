
#include "processImage.hpp"
#include "coreVisionPipeline.h"
#include "coreVisionPipeline_terminate.h"
#include "coreVisionPipeline_data.h"

#ifndef RAW_FRAME
#include "isFrameSaturated.h"
#include "isFrameSaturated_terminate.h"
#include "isFrameSaturated_data.h"
#endif

processImageClass::processImageClass()
{

    /* Allocate GPU Memory for buffers */
    processImageClass::createFrameBufferArray();

    /* Initialize awbGain values */
    cudaMalloc((void**)&awbGain, 3*sizeof(float));
    float initGain[3] = {2,1,2};
    cudaMemcpy(awbGain, initGain, 3*sizeof(float), cudaMemcpyHostToDevice);
    
    /* Allocate memory and set output frame data pointers */
    processFrameAbstractClass::setLeftFramePtr(leftFrameData);
    processFrameAbstractClass::setRightFramePtr(rightFrameData);
    
    leftFrameData = (uint16_t*)malloc(FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t));
    rightFrameData = (uint16_t*)malloc(FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t));

    cudaMalloc((void**)&devPtr_leftFrameData, FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t));
    cudaMalloc((void**)&devPtr_rightFrameData, FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t));
    cudaMalloc((void**)&devPtr_whiteFrame,FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t));

    leftImageMat = cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16UC3, leftFrameData);
    rightImageMat = cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16UC3, rightFrameData);
}

void processImageClass::createFrameBufferArray()
{
    for (int iter=0; iter<MAXSTREAMS*MAXBUFFERS; iter++)
    {
        cudaHostAlloc((void**)&frBuffArray[iter], (FRAME_HEIGHT+BLACK_EST_ROWS)*FRAME_WIDTH*sizeof(uint16_t), cudaHostAllocMapped);
    }
    processFrameAbstractClass::frameBufferArray = frBuffArray;
}

void processImageClass::processLeftFrame(uint16_t* inpLeftFramePtr, void* userContext)
{
#ifdef RAW_FRAME
    cudaMemcpy(leftFrameData, inpLeftFramePtr, (FRAME_HEIGHT+BLACK_EST_ROWS) * FRAME_WIDTH * sizeof(uint16_t), cudaMemcpyDeviceToHost);
    leftImageMat = cv::Mat((FRAME_HEIGHT+BLACK_EST_ROWS), FRAME_WIDTH, CV_16U, leftFrameData);
#else
    coreVisionPipeline(inpLeftFramePtr, awbGain, false, devPtr_leftFrameData);
    cudaMemcpy(leftFrameData, devPtr_leftFrameData, FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t), cudaMemcpyDeviceToHost);
#endif
    displayImage(leftWindowName.c_str(), leftImageMat);
}

void processImageClass::processRightFrame(uint16_t* inpRightFramePtr, void* userContext)
{
#ifdef RAW_FRAME
    cudaMemcpy(rightFrameData, inpRightFramePtr, (FRAME_HEIGHT+BLACK_EST_ROWS) * FRAME_WIDTH * sizeof(uint16_t), cudaMemcpyDeviceToHost);
    rightImageMat = cv::Mat((FRAME_HEIGHT+BLACK_EST_ROWS), FRAME_WIDTH, CV_16U, rightFrameData);
#else
    coreVisionPipeline(inpRightFramePtr, awbGain, false, devPtr_rightFrameData);
    cudaMemcpy(rightFrameData, devPtr_rightFrameData, FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t), cudaMemcpyDeviceToHost);
#endif
    displayImage(rightWindowName.c_str(), rightImageMat);
}

bool processImageClass::processAWBFrame(uint16_t* rawFramePtr, void* userContext)
{
#ifndef RAW_FRAME
    bool isSaturated = (bool)isFrameSaturated(rawFramePtr);
#else
    bool isSaturated = false;
#endif
    if (!isSaturated)
    {
        uint16_t processedWhiteFrame[FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS];
        
        coreVisionPipeline(rawFramePtr, awbGain, false, devPtr_whiteFrame);
        cudaMemcpy(processedWhiteFrame, devPtr_whiteFrame, FRAME_HEIGHT * FRAME_WIDTH * FRAME_CHANNELS * sizeof(uint16_t), cudaMemcpyDeviceToHost);
        
        displayImage("White Frame", cv::Mat(FRAME_HEIGHT, FRAME_WIDTH, CV_16UC3, processedWhiteFrame));
    }
    cv::destroyWindow("White Frame");
    return isSaturated;
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

    cudaFree(awbGain);
    cudaFree(devPtr_leftFrameData);
    cudaFree(devPtr_rightFrameData);
    cudaFree(devPtr_whiteFrame);

    LOG("Freeing GPU Memory!");
    if (isInitialized_coreVisionPipeline)
        coreVisionPipeline_terminate();

#ifndef RAW_FRAME
    if (isInitialized_isFrameSaturated)
        isFrameSaturated_terminate();
    
    for (int iter=0; iter<MAXSTREAMS*MAXBUFFERS; iter++)
    {
        cudaFree(frameBufferArray[iter]);
    }
#endif
};