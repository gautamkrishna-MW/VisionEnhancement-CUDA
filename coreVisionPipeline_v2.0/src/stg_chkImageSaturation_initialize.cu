//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: stg_chkImageSaturation_initialize.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 24-Feb-2023 22:32:24
//

// Include Files
#include "stg_chkImageSaturation_initialize.h"
#include "stg_chkImageSaturation_data.h"
#include "MWMemoryManager.hpp"

// Function Definitions
//
// Arguments    : void
// Return Type  : void
//
void stg_chkImageSaturation_initialize()
{
  mwMemoryManagerInit(256U, 0U, 8U, 2048U);
  cudaGetLastError();
  isInitialized_stg_chkImageSaturation = true;
}

//
// File trailer for stg_chkImageSaturation_initialize.cu
//
// [EOF]
//
