//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: isFrameSaturated_terminate.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 13-Mar-2023 12:15:40
//

// Include Files
#include "isFrameSaturated_terminate.h"
#include "isFrameSaturated_data.h"
#include "MWMemoryManager.hpp"
#include "stdio.h"

// Function Definitions
//
// Arguments    : void
// Return Type  : void
//
void isFrameSaturated_terminate()
{
  cudaError_t errCode;
  errCode = cudaGetLastError();
  if (errCode != cudaSuccess) {
    fprintf(stderr, "ERR[%d] %s:%s\n", errCode, cudaGetErrorString(errCode),
            cudaGetErrorName(errCode));
    exit(errCode);
  }
  mwMemoryManagerTerminate();
  isInitialized_isFrameSaturated = false;
}

//
// File trailer for isFrameSaturated_terminate.cu
//
// [EOF]
//
