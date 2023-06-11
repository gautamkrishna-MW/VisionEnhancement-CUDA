//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: isFrameSaturated_initialize.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 13-Mar-2023 12:15:40
//

// Include Files
#include "isFrameSaturated_initialize.h"
#include "isFrameSaturated_data.h"
#include "MWMemoryManager.hpp"

// Function Definitions
//
// Arguments    : void
// Return Type  : void
//
void isFrameSaturated_initialize()
{
  mwMemoryManagerInit(256U, 0U, 8U, 2048U);
  cudaGetLastError();
  isInitialized_isFrameSaturated = true;
}

//
// File trailer for isFrameSaturated_initialize.cu
//
// [EOF]
//
