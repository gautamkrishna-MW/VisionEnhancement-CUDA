//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: visionPipeline.h
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 13-Feb-2023 14:42:18
//

#ifndef VISIONPIPELINE_H
#define VISIONPIPELINE_H

// Include Files
#include "rtwtypes.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void visionPipeline(const unsigned short inputFrame[2108160],
                           const unsigned short whitePatch[518400],
                           const double *gainFactor,
                           unsigned short outFrame[6220800]);

#endif
//
// File trailer for visionPipeline.h
//
// [EOF]
//
