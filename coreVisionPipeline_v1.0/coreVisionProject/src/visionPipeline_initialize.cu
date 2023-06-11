//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: visionPipeline_initialize.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 17-Feb-2023 18:05:57
//

// Include Files
#include "visionPipeline_initialize.h"
#include "visionPipeline_data.h"
#include "MWMemoryManager.hpp"

// Function Definitions
//
// Arguments    : void
// Return Type  : void
//
void visionPipeline_initialize()
{
  mwMemoryManagerInit(256U, 0U, 8U, 2048U);
  cudaGetLastError();
  isInitialized_gpuMEX = true;
}

//
// File trailer for visionPipeline_initialize.cu
//
// [EOF]
//
