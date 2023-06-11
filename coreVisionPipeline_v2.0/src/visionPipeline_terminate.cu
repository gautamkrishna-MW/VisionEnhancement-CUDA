//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: visionPipeline_terminate.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 24-Feb-2023 21:05:52
//

// Include Files
#include "visionPipeline_terminate.h"
#include "visionPipeline_data.h"
#include "MWMemoryManager.hpp"
#include "stdio.h"

// Function Definitions
//
// Arguments    : void
// Return Type  : void
//
void visionPipeline_terminate()
{
  cudaError_t errCode;
  errCode = cudaGetLastError();
  if (errCode != cudaSuccess) {
    fprintf(stderr, "ERR[%d] %s:%s\n", errCode, cudaGetErrorString(errCode),
            cudaGetErrorName(errCode));
    exit(errCode);
  }
  mwMemoryManagerTerminate();
  isInitialized_gpuMEX = false;
}

//
// File trailer for visionPipeline_terminate.cu
//
// [EOF]
//
