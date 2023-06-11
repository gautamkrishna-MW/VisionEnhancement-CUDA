//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: coreVisionPipeline_terminate.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 17-Mar-2023 21:49:01
//

// Include Files
#include "coreVisionPipeline_terminate.h"
#include "coreVisionPipeline_data.h"
#include "MWMemoryManager.hpp"
#include "stdio.h"

// Function Definitions
//
// Arguments    : void
// Return Type  : void
//
void coreVisionPipeline_terminate()
{
  cudaError_t errCode;
  errCode = cudaGetLastError();
  if (errCode != cudaSuccess) {
    fprintf(stderr, "ERR[%d] %s:%s\n", errCode, cudaGetErrorString(errCode),
            cudaGetErrorName(errCode));
    exit(errCode);
  }
  mwMemoryManagerTerminate();
  isInitialized_coreVisionPipeline = false;
}

//
// File trailer for coreVisionPipeline_terminate.cu
//
// [EOF]
//
