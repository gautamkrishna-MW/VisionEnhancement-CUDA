//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: coreVisionPipeline.h
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 17-Mar-2023 21:49:01
//

#ifndef COREVISIONPIPELINE_H
#define COREVISIONPIPELINE_H

// Include Files
#include "rtwtypes.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void coreVisionPipeline(const unsigned short inputFrame[2108160],
                               float gainAWB[3], double runAWB,
                               unsigned short processedFrame[6220800]);

#endif
//
// File trailer for coreVisionPipeline.h
//
// [EOF]
//
