//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: isFrameSaturated.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 13-Mar-2023 12:15:40
//

// Include Files
#include "isFrameSaturated.h"
#include "isFrameSaturated_data.h"
#include "isFrameSaturated_initialize.h"
#include "MWAtomicUtility.hpp"
#include "MWCudaDimUtility.hpp"
#include "MWCudaMemoryFunctions.hpp"
#include "MWScanFunctors.h"
#include "MWScanUtility.h"
#include "MWShuffleUtility.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

// Function Declarations
static void checkCudaError(cudaError_t errCode, const char *file,
                           unsigned int b_line);

static __global__ void
isFrameSaturated_kernel1(unsigned long long localHistogram[16384]);

static __global__ void
isFrameSaturated_kernel2(const unsigned short inpFrame[2108160],
                         unsigned long long localHistogram[16384]);

static __global__ void
isFrameSaturated_kernel3(unsigned long long globalHistogram[4096]);

static __global__ void
isFrameSaturated_kernel4(unsigned long long localHistogram[16384],
                         unsigned long long globalHistogram[4096]);

static __global__ void
isFrameSaturated_kernel5(const unsigned long long globalHistogram[4096],
                         unsigned long long cumulativePixDist[4096]);

static __global__ void
isFrameSaturated_kernel6(const unsigned long long cumulativePixDist[4096],
                         boolean_T *isSaturated);

static void raiseCudaError(int errCode, const char *file, unsigned int b_line,
                           const char *errorName, const char *errorString);

// Function Definitions
//
// Arguments    : cudaError_t errCode
//                const char *file
//                unsigned int b_line
// Return Type  : void
//
static void checkCudaError(cudaError_t errCode, const char *file,
                           unsigned int b_line)
{
  if (errCode != cudaSuccess) {
    raiseCudaError(errCode, file, b_line, cudaGetErrorString(errCode),
                   cudaGetErrorName(errCode));
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long localHistogram[16384]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void isFrameSaturated_kernel1(
    unsigned long long localHistogram[16384])
{
  unsigned long long threadId;
  int k;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  k = static_cast<int>(threadId);
  if (k < 16384) {
    //  Compute sizes and declaring constants
    //  Histogram Computation
    //  GPU Codegen: Block-wise histogram computation
    //  Histogram per block is stored in the local histogram matrix
    localHistogram[k] = 0ULL;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short inpFrame[2108160]
//                unsigned long long localHistogram[16384]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void isFrameSaturated_kernel2(
    const unsigned short inpFrame[2108160],
    unsigned long long localHistogram[16384])
{
  unsigned long long threadId;
  int colBlockIter;
  int rowBlockIter;
  int shiftAmount;
  int xexp;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  shiftAmount = static_cast<int>(threadId % 549ULL);
  threadId = (threadId - static_cast<unsigned long long>(shiftAmount)) / 549ULL;
  xexp = static_cast<int>(threadId % 960ULL);
  threadId = (threadId - static_cast<unsigned long long>(xexp)) / 960ULL;
  rowBlockIter = static_cast<int>(threadId % 2ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowBlockIter)) / 2ULL;
  colBlockIter = static_cast<int>(threadId);
  if ((colBlockIter < 2) && (rowBlockIter < 2) && (xexp < 960) &&
      (shiftAmount < 549)) {
    unsigned int u;
    colBlockIter = colBlockIter * 960 + 1;
    rowBlockIter = rowBlockIter * 549 + 1;
    u = inpFrame[((rowBlockIter + shiftAmount) +
                  1098 * ((colBlockIter + xexp) - 1)) -
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
static __global__ __launch_bounds__(512, 1) void isFrameSaturated_kernel3(
    unsigned long long globalHistogram[4096])
{
  unsigned long long threadId;
  int k;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  k = static_cast<int>(threadId);
  if (k < 4096) {
    //  Local histograms are added to create the final global histogram
    globalHistogram[k] = 0ULL;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long localHistogram[16384]
//                unsigned long long globalHistogram[4096]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void isFrameSaturated_kernel4(
    unsigned long long localHistogram[16384],
    unsigned long long globalHistogram[4096])
{
  unsigned long long threadId;
  int colBlockIter;
  int k;
  int rowBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  k = static_cast<int>(threadId % 4096ULL);
  threadId = (threadId - static_cast<unsigned long long>(k)) / 4096ULL;
  rowBlockIter = static_cast<int>(threadId % 2ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowBlockIter)) / 2ULL;
  colBlockIter = static_cast<int>(threadId);
  if ((colBlockIter < 2) && (rowBlockIter < 2) && (k < 4096)) {
    gpu_uint64_atomicAdd(
        &globalHistogram[k],
        localHistogram[(k + (rowBlockIter << 12)) + (colBlockIter << 13)]);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned long long globalHistogram[4096]
//                unsigned long long cumulativePixDist[4096]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void isFrameSaturated_kernel5(
    const unsigned long long globalHistogram[4096],
    unsigned long long cumulativePixDist[4096])
{
  unsigned long long threadId;
  int k;
  int xexp;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  k = static_cast<int>(threadId);
  if (k < 4096) {
    threadId = globalHistogram[k];
    if (threadId == 0ULL) {
      cumulativePixDist[k] = 0ULL;
    } else {
      unsigned long long res;
      frexp(2.10816E+6, &xexp);
      xexp = -31;
      res = threadId / 4527239127367680ULL;
      threadId -= threadId / 4527239127367680ULL * 4527239127367680ULL;
      int exitg1;
      do {
        exitg1 = 0;
        if (xexp < 0) {
          int shiftAmount;
          shiftAmount = -xexp;
          if (shiftAmount > 11) {
            shiftAmount = 11;
          }
          if ((res >> (64 - shiftAmount)) > 0ULL) {
            cumulativePixDist[k] = MAX_uint64_T;
            exitg1 = 1;
          } else {
            unsigned long long t;
            res <<= shiftAmount;
            threadId <<= shiftAmount;
            xexp += shiftAmount;
            t = threadId / 4527239127367680ULL;
            if (MAX_uint64_T - t <= res) {
              cumulativePixDist[k] = MAX_uint64_T;
              exitg1 = 1;
            } else {
              res += t;
              threadId -= threadId / 4527239127367680ULL * 4527239127367680ULL;
            }
          }
        } else {
          if ((threadId << 1) >= 4527239127367680ULL) {
            res++;
          }
          cumulativePixDist[k] = res;
          exitg1 = 1;
        }
      } while (exitg1 == 0);
    }
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned long long cumulativePixDist[4096]
//                boolean_T *isSaturated
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void isFrameSaturated_kernel6(
    const unsigned long long cumulativePixDist[4096], boolean_T *isSaturated)
{
  unsigned long long threadId;
  int k;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  k = static_cast<int>(threadId);
  if (k < 4095) {
    unsigned long long res;
    threadId = cumulativePixDist[k];
    res = threadId + cumulativePixDist[k + 1];
    if (res < threadId) {
      res = MAX_uint64_T;
    }
    *isSaturated =
        ((res >= 4503599627370496ULL) || (res > 0.9) || (*isSaturated));
  }
}

//
// Arguments    : int errCode
//                const char *file
//                unsigned int b_line
//                const char *errorName
//                const char *errorString
// Return Type  : void
//
static void raiseCudaError(int errCode, const char *file, unsigned int b_line,
                           const char *errorName, const char *errorString)
{
  printf("ERR[%d] %s:%s in file %s at line %d\nExiting program execution ...\n",
         errCode, errorName, errorString, file, b_line);
  exit(errCode);
}

//
// GPU Pragmas
//
// Arguments    : const unsigned short inpFrame[2108160]
// Return Type  : boolean_T
//
boolean_T isFrameSaturated(const unsigned short inpFrame[2108160])
{
  unsigned long long(*gpu_localHistogram)[16384];
  unsigned long long(*gpu_cumulativePixDist)[4096];
  unsigned long long(*gpu_globalHistogram)[4096];
  boolean_T isSaturated;
  boolean_T *gpu_isSaturated;
  if (!isInitialized_isFrameSaturated) {
    isFrameSaturated_initialize();
  }
#define CUDACHECK(errCall) checkCudaError(errCall, __FILE__, __LINE__)
  checkCudaError(cudaGetLastError(), __FILE__, __LINE__);
  mwCudaMalloc(&gpu_isSaturated, 1ULL);
  CUDACHECK(cudaGetLastError());
  mwCudaMalloc(&gpu_cumulativePixDist, 32768ULL);
  CUDACHECK(cudaGetLastError());
  mwCudaMalloc(&gpu_globalHistogram, 32768ULL);
  CUDACHECK(cudaGetLastError());
  mwCudaMalloc(&gpu_localHistogram, 131072ULL);
  CUDACHECK(cudaGetLastError());
  //  Compute sizes and declaring constants
  //  Histogram Computation
  //  GPU Codegen: Block-wise histogram computation
  //  Histogram per block is stored in the local histogram matrix
  isFrameSaturated_kernel1<<<dim3(32U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_localHistogram);
  CUDACHECK(cudaGetLastError());
  isFrameSaturated_kernel2<<<dim3(4118U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      inpFrame, *gpu_localHistogram);
  CUDACHECK(cudaGetLastError());
  //  Local histograms are added to create the final global histogram
  isFrameSaturated_kernel3<<<dim3(8U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_globalHistogram);
  CUDACHECK(cudaGetLastError());
  isFrameSaturated_kernel4<<<dim3(32U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_localHistogram, *gpu_globalHistogram);
  CUDACHECK(cudaGetLastError());
  //  Check of the pixels are concentrated in the last K bins
  callThrustScan1D(&(*gpu_globalHistogram)[0], false, 4096);
  isFrameSaturated_kernel5<<<dim3(8U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_globalHistogram, *gpu_cumulativePixDist);
  CUDACHECK(cudaGetLastError());
  isSaturated = false;
  cudaMemcpy(gpu_isSaturated, &isSaturated, 1ULL, cudaMemcpyHostToDevice);
  CUDACHECK(cudaGetLastError());
  isFrameSaturated_kernel6<<<dim3(8U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_cumulativePixDist, gpu_isSaturated);
  CUDACHECK(cudaGetLastError());
  cudaMemcpy(&isSaturated, gpu_isSaturated, 1ULL, cudaMemcpyDeviceToHost);
  CUDACHECK(cudaGetLastError());
  mwCudaFree(&(*gpu_localHistogram)[0]);
  CUDACHECK(cudaGetLastError());
  mwCudaFree(&(*gpu_globalHistogram)[0]);
  CUDACHECK(cudaGetLastError());
  mwCudaFree(&(*gpu_cumulativePixDist)[0]);
  CUDACHECK(cudaGetLastError());
  mwCudaFree(gpu_isSaturated);
  CUDACHECK(cudaGetLastError());
#undef CUDACHECK
  return isSaturated;
}

//
// File trailer for isFrameSaturated.cu
//
// [EOF]
//
