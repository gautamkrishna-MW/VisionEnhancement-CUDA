//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: coreVisionPipeline.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 17-Mar-2023 21:49:01
//

// Include Files
#include "coreVisionPipeline.h"
#include "coreVisionPipeline_data.h"
#include "coreVisionPipeline_initialize.h"
#include "MWAtomicUtility.hpp"
#include "MWCudaDimUtility.hpp"
#include "MWCudaMemoryFunctions.hpp"
#include "MWScanFunctors.h"
#include "MWScanUtility.h"
#include "MWShuffleUtility.h"
#include "MWTransposeUtility.hpp"
#include "thrust/sort.h"

// Function Declarations
static __device__ float atomicOpreal32_T(float *address, float value);

static __device__ unsigned int atomicOpuint32_T(unsigned int *address,
                                                unsigned int value);

static __global__ void coder_reduce0(const float inputVar[527040],
                                     float *outputVar);

static __global__ void coder_reduce1(const float inputVar[527040],
                                     float *outputVar);

static __global__ void coder_reduce2(const float inputVar[527040],
                                     float *outputVar);

static __global__ void coder_reduce3(const unsigned short inputVar[19200],
                                     unsigned int *outputVar);

static __global__ void
coreVisionPipeline_kernel1(const unsigned short inputFrame[2108160],
                           float gMat[527040], float bMat[527040],
                           float rMat[527040]);

static __global__ void
coreVisionPipeline_kernel10(const unsigned short varargout_4[2073600],
                            const unsigned short varargout_5[2073600],
                            const unsigned short varargout_3[2073600],
                            const unsigned short varargout_2[2073600],
                            const unsigned short varargout_1[2073600],
                            unsigned short stg2OutFrame[6220800]);

static __global__ void
coreVisionPipeline_kernel11(const unsigned short stg2OutFrame[6220800],
                            unsigned short stg3OutFrame[6220800]);

static __global__ void
coreVisionPipeline_kernel12(const unsigned short stg2OutFrame[6220800],
                            unsigned short stg3OutFrame[6220800]);

static __global__ void
coreVisionPipeline_kernel13(const float gainAWB[3],
                            unsigned short stg1OutFrame[2073600],
                            unsigned short stg3OutFrame[6220800]);

static __global__ void
coreVisionPipeline_kernel14(unsigned long long localHistogram[16384]);

static __global__ void
coreVisionPipeline_kernel15(const unsigned short stg1OutFrame[2073600],
                            unsigned long long localHistogram[16384]);

static __global__ void
coreVisionPipeline_kernel16(unsigned long long globalHistogram[4096]);

static __global__ void
coreVisionPipeline_kernel17(unsigned long long localHistogram[16384],
                            unsigned long long globalHistogram[4096]);

static __global__ void
coreVisionPipeline_kernel18(const unsigned long long globalHistogram[4096],
                            int *bin99Percent, int *bin1Percent);

static __global__ void
coreVisionPipeline_kernel19(const int *bin99Percent, const int *bin1Percent,
                            unsigned short stg3OutFrame[6220800]);

static __global__ void coreVisionPipeline_kernel2(const float rMat[527040],
                                                  float *b);

static __global__ void
coreVisionPipeline_kernel20(const unsigned short stg3OutFrame[6220800],
                            unsigned short stg1OutFrame[2073600]);

static __global__ void
coreVisionPipeline_kernel21(const unsigned short stg3OutFrame[6220800],
                            unsigned short stg1OutFrame[2073600]);

static __global__ void
coreVisionPipeline_kernel22(const unsigned short stg3OutFrame[6220800],
                            unsigned short stg1OutFrame[2073600]);

static __global__ void
coreVisionPipeline_kernel23(const unsigned short outImgB[2073600],
                            const unsigned short outImgG[2073600],
                            const unsigned short outImgR[2073600],
                            unsigned short processedFrame[6220800]);

static __global__ void coreVisionPipeline_kernel3(const float gMat[527040],
                                                  float *b);

static __global__ void coreVisionPipeline_kernel4(const float bMat[527040],
                                                  float *b);

static __global__ void coreVisionPipeline_kernel5(float gainAWB[3]);

static __global__ void coreVisionPipeline_kernel6(const float meanBChannel,
                                                  const float meanGChannel,
                                                  const float meanRChannel,
                                                  float gainAWB[3]);

static __global__ void
coreVisionPipeline_kernel7(const unsigned short outFrameColMajor[2108160],
                           unsigned short inputArray[19200]);

static __global__ void
coreVisionPipeline_kernel8(const unsigned short inputArray[19200],
                           unsigned int *outputVar);

static __global__ void
coreVisionPipeline_kernel9(const float meanRChannel,
                           const unsigned short outFrameColMajor[2108160],
                           unsigned short stg1OutFrame[2073600]);

static __device__ float shflDown1(float in1, unsigned int offset,
                                  unsigned int mask);

static __device__ unsigned int shflDown1(unsigned int in1, unsigned int offset,
                                         unsigned int mask);

static __global__ void stencilKernel(const unsigned short input[2073600],
                                     unsigned short paddingValue,
                                     unsigned short output[2073600],
                                     unsigned short b_output[2073600],
                                     unsigned short c_output[2073600],
                                     unsigned short d_output[2073600],
                                     unsigned short e_output[2073600]);

static __device__ float threadGroupReduction(float val, unsigned int lane,
                                             unsigned int mask);

static __device__ unsigned int
threadGroupReduction(unsigned int val, unsigned int lane, unsigned int mask);

static __device__ unsigned int workGroupReduction(unsigned int val,
                                                  unsigned int mask,
                                                  unsigned int numActiveWarps);

static __device__ float workGroupReduction(float val, unsigned int mask,
                                           unsigned int numActiveWarps);

// Function Definitions
//
// Arguments    : float *address
//                float value
// Return Type  : float
//
static __device__ float atomicOpreal32_T(float *address, float value)
{
  unsigned int old;
  unsigned int *address_as_up;
  address_as_up = (unsigned int *)address;
  old = *address_as_up;
  float input2;
  unsigned int assumed;
  do {
    assumed = old;
    input2 = __uint_as_float(old);
    //  Helper function
    old = atomicCAS(address_as_up, old, __float_as_uint(value + input2));
  } while (assumed != old);
  return __uint_as_float(old);
}

//
// Arguments    : unsigned int *address
//                unsigned int value
// Return Type  : unsigned int
//
static __device__ unsigned int atomicOpuint32_T(unsigned int *address,
                                                unsigned int value)
{
  unsigned int output;
  output = *address;
  unsigned int assumed;
  unsigned int red;
  do {
    assumed = output;
    //  Helper function
    red = value + output;
    if (red < value) {
      red = MAX_uint32_T;
    }
    output = atomicCAS(address, output, red);
  } while (assumed != output);
  return output;
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float inputVar[527040]
//                float *outputVar
// Return Type  : void
//
static __global__
    __launch_bounds__(1024, 1) void coder_reduce0(const float inputVar[527040],
                                                  float *outputVar)
{
  float input1;
  unsigned int blockStride;
  unsigned int m;
  unsigned int thBlkId;
  unsigned int threadId;
  unsigned int threadStride;
  threadStride = static_cast<unsigned int>(mwGetTotalThreadsLaunched());
  threadId = static_cast<unsigned int>(mwGetGlobalThreadIndex());
  thBlkId = static_cast<unsigned int>(mwGetThreadIndexWithinBlock());
  blockStride = static_cast<unsigned int>(mwGetThreadsPerBlock());
  if (static_cast<unsigned int>(mwGetBlockIndex()) == 527039U / blockStride) {
    m = 527039U % blockStride;
    if (m > 0U) {
      blockStride = m;
    }
  }
  blockStride = ((blockStride + warpSize) - 1U) / warpSize;
  if (threadId <= 527038U) {
    input1 = inputVar[threadId];
  }
  m = __ballot_sync(MAX_uint32_T, threadId <= 527038U);
  for (unsigned int idx{threadId + threadStride}; idx <= 527038U;
       idx += threadStride) {
    float input2;
    input2 = inputVar[idx];
    //  Helper function
    input1 += input2;
  }
  input1 = workGroupReduction(input1, m, blockStride);
  if ((threadId <= 527038U) && (thBlkId == 0U)) {
    atomicOpreal32_T(&outputVar[0], input1);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float inputVar[527040]
//                float *outputVar
// Return Type  : void
//
static __global__
    __launch_bounds__(1024, 1) void coder_reduce1(const float inputVar[527040],
                                                  float *outputVar)
{
  float input1;
  unsigned int blockStride;
  unsigned int m;
  unsigned int thBlkId;
  unsigned int threadId;
  unsigned int threadStride;
  threadStride = static_cast<unsigned int>(mwGetTotalThreadsLaunched());
  threadId = static_cast<unsigned int>(mwGetGlobalThreadIndex());
  thBlkId = static_cast<unsigned int>(mwGetThreadIndexWithinBlock());
  blockStride = static_cast<unsigned int>(mwGetThreadsPerBlock());
  if (static_cast<unsigned int>(mwGetBlockIndex()) == 527039U / blockStride) {
    m = 527039U % blockStride;
    if (m > 0U) {
      blockStride = m;
    }
  }
  blockStride = ((blockStride + warpSize) - 1U) / warpSize;
  if (threadId <= 527038U) {
    input1 = inputVar[threadId];
  }
  m = __ballot_sync(MAX_uint32_T, threadId <= 527038U);
  for (unsigned int idx{threadId + threadStride}; idx <= 527038U;
       idx += threadStride) {
    float input2;
    input2 = inputVar[idx];
    //  Helper function
    input1 += input2;
  }
  input1 = workGroupReduction(input1, m, blockStride);
  if ((threadId <= 527038U) && (thBlkId == 0U)) {
    atomicOpreal32_T(&outputVar[0], input1);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float inputVar[527040]
//                float *outputVar
// Return Type  : void
//
static __global__
    __launch_bounds__(1024, 1) void coder_reduce2(const float inputVar[527040],
                                                  float *outputVar)
{
  float input1;
  unsigned int blockStride;
  unsigned int m;
  unsigned int thBlkId;
  unsigned int threadId;
  unsigned int threadStride;
  threadStride = static_cast<unsigned int>(mwGetTotalThreadsLaunched());
  threadId = static_cast<unsigned int>(mwGetGlobalThreadIndex());
  thBlkId = static_cast<unsigned int>(mwGetThreadIndexWithinBlock());
  blockStride = static_cast<unsigned int>(mwGetThreadsPerBlock());
  if (static_cast<unsigned int>(mwGetBlockIndex()) == 527039U / blockStride) {
    m = 527039U % blockStride;
    if (m > 0U) {
      blockStride = m;
    }
  }
  blockStride = ((blockStride + warpSize) - 1U) / warpSize;
  if (threadId <= 527038U) {
    input1 = inputVar[threadId];
  }
  m = __ballot_sync(MAX_uint32_T, threadId <= 527038U);
  for (unsigned int idx{threadId + threadStride}; idx <= 527038U;
       idx += threadStride) {
    float input2;
    input2 = inputVar[idx];
    //  Helper function
    input1 += input2;
  }
  input1 = workGroupReduction(input1, m, blockStride);
  if ((threadId <= 527038U) && (thBlkId == 0U)) {
    atomicOpreal32_T(&outputVar[0], input1);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short inputVar[19200]
//                unsigned int *outputVar
// Return Type  : void
//
static __global__ __launch_bounds__(1024, 1) void coder_reduce3(
    const unsigned short inputVar[19200], unsigned int *outputVar)
{
  unsigned int blockStride;
  unsigned int m;
  unsigned int thBlkId;
  unsigned int threadId;
  unsigned int threadStride;
  unsigned int tmpRed0;
  threadStride = static_cast<unsigned int>(mwGetTotalThreadsLaunched());
  threadId = static_cast<unsigned int>(mwGetGlobalThreadIndex());
  thBlkId = static_cast<unsigned int>(mwGetThreadIndexWithinBlock());
  blockStride = static_cast<unsigned int>(mwGetThreadsPerBlock());
  if (static_cast<unsigned int>(mwGetBlockIndex()) == 19199U / blockStride) {
    m = 19199U % blockStride;
    if (m > 0U) {
      blockStride = m;
    }
  }
  blockStride = ((blockStride + warpSize) - 1U) / warpSize;
  if (threadId <= 19198U) {
    unsigned short input1;
    input1 = inputVar[threadId];
    tmpRed0 = input1;
  }
  m = __ballot_sync(MAX_uint32_T, threadId <= 19198U);
  for (unsigned int idx{threadId + threadStride}; idx <= 19198U;
       idx += threadStride) {
    unsigned int b_input1;
    int input2;
    b_input1 = tmpRed0;
    input2 = inputVar[idx];
    //  Helper function
    tmpRed0 += static_cast<unsigned int>(input2);
    if (tmpRed0 < b_input1) {
      tmpRed0 = MAX_uint32_T;
    }
  }
  tmpRed0 = workGroupReduction(tmpRed0, m, blockStride);
  if ((threadId <= 19198U) && (thBlkId == 0U)) {
    atomicOpuint32_T(&outputVar[0], tmpRed0);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short inputFrame[2108160]
//                float gMat[527040]
//                float bMat[527040]
//                float rMat[527040]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel1(
    const unsigned short inputFrame[2108160], float gMat[527040],
    float bMat[527040], float rMat[527040])
{
  unsigned long long threadId;
  int colIter;
  int rowIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  rowIter = static_cast<int>(threadId % 275ULL);
  colIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(rowIter)) / 275ULL);
  if ((colIter < 481) && (rowIter < 275)) {
    double histCol;
    int colBlockIter;
    unsigned int qY;
    colBlockIter = (colIter << 1) + 480;
    histCol = static_cast<double>(rowIter) * 2.0 + 274.5;
    colIter = static_cast<int>(floor((histCol - 274.5) / 2.0));
    rowIter = static_cast<int>(
        floor((static_cast<double>(colBlockIter) - 480.0) / 2.0));
    rMat[colIter + 549 * rowIter] = inputFrame
        [(static_cast<int>(floor(histCol)) + 1098 * (colBlockIter - 1)) - 1];
    bMat[colIter + 549 * rowIter] =
        inputFrame[static_cast<int>(floor(histCol)) + 1098 * colBlockIter];
    qY =
        static_cast<unsigned int>(inputFrame[(static_cast<int>(floor(histCol)) +
                                              1098 * colBlockIter) -
                                             1]) +
        inputFrame[static_cast<int>(floor(histCol)) +
                   1098 * (colBlockIter - 1)];
    if (qY > 65535U) {
      qY = 65535U;
    }
    gMat[colIter + 549 * rowIter] = static_cast<float>(qY);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short varargout_4[2073600]
//                const unsigned short varargout_5[2073600]
//                const unsigned short varargout_3[2073600]
//                const unsigned short varargout_2[2073600]
//                const unsigned short varargout_1[2073600]
//                unsigned short stg2OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel10(
    const unsigned short varargout_4[2073600],
    const unsigned short varargout_5[2073600],
    const unsigned short varargout_3[2073600],
    const unsigned short varargout_2[2073600],
    const unsigned short varargout_1[2073600],
    unsigned short stg2OutFrame[6220800])
{
  unsigned long long threadId;
  int chIter;
  int colIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  chIter = static_cast<int>(threadId % 540ULL);
  colIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(chIter)) / 540ULL);
  if ((colIter < 960) && (chIter < 540)) {
    int colBlockIter;
    int rowIter;
    colBlockIter = (colIter << 1) + 1;
    rowIter = (chIter << 1) + 1;
    stg2OutFrame[(rowIter + 1080 * (colBlockIter - 1)) - 1] =
        varargout_1[(rowIter + 1080 * (colBlockIter - 1)) - 1];
    stg2OutFrame[(rowIter + 1080 * (colBlockIter - 1)) + 2073599] =
        varargout_2[(rowIter + 1080 * (colBlockIter - 1)) - 1];
    stg2OutFrame[(rowIter + 1080 * (colBlockIter - 1)) + 4147199] =
        varargout_3[(rowIter + 1080 * (colBlockIter - 1)) - 1];
    stg2OutFrame[rowIter + 1080 * (colBlockIter - 1)] =
        varargout_5[rowIter + 1080 * (colBlockIter - 1)];
    stg2OutFrame[(rowIter + 1080 * (colBlockIter - 1)) + 2073600] =
        varargout_1[rowIter + 1080 * (colBlockIter - 1)];
    stg2OutFrame[(rowIter + 1080 * (colBlockIter - 1)) + 4147200] =
        varargout_4[rowIter + 1080 * (colBlockIter - 1)];
    colBlockIter = (colIter << 1) + 1;
    rowIter = (chIter << 1) + 1;
    stg2OutFrame[(rowIter + 1080 * colBlockIter) - 1] =
        varargout_4[(rowIter + 1080 * colBlockIter) - 1];
    stg2OutFrame[(rowIter + 1080 * colBlockIter) + 2073599] =
        varargout_1[(rowIter + 1080 * colBlockIter) - 1];
    stg2OutFrame[(rowIter + 1080 * colBlockIter) + 4147199] =
        varargout_5[(rowIter + 1080 * colBlockIter) - 1];
    stg2OutFrame[rowIter + 1080 * colBlockIter] =
        varargout_3[rowIter + 1080 * colBlockIter];
    stg2OutFrame[(rowIter + 1080 * colBlockIter) + 2073600] =
        varargout_2[rowIter + 1080 * colBlockIter];
    stg2OutFrame[(rowIter + 1080 * colBlockIter) + 4147200] =
        varargout_1[rowIter + 1080 * colBlockIter];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg2OutFrame[6220800]
//                unsigned short stg3OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel11(
    const unsigned short stg2OutFrame[6220800],
    unsigned short stg3OutFrame[6220800])
{
  unsigned long long threadId;
  int colBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  colBlockIter = static_cast<int>(threadId);
  if (colBlockIter < 6220800) {
    //  GRBG = [(4,1,5)->(1,1), (1,2,3)->(1,2); (3,2,1)->(2,1), (5,1,4)->(2,2)]
    //  Despeckle
    //  Despeckle Algorithm Caller
    stg3OutFrame[colBlockIter] = stg2OutFrame[colBlockIter];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg2OutFrame[6220800]
//                unsigned short stg3OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel12(
    const unsigned short stg2OutFrame[6220800],
    unsigned short stg3OutFrame[6220800])
{
  unsigned long long threadId;
  int chIter;
  int colIter;
  int rowIter;
  unsigned short winMat[10];
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  rowIter = static_cast<int>(threadId % 1078ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowIter)) / 1078ULL;
  colIter = static_cast<int>(threadId % 1918ULL);
  threadId = (threadId - static_cast<unsigned long long>(colIter)) / 1918ULL;
  chIter = static_cast<int>(threadId);
  if ((chIter < 3) && (colIter < 1918) && (rowIter < 1078)) {
    winMat[0] = stg2OutFrame[(rowIter + 1080 * colIter) + 2073600 * chIter];
    winMat[1] =
        stg2OutFrame[(rowIter + 1080 * (colIter + 1)) + 2073600 * chIter];
    winMat[2] =
        stg2OutFrame[(rowIter + 1080 * (colIter + 2)) + 2073600 * chIter];
    winMat[3] =
        stg2OutFrame[((rowIter + 1080 * colIter) + 2073600 * chIter) + 1];
    winMat[4] =
        stg2OutFrame[((rowIter + 1080 * (colIter + 1)) + 2073600 * chIter) + 1];
    winMat[5] =
        stg2OutFrame[((rowIter + 1080 * (colIter + 2)) + 2073600 * chIter) + 1];
    winMat[6] =
        stg2OutFrame[((rowIter + 1080 * colIter) + 2073600 * chIter) + 2];
    winMat[7] =
        stg2OutFrame[((rowIter + 1080 * (colIter + 1)) + 2073600 * chIter) + 2];
    winMat[8] =
        stg2OutFrame[((rowIter + 1080 * (colIter + 2)) + 2073600 * chIter) + 2];
    winMat[9] = 0U;
    for (int iter{0}; iter < 5; iter++) {
      int b_colBlockIter;
      b_colBlockIter = 8 - iter;
      for (int rowBlockIter{0}; rowBlockIter < b_colBlockIter; rowBlockIter++) {
        int colBlockIter;
        colBlockIter = (iter + rowBlockIter) + 2;
        if (winMat[iter] > winMat[colBlockIter - 1]) {
          unsigned short t;
          t = winMat[iter];
          winMat[iter] = winMat[colBlockIter - 1];
          winMat[colBlockIter - 1] = t;
        }
      }
    }
    stg3OutFrame[((rowIter + 1080 * (colIter + 1)) + 2073600 * chIter) + 1] =
        winMat[4];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float gainAWB[3]
//                unsigned short stg1OutFrame[2073600]
//                unsigned short stg3OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel13(
    const float gainAWB[3], unsigned short stg1OutFrame[2073600],
    unsigned short stg3OutFrame[6220800])
{
  unsigned long long threadId;
  int colIter;
  int rowIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  rowIter = static_cast<int>(threadId % 1080ULL);
  colIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(rowIter)) / 1080ULL);
  if ((colIter < 1920) && (rowIter < 1080)) {
    float maxVal;
    unsigned short t;
    unsigned short u;
    unsigned short u2;
    maxVal = roundf(static_cast<float>(stg3OutFrame[rowIter + 1080 * colIter]) *
                    gainAWB[0]);
    if (maxVal < 65536.0F) {
      if (maxVal >= 0.0F) {
        t = static_cast<unsigned short>(maxVal);
      } else {
        t = 0U;
      }
    } else if (maxVal >= 65536.0F) {
      t = MAX_uint16_T;
    } else {
      t = 0U;
    }
    if (t >= 4095) {
      u = 4095U;
    } else {
      u = t;
    }
    stg3OutFrame[rowIter + 1080 * colIter] = u;
    maxVal = roundf(
        static_cast<float>(stg3OutFrame[(rowIter + 1080 * colIter) + 2073600]) *
        gainAWB[1]);
    if (maxVal < 65536.0F) {
      if (maxVal >= 0.0F) {
        t = static_cast<unsigned short>(maxVal);
      } else {
        t = 0U;
      }
    } else if (maxVal >= 65536.0F) {
      t = MAX_uint16_T;
    } else {
      t = 0U;
    }
    if (t >= 4095) {
      u2 = 4095U;
    } else {
      u2 = t;
    }
    stg3OutFrame[(rowIter + 1080 * colIter) + 2073600] = u2;
    maxVal = roundf(
        static_cast<float>(stg3OutFrame[(rowIter + 1080 * colIter) + 4147200]) *
        gainAWB[2]);
    if (maxVal < 65536.0F) {
      if (maxVal >= 0.0F) {
        t = static_cast<unsigned short>(maxVal);
      } else {
        t = 0U;
      }
    } else if (maxVal >= 65536.0F) {
      t = MAX_uint16_T;
    } else {
      t = 0U;
    }
    if (t >= 4095) {
      t = 4095U;
    }
    stg3OutFrame[(rowIter + 1080 * colIter) + 4147200] = t;
    u = static_cast<unsigned short>(roundf(
        (0.2126F * static_cast<float>(u) + 0.7152F * static_cast<float>(u2)) +
        0.0722F * static_cast<float>(t)));
    stg1OutFrame[rowIter + 1080 * colIter] = u;
    if (u > 4095) {
      stg1OutFrame[rowIter + 1080 * colIter] = 4095U;
    }
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long localHistogram[16384]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel14(
    unsigned long long localHistogram[16384])
{
  unsigned long long threadId;
  int colBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  colBlockIter = static_cast<int>(threadId);
  if (colBlockIter < 16384) {
    //  Histogram Computation
    //  GPU Codegen: Block-wise histogram computation
    //  Histogram per block is stored in the local histogram matrix
    localHistogram[colBlockIter] = 0ULL;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg1OutFrame[2073600]
//                unsigned long long localHistogram[16384]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel15(
    const unsigned short stg1OutFrame[2073600],
    unsigned long long localHistogram[16384])
{
  unsigned long long threadId;
  int chIter;
  int colBlockIter;
  int colIter;
  int rowIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  rowIter = static_cast<int>(threadId % 540ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowIter)) / 540ULL;
  colIter = static_cast<int>(threadId % 960ULL);
  threadId = (threadId - static_cast<unsigned long long>(colIter)) / 960ULL;
  chIter = static_cast<int>(threadId % 2ULL);
  threadId = (threadId - static_cast<unsigned long long>(chIter)) / 2ULL;
  colBlockIter = static_cast<int>(threadId);
  if ((colBlockIter < 2) && (chIter < 2) && (colIter < 960) &&
      (rowIter < 540)) {
    unsigned int qY;
    colBlockIter = colBlockIter * 960 + 1;
    chIter = chIter * 540 + 1;
    qY = stg1OutFrame[((chIter + rowIter) +
                       1080 * ((colBlockIter + colIter) - 1)) -
                      1] +
         1U;
    if (qY > 65535U) {
      qY = 65535U;
    }
    gpu_uint64_atomicAdd(
        &localHistogram
            [((static_cast<int>(qY) +
               ((static_cast<int>((static_cast<double>(chIter) - 1.0) / 540.0 +
                                  1.0) -
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
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel16(
    unsigned long long globalHistogram[4096])
{
  unsigned long long threadId;
  int colBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  colBlockIter = static_cast<int>(threadId);
  if (colBlockIter < 4096) {
    //  Local histograms are added to create the final global histogram
    globalHistogram[colBlockIter] = 0ULL;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long localHistogram[16384]
//                unsigned long long globalHistogram[4096]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel17(
    unsigned long long localHistogram[16384],
    unsigned long long globalHistogram[4096])
{
  unsigned long long threadId;
  int chIter;
  int colBlockIter;
  int rowBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  chIter = static_cast<int>(threadId % 4096ULL);
  threadId = (threadId - static_cast<unsigned long long>(chIter)) / 4096ULL;
  rowBlockIter = static_cast<int>(threadId % 2ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowBlockIter)) / 2ULL;
  colBlockIter = static_cast<int>(threadId);
  if ((colBlockIter < 2) && (rowBlockIter < 2) && (chIter < 4096)) {
    gpu_uint64_atomicAdd(
        &globalHistogram[chIter],
        localHistogram[(chIter + (rowBlockIter << 12)) + (colBlockIter << 13)]);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned long long globalHistogram[4096]
//                int *bin99Percent
//                int *bin1Percent
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel18(
    const unsigned long long globalHistogram[4096], int *bin99Percent,
    int *bin1Percent)
{
  unsigned long long threadId;
  int iter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  iter = static_cast<int>(threadId);
  if (iter < 4095) {
    threadId = globalHistogram[iter];
    if ((threadId < 207360ULL) && (globalHistogram[iter + 1] >= 207360ULL)) {
      *bin1Percent = iter + 2;
    }
    if ((threadId < 2052864ULL) && (globalHistogram[iter + 1] >= 2052864ULL)) {
      *bin99Percent = iter + 2;
    }
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const int *bin99Percent
//                const int *bin1Percent
//                unsigned short stg3OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel19(
    const int *bin99Percent, const int *bin1Percent,
    unsigned short stg3OutFrame[6220800])
{
  unsigned long long threadId;
  int chIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  chIter = static_cast<int>(threadId);
  if (chIter < 6220800) {
    float maxVal;
    int colBlockIter;
    unsigned short u;
    //  Applying pixel gains
    u = stg3OutFrame[chIter];
    colBlockIter = u - *bin1Percent;
    if (colBlockIter < 0) {
      colBlockIter = 0;
    }
    maxVal = roundf(static_cast<float>((u > *bin1Percent) * colBlockIter) *
                    4095.0F / static_cast<float>(*bin99Percent - *bin1Percent));
    if (maxVal < 65536.0F) {
      if (maxVal >= 0.0F) {
        u = static_cast<unsigned short>(maxVal);
      } else {
        u = 0U;
      }
    } else if (maxVal >= 65536.0F) {
      u = MAX_uint16_T;
    } else {
      u = 0U;
    }
    if (u < 4095) {
      stg3OutFrame[chIter] = u;
    } else {
      stg3OutFrame[chIter] = 4095U;
    }
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float rMat[527040]
//                float *b
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void coreVisionPipeline_kernel2(
    const float rMat[527040], float *b)
{
  unsigned long long threadId;
  int indV;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  indV = static_cast<int>(threadId);
  if (indV < 1) {
    *b = rMat[527039];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg3OutFrame[6220800]
//                unsigned short stg1OutFrame[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel20(
    const unsigned short stg3OutFrame[6220800],
    unsigned short stg1OutFrame[2073600])
{
  unsigned long long threadId;
  int chIter;
  int colBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  chIter = static_cast<int>(threadId % 1080ULL);
  colBlockIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(chIter)) / 1080ULL);
  if ((colBlockIter < 1920) && (chIter < 1080)) {
    stg1OutFrame[chIter + 1080 * colBlockIter] =
        stg3OutFrame[chIter + 1080 * colBlockIter];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg3OutFrame[6220800]
//                unsigned short stg1OutFrame[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel21(
    const unsigned short stg3OutFrame[6220800],
    unsigned short stg1OutFrame[2073600])
{
  unsigned long long threadId;
  int chIter;
  int colBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  chIter = static_cast<int>(threadId % 1080ULL);
  colBlockIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(chIter)) / 1080ULL);
  if ((colBlockIter < 1920) && (chIter < 1080)) {
    stg1OutFrame[chIter + 1080 * colBlockIter] =
        stg3OutFrame[(chIter + 1080 * colBlockIter) + 2073600];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg3OutFrame[6220800]
//                unsigned short stg1OutFrame[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel22(
    const unsigned short stg3OutFrame[6220800],
    unsigned short stg1OutFrame[2073600])
{
  unsigned long long threadId;
  int chIter;
  int colBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  chIter = static_cast<int>(threadId % 1080ULL);
  colBlockIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(chIter)) / 1080ULL);
  if ((colBlockIter < 1920) && (chIter < 1080)) {
    stg1OutFrame[chIter + 1080 * colBlockIter] =
        stg3OutFrame[(chIter + 1080 * colBlockIter) + 4147200];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short outImgB[2073600]
//                const unsigned short outImgG[2073600]
//                const unsigned short outImgR[2073600]
//                unsigned short processedFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel23(
    const unsigned short outImgB[2073600],
    const unsigned short outImgG[2073600],
    const unsigned short outImgR[2073600],
    unsigned short processedFrame[6220800])
{
  unsigned long long threadId;
  int chIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  chIter = static_cast<int>(threadId);
  if (chIter < 2073600) {
    processedFrame[3 * (chIter + 1) - 1] = outImgR[chIter];
    processedFrame[3 * (chIter + 1) - 2] = outImgG[chIter];
    processedFrame[3 * (chIter + 1) - 3] = outImgB[chIter];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float gMat[527040]
//                float *b
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void coreVisionPipeline_kernel3(
    const float gMat[527040], float *b)
{
  unsigned long long threadId;
  int indV;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  indV = static_cast<int>(threadId);
  if (indV < 1) {
    *b = gMat[527039];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float bMat[527040]
//                float *b
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void coreVisionPipeline_kernel4(
    const float bMat[527040], float *b)
{
  unsigned long long threadId;
  int indV;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  indV = static_cast<int>(threadId);
  if (indV < 1) {
    *b = bMat[527039];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                float gainAWB[3]
// Return Type  : void
//
static __global__
    __launch_bounds__(32, 1) void coreVisionPipeline_kernel5(float gainAWB[3])
{
  unsigned long long threadId;
  int colBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  colBlockIter = static_cast<int>(threadId);
  if (colBlockIter < 3) {
    //  Create dummy kernel to keep the data on GPU
    gainAWB[colBlockIter] = 0.0F;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float meanBChannel
//                const float meanGChannel
//                const float meanRChannel
//                float gainAWB[3]
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void coreVisionPipeline_kernel6(
    const float meanBChannel, const float meanGChannel,
    const float meanRChannel, float gainAWB[3])
{
  unsigned long long threadId;
  int bin1Percent;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  bin1Percent = static_cast<int>(threadId);
  if (bin1Percent < 2) {
    float maxVal;
    maxVal = fmaxf(meanRChannel, fmaxf(meanGChannel, meanBChannel));
    gainAWB[0] = maxVal / meanRChannel;
    gainAWB[1] = maxVal / meanGChannel;
    gainAWB[2] = maxVal / meanBChannel;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short outFrameColMajor[2108160]
//                unsigned short inputArray[19200]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel7(
    const unsigned short outFrameColMajor[2108160],
    unsigned short inputArray[19200])
{
  unsigned long long threadId;
  int chIter;
  int colBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  chIter = static_cast<int>(threadId % 10ULL);
  colBlockIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(chIter)) / 10ULL);
  if ((colBlockIter < 1920) && (chIter < 10)) {
    inputArray[chIter + 10 * colBlockIter] =
        outFrameColMajor[chIter + 1098 * colBlockIter];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short inputArray[19200]
//                unsigned int *outputVar
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void coreVisionPipeline_kernel8(
    const unsigned short inputArray[19200], unsigned int *outputVar)
{
  unsigned long long threadId;
  int indV;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  indV = static_cast<int>(threadId);
  if (indV < 1) {
    *outputVar = inputArray[19199];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float meanRChannel
//                const unsigned short outFrameColMajor[2108160]
//                unsigned short stg1OutFrame[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void coreVisionPipeline_kernel9(
    const float meanRChannel, const unsigned short outFrameColMajor[2108160],
    unsigned short stg1OutFrame[2073600])
{
  unsigned long long threadId;
  int colIter;
  int rowIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  rowIter = static_cast<int>(threadId % 1080ULL);
  colIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(rowIter)) / 1080ULL);
  if ((colIter < 1920) && (rowIter < 1080)) {
    int chIter;
    unsigned int qY;
    chIter = outFrameColMajor[(rowIter + 1098 * colIter) + 18];
    qY = static_cast<unsigned int>(chIter) -
         static_cast<unsigned int>(roundf(meanRChannel));
    if (qY > static_cast<unsigned int>(chIter)) {
      qY = 0U;
    }
    stg1OutFrame[rowIter + 1080 * colIter] = static_cast<unsigned short>(qY);
  }
}

//
// Arguments    : unsigned int in1
//                unsigned int offset
//                unsigned int mask
// Return Type  : unsigned int
//
static __device__ unsigned int shflDown1(unsigned int in1, unsigned int offset,
                                         unsigned int mask)
{
  int *tmp;
  tmp = (int *)&in1;
  *tmp = __shfl_down_sync(mask, *tmp, offset);
  return *(unsigned int *)tmp;
}

//
// Arguments    : float in1
//                unsigned int offset
//                unsigned int mask
// Return Type  : float
//
static __device__ float shflDown1(float in1, unsigned int offset,
                                  unsigned int mask)
{
  int *tmp;
  tmp = (int *)&in1;
  *tmp = __shfl_down_sync(mask, *tmp, offset);
  return *(float *)tmp;
}

//
// Arguments    : unsigned int blockArg
//                unsigned int gridArg
//                const unsigned short input[2073600]
//                unsigned short paddingValue
//                unsigned short output[2073600]
//                unsigned short b_output[2073600]
//                unsigned short c_output[2073600]
//                unsigned short d_output[2073600]
//                unsigned short e_output[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(256, 1) void stencilKernel(
    const unsigned short input[2073600], unsigned short paddingValue,
    unsigned short output[2073600], unsigned short b_output[2073600],
    unsigned short c_output[2073600], unsigned short d_output[2073600],
    unsigned short e_output[2073600])
{
  int workGroupIdTmp;
  int workItemGlobalOutputElemDimIdx;
  int workItemLocalId;
  workItemLocalId = mwGetThreadIndexWithinBlock();
  workGroupIdTmp = mwGetBlockIndex();
  workItemGlobalOutputElemDimIdx =
      workItemLocalId % 16 + ((workGroupIdTmp % 68) << 4);
  workGroupIdTmp /= 68;
  workItemLocalId = workItemLocalId / 16 + (workGroupIdTmp << 4);
  if ((workItemGlobalOutputElemDimIdx < 1080) && (workItemLocalId < 1920)) {
    unsigned int u;
    unsigned short window[9];
    for (int windowIdx{0}; windowIdx < 3; windowIdx++) {
      workGroupIdTmp = (workItemLocalId + windowIdx) - 1;
      for (int b_windowIdx{0}; b_windowIdx < 3; b_windowIdx++) {
        int inputIdx;
        inputIdx = (workItemGlobalOutputElemDimIdx + b_windowIdx) - 1;
        if ((inputIdx >= 0) && (inputIdx < 1080) && (workGroupIdTmp >= 0) &&
            (workGroupIdTmp < 1920)) {
          window[b_windowIdx + 3 * windowIdx] =
              input[inputIdx + 1080 * workGroupIdTmp];
        } else {
          window[b_windowIdx + 3 * windowIdx] = paddingValue;
        }
      }
    }
    //  out1 = [0,0,0;0,1,0;0,0,0] // Center
    //  out2 = [0,1,0;1,0,1;0,1,0] // LRTB
    //  out3 = [1,0,1;0,0,0;1,0,1] // Corner
    //  out4 = [0,0,0;1,0,1;0,0,0] // LR
    //  out5 = [0,1,0;0,0,0;0,1,0] // TB
    //  Stencil function
    output[workItemGlobalOutputElemDimIdx + 1080 * workItemLocalId] = window[4];
    u = static_cast<unsigned int>(window[1]) + window[3];
    if (u > 65535U) {
      u = 65535U;
    }
    u += window[7];
    if (u > 65535U) {
      u = 65535U;
    }
    u += window[5];
    if (u > 65535U) {
      u = 65535U;
    }
    b_output[workItemGlobalOutputElemDimIdx + 1080 * workItemLocalId] =
        static_cast<unsigned short>(roundf(static_cast<float>(u) * 0.25F));
    u = static_cast<unsigned int>(window[0]) + window[6];
    if (u > 65535U) {
      u = 65535U;
    }
    u += window[2];
    if (u > 65535U) {
      u = 65535U;
    }
    u += window[8];
    if (u > 65535U) {
      u = 65535U;
    }
    c_output[workItemGlobalOutputElemDimIdx + 1080 * workItemLocalId] =
        static_cast<unsigned short>(roundf(static_cast<float>(u) * 0.25F));
    u = static_cast<unsigned int>(window[1]) + window[7];
    if (u > 65535U) {
      u = 65535U;
    }
    d_output[workItemGlobalOutputElemDimIdx + 1080 * workItemLocalId] =
        static_cast<unsigned short>(roundf(static_cast<float>(u) * 0.5F));
    u = static_cast<unsigned int>(window[3]) + window[5];
    if (u > 65535U) {
      u = 65535U;
    }
    e_output[workItemGlobalOutputElemDimIdx + 1080 * workItemLocalId] =
        static_cast<unsigned short>(roundf(static_cast<float>(u) * 0.5F));
  }
}

//
// Arguments    : unsigned int val
//                unsigned int lane
//                unsigned int mask
// Return Type  : unsigned int
//
static __device__ unsigned int
threadGroupReduction(unsigned int val, unsigned int lane, unsigned int mask)
{
  unsigned int activeSize;
  unsigned int offset;
  activeSize = __popc(mask);
  offset = (activeSize + 1U) / 2U;
  while (activeSize > 1U) {
    unsigned int other;
    other = shflDown1(val, offset, mask);
    if (lane + offset < activeSize) {
      activeSize = val;
      //  Helper function
      val += other;
      if (val < activeSize) {
        val = MAX_uint32_T;
      }
    }
    activeSize = offset;
    offset = (offset + 1U) / 2U;
  }
  return val;
}

//
// Arguments    : float val
//                unsigned int lane
//                unsigned int mask
// Return Type  : float
//
static __device__ float threadGroupReduction(float val, unsigned int lane,
                                             unsigned int mask)
{
  unsigned int activeSize;
  unsigned int offset;
  activeSize = __popc(mask);
  offset = (activeSize + 1U) / 2U;
  while (activeSize > 1U) {
    float other;
    other = shflDown1(val, offset, mask);
    if (lane + offset < activeSize) {
      //  Helper function
      val += other;
    }
    activeSize = offset;
    offset = (offset + 1U) / 2U;
  }
  return val;
}

//
// Arguments    : float val
//                unsigned int mask
//                unsigned int numActiveWarps
// Return Type  : float
//
static __device__ float workGroupReduction(float val, unsigned int mask,
                                           unsigned int numActiveWarps)
{
  __shared__ float shared[32];
  unsigned int lane;
  unsigned int threadId;
  threadId = static_cast<unsigned int>(mwGetGlobalThreadIndex());
  threadId = static_cast<unsigned int>(mwGetThreadIndexWithinBlock());
  lane = threadId % warpSize;
  threadId /= warpSize;
  val = threadGroupReduction(val, lane, mask);
  if (lane == 0U) {
    shared[threadId] = val;
  }
  __syncthreads();
  mask = __ballot_sync(MAX_uint32_T, lane < numActiveWarps);
  val = shared[lane];
  if (threadId == 0U) {
    val = threadGroupReduction(val, lane, mask);
  }
  return val;
}

//
// Arguments    : unsigned int val
//                unsigned int mask
//                unsigned int numActiveWarps
// Return Type  : unsigned int
//
static __device__ unsigned int workGroupReduction(unsigned int val,
                                                  unsigned int mask,
                                                  unsigned int numActiveWarps)
{
  __shared__ unsigned int shared[32];
  unsigned int lane;
  unsigned int threadId;
  threadId = static_cast<unsigned int>(mwGetGlobalThreadIndex());
  threadId = static_cast<unsigned int>(mwGetThreadIndexWithinBlock());
  lane = threadId % warpSize;
  threadId /= warpSize;
  val = threadGroupReduction(val, lane, mask);
  if (lane == 0U) {
    shared[threadId] = val;
  }
  __syncthreads();
  mask = __ballot_sync(MAX_uint32_T, lane < numActiveWarps);
  val = shared[lane];
  if (threadId == 0U) {
    val = threadGroupReduction(val, lane, mask);
  }
  return val;
}

//
// Arguments    : const unsigned short inputFrame[2108160]
//                float gainAWB[3]
//                double runAWB
//                unsigned short processedFrame[6220800]
// Return Type  : void
//
void coreVisionPipeline(const unsigned short inputFrame[2108160],
                        float gainAWB[3], double runAWB,
                        unsigned short processedFrame[6220800])
{
  unsigned long long(*gpu_localHistogram)[16384];
  unsigned long long(*gpu_globalHistogram)[4096];
  float(*gpu_bMat)[527040];
  float(*gpu_gMat)[527040];
  float(*gpu_rMat)[527040];
  float b;
  float c;
  float d;
  float *b_gpu_tmp;
  float *c_gpu_tmp;
  float *gpu_tmp;
  int bin1Percent;
  int bin99Percent;
  unsigned int outputVar;
  int *gpu_bin1Percent;
  int *gpu_bin99Percent;
  unsigned int *gpu_outputVar;
  unsigned short(*gpu_stg2OutFrame)[6220800];
  unsigned short(*gpu_stg3OutFrame)[6220800];
  unsigned short(*gpu_outFrameColMajor)[2108160];
  unsigned short(*gpu_outImgB)[2073600];
  unsigned short(*gpu_outImgG)[2073600];
  unsigned short(*gpu_outImgR)[2073600];
  unsigned short(*gpu_stg1OutFrame)[2073600];
  unsigned short(*gpu_varargout_1)[2073600];
  unsigned short(*gpu_varargout_2)[2073600];
  unsigned short(*gpu_varargout_3)[2073600];
  unsigned short(*gpu_varargout_4)[2073600];
  unsigned short(*gpu_varargout_5)[2073600];
  unsigned short(*gpu_inputArray)[19200];
  if (!isInitialized_coreVisionPipeline) {
    coreVisionPipeline_initialize();
  }
  mwCudaMalloc(&gpu_outImgB, 4147200ULL);
  mwCudaMalloc(&gpu_outImgG, 4147200ULL);
  mwCudaMalloc(&gpu_outImgR, 4147200ULL);
  mwCudaMalloc(&gpu_bin1Percent, 4ULL);
  mwCudaMalloc(&gpu_bin99Percent, 4ULL);
  mwCudaMalloc(&gpu_globalHistogram, 32768ULL);
  mwCudaMalloc(&gpu_localHistogram, 131072ULL);
  mwCudaMalloc(&gpu_stg3OutFrame, 12441600ULL);
  mwCudaMalloc(&gpu_stg2OutFrame, 12441600ULL);
  mwCudaMalloc(&gpu_varargout_5, 4147200ULL);
  mwCudaMalloc(&gpu_varargout_4, 4147200ULL);
  mwCudaMalloc(&gpu_varargout_3, 4147200ULL);
  mwCudaMalloc(&gpu_varargout_2, 4147200ULL);
  mwCudaMalloc(&gpu_varargout_1, 4147200ULL);
  mwCudaMalloc(&gpu_stg1OutFrame, 4147200ULL);
  mwCudaMalloc(&c_gpu_tmp, 4ULL);
  mwCudaMalloc(&gpu_outputVar, 4ULL);
  mwCudaMalloc(&gpu_inputArray, 38400ULL);
  mwCudaMalloc(&b_gpu_tmp, 4ULL);
  mwCudaMalloc(&gpu_tmp, 4ULL);
  mwCudaMalloc(&gpu_outFrameColMajor, 4216320ULL);
  mwCudaMalloc(&gpu_rMat, 2108160ULL);
  mwCudaMalloc(&gpu_bMat, 2108160ULL);
  mwCudaMalloc(&gpu_gMat, 2108160ULL);
  //  AWB Gain update
  if (runAWB != 0.0) {
    //  Compute the mean of RGB channels in the bayer patch
    coreVisionPipeline_kernel1<<<dim3(259U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
        inputFrame, *gpu_gMat, *gpu_bMat, *gpu_rMat);
    coreVisionPipeline_kernel2<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
        *gpu_rMat, gpu_tmp);
    coder_reduce0<<<dim3(1030U, 1U, 1U), dim3(512U, 1U, 1U)>>>(*gpu_rMat,
                                                               gpu_tmp);
    cudaMemcpy(&b, gpu_tmp, 4ULL, cudaMemcpyDeviceToHost);
    coreVisionPipeline_kernel3<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
        *gpu_gMat, b_gpu_tmp);
    coder_reduce1<<<dim3(1030U, 1U, 1U), dim3(512U, 1U, 1U)>>>(*gpu_gMat,
                                                               b_gpu_tmp);
    cudaMemcpy(&c, b_gpu_tmp, 4ULL, cudaMemcpyDeviceToHost);
    coreVisionPipeline_kernel4<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
        *gpu_bMat, c_gpu_tmp);
    coder_reduce2<<<dim3(1030U, 1U, 1U), dim3(512U, 1U, 1U)>>>(*gpu_bMat,
                                                               c_gpu_tmp);
    cudaMemcpy(&d, c_gpu_tmp, 4ULL, cudaMemcpyDeviceToHost);
    //  Create dummy kernel to keep the data on GPU
    coreVisionPipeline_kernel5<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
        gainAWB);
    coreVisionPipeline_kernel6<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
        d / 2.10816E+6F, 1.2F * c / 2.10816E+6F, b / 2.10816E+6F, gainAWB);
  }
  //  Process input frame
  //  Input Frame row-major to column-major conversion
  transposeImpl((unsigned short *)&inputFrame[0], &(*gpu_outFrameColMajor)[0],
                1920, 1098, false);
  //  outFrameColMajor = inputFrame;
  //  Split Frame and Black Correction
  //  Constants:
  //  Rows for black correction cropping
  //  Rows for black level estimation
  //  Input Size
  //  Estimating the black value in both the frames
  coreVisionPipeline_kernel7<<<dim3(38U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_outFrameColMajor, *gpu_inputArray);
  coreVisionPipeline_kernel8<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
      *gpu_inputArray, gpu_outputVar);
  coder_reduce3<<<dim3(38U, 1U, 1U), dim3(512U, 1U, 1U)>>>(*gpu_inputArray,
                                                           gpu_outputVar);
  cudaMemcpy(&outputVar, gpu_outputVar, 4ULL, cudaMemcpyDeviceToHost);
  if (outputVar > 65535U) {
    outputVar = 65535U;
  }
  //  Subtract mean black and remove the crop the blackCorrection rows
  coreVisionPipeline_kernel9<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      static_cast<float>(outputVar) / 19200.0F, *gpu_outFrameColMajor,
      *gpu_stg1OutFrame);
  //  Debayer
  //  Function to call debayer algorithm on input image.
  //     %% Sizes and constants
  //  Debayer Function
  //  Convolve image with masks
  stencilKernel<<<8160U, 256U>>>(*gpu_stg1OutFrame, 0U, *gpu_varargout_1,
                                 *gpu_varargout_2, *gpu_varargout_3,
                                 *gpu_varargout_4, *gpu_varargout_5);
  //  Plane Ordering
  //  Since stencil kernel performs
  //  BayerFormat = [(R-plane,G-plane,B-plane)->(Row coord, Col coord)]
  //  Following the RGGB bayer format
  coreVisionPipeline_kernel10<<<dim3(1013U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_varargout_4, *gpu_varargout_5, *gpu_varargout_3, *gpu_varargout_2,
      *gpu_varargout_1, *gpu_stg2OutFrame);
  //  GRBG = [(4,1,5)->(1,1), (1,2,3)->(1,2); (3,2,1)->(2,1), (5,1,4)->(2,2)]
  //  Despeckle
  //  Despeckle Algorithm Caller
  coreVisionPipeline_kernel11<<<dim3(12150U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg2OutFrame, *gpu_stg3OutFrame);
  coreVisionPipeline_kernel12<<<dim3(12115U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg2OutFrame, *gpu_stg3OutFrame);
  //  White Balance
  //  Luma Gain
  //  GPU Pragmas
  //  Compute sizes and declaring constants
  //  Compute Luminance
  coreVisionPipeline_kernel13<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      gainAWB, *gpu_stg1OutFrame, *gpu_stg3OutFrame);
  //  Histogram Computation
  //  GPU Codegen: Block-wise histogram computation
  //  Histogram per block is stored in the local histogram matrix
  coreVisionPipeline_kernel14<<<dim3(32U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_localHistogram);
  coreVisionPipeline_kernel15<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg1OutFrame, *gpu_localHistogram);
  //  Local histograms are added to create the final global histogram
  coreVisionPipeline_kernel16<<<dim3(8U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_globalHistogram);
  coreVisionPipeline_kernel17<<<dim3(32U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_localHistogram, *gpu_globalHistogram);
  //  Histogram equalization
  //  Cumulative histogram values
  callThrustScan1D(&(*gpu_globalHistogram)[0], false, 4096);
  //  Identify 90-th percentile bin and computing the smoothing factor
  bin1Percent = 0;
  bin99Percent = 0;
  cudaMemcpy(gpu_bin99Percent, &bin99Percent, 4ULL, cudaMemcpyHostToDevice);
  cudaMemcpy(gpu_bin1Percent, &bin1Percent, 4ULL, cudaMemcpyHostToDevice);
  coreVisionPipeline_kernel18<<<dim3(8U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_globalHistogram, gpu_bin99Percent, gpu_bin1Percent);
  //  Applying pixel gains
  coreVisionPipeline_kernel19<<<dim3(12150U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      gpu_bin99Percent, gpu_bin1Percent, *gpu_stg3OutFrame);
  //  Planar to packed
  //  Assuming input planar array pointer is row-major of size RowsxColsx3
  coreVisionPipeline_kernel20<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg3OutFrame, *gpu_stg1OutFrame);
  transposeImpl(&(*gpu_stg1OutFrame)[0], &(*gpu_outImgR)[0], 1080, 1920, false);
  coreVisionPipeline_kernel21<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg3OutFrame, *gpu_stg1OutFrame);
  transposeImpl(&(*gpu_stg1OutFrame)[0], &(*gpu_outImgG)[0], 1080, 1920, false);
  coreVisionPipeline_kernel22<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg3OutFrame, *gpu_stg1OutFrame);
  transposeImpl(&(*gpu_stg1OutFrame)[0], &(*gpu_outImgB)[0], 1080, 1920, false);
  coreVisionPipeline_kernel23<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_outImgB, *gpu_outImgG, *gpu_outImgR, processedFrame);
  //      processedFrame = outFrameRGB;
  mwCudaFree(&(*gpu_gMat)[0]);
  mwCudaFree(&(*gpu_bMat)[0]);
  mwCudaFree(&(*gpu_rMat)[0]);
  mwCudaFree(&(*gpu_outFrameColMajor)[0]);
  mwCudaFree(gpu_tmp);
  mwCudaFree(b_gpu_tmp);
  mwCudaFree(&(*gpu_inputArray)[0]);
  mwCudaFree(gpu_outputVar);
  mwCudaFree(c_gpu_tmp);
  mwCudaFree(&(*gpu_stg1OutFrame)[0]);
  mwCudaFree(&(*gpu_varargout_1)[0]);
  mwCudaFree(&(*gpu_varargout_2)[0]);
  mwCudaFree(&(*gpu_varargout_3)[0]);
  mwCudaFree(&(*gpu_varargout_4)[0]);
  mwCudaFree(&(*gpu_varargout_5)[0]);
  mwCudaFree(&(*gpu_stg2OutFrame)[0]);
  mwCudaFree(&(*gpu_stg3OutFrame)[0]);
  mwCudaFree(&(*gpu_localHistogram)[0]);
  mwCudaFree(&(*gpu_globalHistogram)[0]);
  mwCudaFree(gpu_bin99Percent);
  mwCudaFree(gpu_bin1Percent);
  mwCudaFree(&(*gpu_outImgR)[0]);
  mwCudaFree(&(*gpu_outImgG)[0]);
  mwCudaFree(&(*gpu_outImgB)[0]);
}

//
// File trailer for coreVisionPipeline.cu
//
// [EOF]
//
