//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: stg_chkImageSaturation.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 24-Feb-2023 22:32:24
//

// Include Files
#include "stg_chkImageSaturation.h"
#include "stg_chkImageSaturation_data.h"
#include "stg_chkImageSaturation_initialize.h"
#include "MWAtomicUtility.hpp"
#include "MWCudaDimUtility.hpp"
#include "MWCudaMemoryFunctions.hpp"

// Function Declarations
static __global__ void
stg_chkImageSaturation_kernel1(unsigned long long localHistogram[16384]);

static __global__ void
stg_chkImageSaturation_kernel2(const unsigned short inpFrame[2108160],
                               unsigned long long localHistogram[16384]);

static __global__ void
stg_chkImageSaturation_kernel3(unsigned long long globalHistogram[4096]);

static __global__ void
stg_chkImageSaturation_kernel4(unsigned long long localHistogram[16384],
                               unsigned long long globalHistogram[4096]);

static __global__ void
stg_chkImageSaturation_kernel5(const unsigned long long globalHistogram[4096],
                               float *numPixels);

// Function Definitions
//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long localHistogram[16384]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void stg_chkImageSaturation_kernel1(
    unsigned long long localHistogram[16384])
{
  unsigned long long threadId;
  int histIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  histIter = static_cast<int>(threadId);
  if (histIter < 16384) {
    //  Compute sizes and declaring constants
    //  Histogram Computation
    //  GPU Codegen: Block-wise histogram computation
    //  Histogram per block is stored in the local histogram matrix
    localHistogram[histIter] = 0ULL;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short inpFrame[2108160]
//                unsigned long long localHistogram[16384]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void stg_chkImageSaturation_kernel2(
    const unsigned short inpFrame[2108160],
    unsigned long long localHistogram[16384])
{
  unsigned long long threadId;
  int colBlockIter;
  int colIter;
  int rowBlockIter;
  int rowIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  rowIter = static_cast<int>(threadId % 549ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowIter)) / 549ULL;
  colIter = static_cast<int>(threadId % 960ULL);
  threadId = (threadId - static_cast<unsigned long long>(colIter)) / 960ULL;
  rowBlockIter = static_cast<int>(threadId % 2ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowBlockIter)) / 2ULL;
  colBlockIter = static_cast<int>(threadId);
  if ((colBlockIter < 2) && (rowBlockIter < 2) && (colIter < 960) &&
      (rowIter < 549)) {
    unsigned int u;
    colBlockIter = colBlockIter * 960 + 1;
    rowBlockIter = rowBlockIter * 549 + 1;
    u = inpFrame[((rowBlockIter + rowIter) +
                  1098 * ((colBlockIter + colIter) - 1)) -
                 1] +
        1U;
    if (u > 65535U) {
      u = 65535U;
    }
    gpu_uint64_atomicAdd(
        &localHistogram
            [((static_cast<int>(u) +
               ((static_cast<int>(
                     (static_cast<double>(rowBlockIter) - 1.0) / 549.0 + 1.0) -
                 1)
                << 12)) +
              ((static_cast<int>(
                    (static_cast<double>(colBlockIter) - 1.0) / 960.0 + 1.0) -
                1)
               << 13)) -
             1],
        1ULL);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long globalHistogram[4096]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void stg_chkImageSaturation_kernel3(
    unsigned long long globalHistogram[4096])
{
  unsigned long long threadId;
  int histIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  histIter = static_cast<int>(threadId);
  if (histIter < 4096) {
    //  Local histograms are added to create the final global histogram
    globalHistogram[histIter] = 0ULL;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long localHistogram[16384]
//                unsigned long long globalHistogram[4096]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void stg_chkImageSaturation_kernel4(
    unsigned long long localHistogram[16384],
    unsigned long long globalHistogram[4096])
{
  unsigned long long threadId;
  int colBlockIter;
  int histIter;
  int rowBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  histIter = static_cast<int>(threadId % 4096ULL);
  threadId = (threadId - static_cast<unsigned long long>(histIter)) / 4096ULL;
  rowBlockIter = static_cast<int>(threadId % 2ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowBlockIter)) / 2ULL;
  colBlockIter = static_cast<int>(threadId);
  if ((colBlockIter < 2) && (rowBlockIter < 2) && (histIter < 4096)) {
    gpu_uint64_atomicAdd(&globalHistogram[histIter],
                         localHistogram[(histIter + (rowBlockIter << 12)) +
                                        (colBlockIter << 13)]);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned long long globalHistogram[4096]
//                float *numPixels
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void stg_chkImageSaturation_kernel5(
    const unsigned long long globalHistogram[4096], float *numPixels)
{
  unsigned long long threadId;
  int i;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  i = static_cast<int>(threadId);
  if (i < 2) {
    //  Dummy Kernel call
    for (i = 0; i < 5; i++) {
      *numPixels += static_cast<float>(globalHistogram[i + 4091]);
    }
  }
}

//
// GPU Pragmas
//
// Arguments    : const unsigned short inpFrame[2108160]
// Return Type  : boolean_T
//
boolean_T stg_chkImageSaturation(const unsigned short inpFrame[2108160])
{
  unsigned long long(*gpu_localHistogram)[16384];
  unsigned long long(*gpu_globalHistogram)[4096];
  float numPixels;
  float *gpu_numPixels;
  unsigned short(*gpu_inpFrame)[2108160];
  boolean_T isSaturated;
  if (!isInitialized_stg_chkImageSaturation) {
    stg_chkImageSaturation_initialize();
  }
  mwCudaMalloc(&gpu_numPixels, 4ULL);
  mwCudaMalloc(&gpu_globalHistogram, 32768ULL);
  mwCudaMalloc(&gpu_inpFrame, 4216320ULL);
  mwCudaMalloc(&gpu_localHistogram, 131072ULL);
  //  Compute sizes and declaring constants
  //  Histogram Computation
  //  GPU Codegen: Block-wise histogram computation
  //  Histogram per block is stored in the local histogram matrix
  stg_chkImageSaturation_kernel1<<<dim3(32U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_localHistogram);
  cudaMemcpy(*gpu_inpFrame, inpFrame, 4216320ULL, cudaMemcpyHostToDevice);
  stg_chkImageSaturation_kernel2<<<dim3(4118U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_inpFrame, *gpu_localHistogram);
  //  Local histograms are added to create the final global histogram
  stg_chkImageSaturation_kernel3<<<dim3(8U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_globalHistogram);
  stg_chkImageSaturation_kernel4<<<dim3(32U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_localHistogram, *gpu_globalHistogram);
  //  Check of the pixels are concentrated in the last K bins
  numPixels = 0.0F;
  cudaMemcpy(gpu_numPixels, &numPixels, 4ULL, cudaMemcpyHostToDevice);
  stg_chkImageSaturation_kernel5<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
      *gpu_globalHistogram, gpu_numPixels);
  cudaMemcpy(&numPixels, gpu_numPixels, 4ULL, cudaMemcpyDeviceToHost);
  isSaturated = (numPixels / 2.10816E+6F > 0.9);
  mwCudaFree(&(*gpu_localHistogram)[0]);
  mwCudaFree(&(*gpu_inpFrame)[0]);
  mwCudaFree(&(*gpu_globalHistogram)[0]);
  mwCudaFree(gpu_numPixels);
  return isSaturated;
}

//
// File trailer for stg_chkImageSaturation.cu
//
// [EOF]
//
