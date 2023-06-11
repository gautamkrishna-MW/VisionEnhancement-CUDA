//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: coreVisionPipeline_initialize.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 17-Mar-2023 21:49:01
//

// Include Files
#include "coreVisionPipeline_initialize.h"
#include "coreVisionPipeline_data.h"
#include "MWMemoryManager.hpp"

// Function Definitions
//
// Arguments    : void
// Return Type  : void
//
void coreVisionPipeline_initialize()
{
  mwMemoryManagerInit(256U, 0U, 8U, 2048U);
  cudaGetLastError();
  isInitialized_coreVisionPipeline = true;
}

//
// File trailer for coreVisionPipeline_initialize.cu
//
// [EOF]
//
