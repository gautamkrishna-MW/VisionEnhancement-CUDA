//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: stg_chkImageSaturation_terminate.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 21-Feb-2023 16:48:30
//

// Include Files
#include "stg_chkImageSaturation_terminate.h"
#include "stg_chkImageSaturation_data.h"
#include "MWMemoryManager.hpp"
#include "stdio.h"

// Function Definitions
//
// Arguments    : void
// Return Type  : void
//
void stg_chkImageSaturation_terminate()
{
  cudaError_t errCode;
  errCode = cudaGetLastError();
  if (errCode != cudaSuccess) {
    fprintf(stderr, "ERR[%d] %s:%s\n", errCode, cudaGetErrorString(errCode),
            cudaGetErrorName(errCode));
    exit(errCode);
  }
  mwMemoryManagerTerminate();
  isInitialized_stg_chkImageSaturation = false;
}

//
// File trailer for stg_chkImageSaturation_terminate.cu
//
// [EOF]
//
