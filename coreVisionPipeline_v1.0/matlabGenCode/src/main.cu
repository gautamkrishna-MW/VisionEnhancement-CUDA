//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: main.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 13-Feb-2023 14:42:18
//

/*************************************************************************/
/* This automatically generated example CUDA main file shows how to call */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/

// Include Files
#include "main.h"
#include "visionPipeline.h"
#include "visionPipeline_terminate.h"

#include "time.h";
#include "cuda_runtime.h"
#include <opencv2/opencv.hpp>
using namespace cv;

#include <chrono>
#include <iostream>
using std::chrono::high_resolution_clock;
using std::chrono::duration_cast;
using std::chrono::duration;
using std::chrono::milliseconds;


// Function Declarations
static void argInit_1098x1920_uint16_T(unsigned short result[2108160]);

static void argInit_540x960_uint16_T(unsigned short result[518400]);

static double argInit_real_T();

static unsigned short argInit_uint16_T();

// Function Definitions
//
// Arguments    : unsigned short result[2108160]
// Return Type  : void
//
static void argInit_1098x1920_uint16_T(unsigned short result[2108160])
{
  // Loop over the array to initialize each element.
  for (int i{0}; i < 2108160; i++) {
    // Set the value of the array element.
    // Change this value to the value that the application requires.
    result[i] = argInit_uint16_T();
  }
}

//
// Arguments    : unsigned short result[518400]
// Return Type  : void
//
static void argInit_540x960_uint16_T(unsigned short result[518400])
{
  // Loop over the array to initialize each element.
  for (int i{0}; i < 518400; i++) {
    // Set the value of the array element.
    // Change this value to the value that the application requires.
    result[i] = argInit_uint16_T();
  }
}

//
// Arguments    : void
// Return Type  : double
//
static double argInit_real_T()
{
  return 0.0;
}

//
// Arguments    : void
// Return Type  : unsigned short
//
static unsigned short argInit_uint16_T()
{
  return (unsigned short)rand() % 4096;
}

//
// Arguments    : int argc
//                char **argv
// Return Type  : int
//
int main(int, char **)
{
  // The initialize function is being called automatically from your entry-point
  // function. So, a call to initialize is not included here. Invoke the
  // entry-point functions.
  // You can call entry-point functions multiple times.
  main_visionPipeline();
  // Terminate the application.
  // You do not need to do this more than one time.
  visionPipeline_terminate();
  return 0;
}

//
// Arguments    : void
// Return Type  : void
//
void main_visionPipeline()
{
	/*static unsigned short outFrameLeft[6220800];
	static unsigned short outFrameRight[6220800];
	static unsigned short b[4216320];
	static unsigned short c[518400];*/

	unsigned short* outFrame;
	unsigned short* b;
	unsigned short* c;

	unsigned short* dev_outFrame;
	unsigned short* dev_b;
	unsigned short* dev_c;

	double gainFactor = 340.0;

	outFrame = (unsigned short*)malloc(6220800 * sizeof(unsigned short));
	
	cudaMalloc((void**)&dev_b, 4216320 * sizeof(unsigned short));
	cudaMalloc((void**)&dev_c, 518400 * sizeof(unsigned short));
	cudaMalloc((void**)&dev_outFrame, 6220800 * sizeof(unsigned short));
	
	int tmpPtr = 15;
	int *dev_tmpPtr = nullptr;
	cudaMalloc((void**)&dev_tmpPtr, 1 * sizeof(int));
	cudaMemcpy(dev_tmpPtr, &tmpPtr, 1 * sizeof(int), cudaMemcpyHostToDevice);

	char fileName[100] = { 0 };

	for (int i = 0; i < 45; i++)
	{
#if 1  
		sprintf(fileName, "/home/brain/gautamCodes/visionPipeline/datasetImages/flowerFrames/%0.4d.png", i + 1);
		char whitePatchFile[] = "/home/brain/gautamCodes/visionPipeline/datasetImages/flowerFrames/whitePatch.png";
#else
	
		sprintf(fileName, "/home/brain/gautamCodes/visionPipeline/datasetImages/lymphNode/%0.4d.png", i + 1);
		char whitePatchFile[] = "/home/brain/gautamCodes/visionPipeline/datasetImages/lymphNode/whitePatch.png";
#endif
		Mat inpImg = imread(fileName, IMREAD_ANYDEPTH);
		Mat inpPatch = imread(whitePatchFile, IMREAD_ANYDEPTH);
		
		imshow("OrgImg", inpImg.t() * 16);
		waitKey(10);

		b = (unsigned short*)inpImg.data;
		c = (unsigned short*)inpImg.data;
		
		/* Timings and Code Execution */
		auto tStart = high_resolution_clock::now();

		cudaMemcpy(dev_b, b, 4216320 * sizeof(unsigned short), cudaMemcpyHostToDevice);
		cudaMemcpy(dev_c, c, 518400 * sizeof(unsigned short), cudaMemcpyHostToDevice);
		
		auto tChkPt1 = high_resolution_clock::now();

		visionPipeline(dev_b, dev_c, &gainFactor, dev_outFrame);

		auto tChkPt2 = high_resolution_clock::now();

		cudaMemcpy(outFrame, dev_outFrame, 6220800 * sizeof(unsigned short), cudaMemcpyDeviceToHost);
		
		auto tStop = high_resolution_clock::now();

		auto memcpyH2D = duration_cast<milliseconds>(tChkPt1 - tStart);
		auto funExec = duration_cast<milliseconds>(tChkPt2 - tChkPt1);
		auto memcpyD2H = duration_cast<milliseconds>(tStop - tChkPt2);

		std::cout << "Memcpy H2D Time: " << memcpyH2D.count() << "ms\n";
		std::cout << "Func Exec Time: " << funExec.count() << "ms\n";
		std::cout << "Memcpy D2H Time: " << memcpyD2H.count() << "ms\n";
		std::cout << "Total Time: " << memcpyD2H.count() + funExec.count() + memcpyH2D.count() << "ms\n";
		std::cout << "\n\n" << std::endl;

		/* Display Frame */
		Mat outMat;
		Mat frameRGB[3];
		frameRGB[2] = Mat(1920, 1080, CV_16U, outFrame);
		frameRGB[1] = Mat(1920, 1080, CV_16U, outFrame + (1920 * 1080));
		frameRGB[0] = Mat(1920, 1080, CV_16U, outFrame + (1920 * 1080 * 2));
		merge(frameRGB, 3, outMat);
		imshow("OutMat", outMat.t() * 16);
		waitKey(10);
	}
}

//
// File trailer for main.cu
//
// [EOF]
//
