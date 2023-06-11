//
// Trial License - for use to evaluate programs for possible purchase as
// an end-user only.
// File: visionPipeline.cu
//
// GPU Coder version                    : 2.4
// CUDA/C/C++ source code generated on  : 24-Feb-2023 21:05:52
//

// Include Files
#include "visionPipeline.h"
#include "visionPipeline_data.h"
#include "visionPipeline_initialize.h"
#include "MWAtomicUtility.hpp"
#include "MWCudaDimUtility.hpp"
#include "MWCudaMemoryFunctions.hpp"
#include "MWScanFunctors.h"
#include "MWScanUtility.h"
#include "MWShuffleUtility.h"

// Function Declarations
static __device__ float atomicOpreal32_T(float *address, float value);

static __global__ void coder_reduce0(const float inputVar[129600],
                                     float *outputVar);

static __global__ void coder_reduce1(const float inputVar[129600],
                                     float *outputVar);

static __global__ void coder_reduce2(const float inputVar[129600],
                                     float *outputVar);

static __device__ int shflDown1(int in1, unsigned int offset,
                                unsigned int mask);

static __device__ float shflDown1(float in1, unsigned int offset,
                                  unsigned int mask);

static __global__ void stencilKernel(const unsigned short input[2073600],
                                     unsigned short paddingValue,
                                     unsigned short output[2073600],
                                     unsigned short b_output[2073600],
                                     unsigned short c_output[2073600],
                                     unsigned short d_output[2073600],
                                     unsigned short e_output[2073600]);

static __global__ void stencilKernel(const unsigned short input[2073600],
                                     unsigned short paddingValue,
                                     unsigned short output[2073600]);

static __device__ int threadGroupReduction(int val, unsigned int lane,
                                           unsigned int mask);

static __device__ float threadGroupReduction(float val, unsigned int lane,
                                             unsigned int mask);

static __global__ void visionPipeline_kernel1(const unsigned short uv[19200],
                                              int *i1);

static __global__ void visionPipeline_kernel10(const float rMat[129600],
                                               float *b);

static __global__ void visionPipeline_kernel11(const float gMat[129600],
                                               float *b);

static __global__ void visionPipeline_kernel12(const float bMat[129600],
                                               float *b);

static __global__ void
visionPipeline_kernel13(const float meanBChannel, const float meanGChannel,
                        const float meanRChannel, float *gainBChannel,
                        float *gainGChannel, float *gainRChannel);

static __global__ void
visionPipeline_kernel14(const float *gainBChannel, const float *gainGChannel,
                        const float *gainRChannel,
                        unsigned short stg3OutFrame[6220800]);

static __global__ void
visionPipeline_kernel15(const unsigned short stg3OutFrame[6220800],
                        unsigned short varargout_1[2073600]);

static __global__ void
visionPipeline_kernel16(const unsigned short varargout_1[2073600],
                        unsigned short frameLuma[2073600]);

static __global__ void
visionPipeline_kernel17(unsigned long long localHistogram[16384]);

static __global__ void
visionPipeline_kernel18(const unsigned short frameLuma[2073600],
                        unsigned long long localHistogram[16384]);

static __global__ void
visionPipeline_kernel19(unsigned long long globalHistogram[4096]);

static __global__ void visionPipeline_kernel2(const unsigned short uv[19200],
                                              int *i1);

static __global__ void
visionPipeline_kernel20(unsigned long long localHistogram[16384],
                        unsigned long long globalHistogram[4096]);

static __global__ void
visionPipeline_kernel21(const unsigned long long globalHistogram[4096],
                        int *bin1Percent, int *bin99Percent, int *binVal);

static __global__ void visionPipeline_kernel22(const int *bin99Percent,
                                               const int *bin1Percent,
                                               double pixelGainLUT[4096]);

static __global__ void
visionPipeline_kernel23(const double pixelGainLUT[4096],
                        const unsigned short stg3OutFrame[6220800],
                        unsigned short stg2OutFrame[6220800]);

static __global__ void
visionPipeline_kernel24(const unsigned short stg2OutFrame[6220800],
                        unsigned short stg5OutFrame_t[6220800]);

static __global__ void
visionPipeline_kernel25(const unsigned short stg5OutFrame_t[6220800],
                        unsigned short outFrame[6220800]);

static __global__ void
visionPipeline_kernel3(const double meanBlackValue,
                       const unsigned short inputFrame[2108160],
                       unsigned short frameLuma[2073600]);

static __global__ void
visionPipeline_kernel4(const unsigned short varargout_5[2073600],
                       const unsigned short varargout_4[2073600],
                       const unsigned short varargout_3[2073600],
                       const unsigned short varargout_2[2073600],
                       const unsigned short varargout_1[2073600],
                       unsigned short stg2OutFrame[6220800]);

static __global__ void
visionPipeline_kernel5(const unsigned short stg2OutFrame[6220800],
                       unsigned short frameLuma[2073600]);

static __global__ void
visionPipeline_kernel6(const unsigned short stg2OutFrame[6220800],
                       const unsigned short varargout_1[2073600],
                       unsigned short frameLuma[2073600],
                       unsigned short stg3OutFrame[6220800]);

static __global__ void
visionPipeline_kernel7(const unsigned short stg2OutFrame[6220800],
                       const unsigned short varargout_1[2073600],
                       unsigned short frameLuma[2073600],
                       unsigned short stg3OutFrame[6220800]);

static __global__ void
visionPipeline_kernel8(const unsigned short varargout_1[2073600],
                       unsigned short stg3OutFrame[6220800]);

static __global__ void
visionPipeline_kernel9(const unsigned short whitePatch[518400],
                       float gMat[129600], float bMat[129600],
                       float rMat[129600]);

static __device__ int workGroupReduction(int val, unsigned int mask,
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
    old = atomicCAS(address_as_up, old, __float_as_uint(value + input2));
  } while (assumed != old);
  return __uint_as_float(old);
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float inputVar[129600]
//                float *outputVar
// Return Type  : void
//
static __global__
    __launch_bounds__(1024, 1) void coder_reduce0(const float inputVar[129600],
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
  if (static_cast<unsigned int>(mwGetBlockIndex()) == 129599U / blockStride) {
    m = 129599U % blockStride;
    if (m > 0U) {
      blockStride = m;
    }
  }
  blockStride = ((blockStride + warpSize) - 1U) / warpSize;
  if (threadId <= 129598U) {
    input1 = inputVar[threadId];
  }
  m = __ballot_sync(MAX_uint32_T, threadId <= 129598U);
  for (unsigned int idx{threadId + threadStride}; idx <= 129598U;
       idx += threadStride) {
    float input2;
    input2 = inputVar[idx];
    input1 += input2;
  }
  input1 = workGroupReduction(input1, m, blockStride);
  if ((threadId <= 129598U) && (thBlkId == 0U)) {
    atomicOpreal32_T(&outputVar[0], input1);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float inputVar[129600]
//                float *outputVar
// Return Type  : void
//
static __global__
    __launch_bounds__(1024, 1) void coder_reduce1(const float inputVar[129600],
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
  if (static_cast<unsigned int>(mwGetBlockIndex()) == 129599U / blockStride) {
    m = 129599U % blockStride;
    if (m > 0U) {
      blockStride = m;
    }
  }
  blockStride = ((blockStride + warpSize) - 1U) / warpSize;
  if (threadId <= 129598U) {
    input1 = inputVar[threadId];
  }
  m = __ballot_sync(MAX_uint32_T, threadId <= 129598U);
  for (unsigned int idx{threadId + threadStride}; idx <= 129598U;
       idx += threadStride) {
    float input2;
    input2 = inputVar[idx];
    input1 += input2;
  }
  input1 = workGroupReduction(input1, m, blockStride);
  if ((threadId <= 129598U) && (thBlkId == 0U)) {
    atomicOpreal32_T(&outputVar[0], input1);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float inputVar[129600]
//                float *outputVar
// Return Type  : void
//
static __global__
    __launch_bounds__(1024, 1) void coder_reduce2(const float inputVar[129600],
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
  if (static_cast<unsigned int>(mwGetBlockIndex()) == 129599U / blockStride) {
    m = 129599U % blockStride;
    if (m > 0U) {
      blockStride = m;
    }
  }
  blockStride = ((blockStride + warpSize) - 1U) / warpSize;
  if (threadId <= 129598U) {
    input1 = inputVar[threadId];
  }
  m = __ballot_sync(MAX_uint32_T, threadId <= 129598U);
  for (unsigned int idx{threadId + threadStride}; idx <= 129598U;
       idx += threadStride) {
    float input2;
    input2 = inputVar[idx];
    input1 += input2;
  }
  input1 = workGroupReduction(input1, m, blockStride);
  if ((threadId <= 129598U) && (thBlkId == 0U)) {
    atomicOpreal32_T(&outputVar[0], input1);
  }
}

//
// Arguments    : int in1
//                unsigned int offset
//                unsigned int mask
// Return Type  : int
//
static __device__ int shflDown1(int in1, unsigned int offset, unsigned int mask)
{
  in1 = __shfl_down_sync(mask, in1, offset);
  return in1;
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
      workItemLocalId % 16 + ((workGroupIdTmp % 120) << 4);
  workGroupIdTmp /= 120;
  workItemLocalId = workItemLocalId / 16 + (workGroupIdTmp << 4);
  if (workItemLocalId < 1080) {
    unsigned int u;
    unsigned short window[9];
    for (int windowIdx{0}; windowIdx < 3; windowIdx++) {
      workGroupIdTmp = (workItemLocalId + windowIdx) - 1;
      for (int b_windowIdx{0}; b_windowIdx < 3; b_windowIdx++) {
        int inputIdx;
        inputIdx = (workItemGlobalOutputElemDimIdx + b_windowIdx) - 1;
        if ((workGroupIdTmp >= 0) && (workGroupIdTmp < 1080) &&
            (inputIdx >= 0) && (inputIdx < 1920)) {
          window[b_windowIdx + 3 * windowIdx] =
              input[inputIdx + 1920 * workGroupIdTmp];
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
    output[workItemGlobalOutputElemDimIdx + 1920 * workItemLocalId] = window[4];
    u = static_cast<unsigned int>(window[1]) + window[3];
    if (u > 65535U) {
      u = 65535U;
    }
    u += window[5];
    if (u > 65535U) {
      u = 65535U;
    }
    u += window[7];
    if (u > 65535U) {
      u = 65535U;
    }
    b_output[workItemGlobalOutputElemDimIdx + 1920 * workItemLocalId] =
        static_cast<unsigned short>(roundf(static_cast<float>(u) * 0.25F));
    u = static_cast<unsigned int>(window[0]) + window[2];
    if (u > 65535U) {
      u = 65535U;
    }
    u += window[6];
    if (u > 65535U) {
      u = 65535U;
    }
    u += window[8];
    if (u > 65535U) {
      u = 65535U;
    }
    c_output[workItemGlobalOutputElemDimIdx + 1920 * workItemLocalId] =
        static_cast<unsigned short>(roundf(static_cast<float>(u) * 0.25F));
    u = static_cast<unsigned int>(window[3]) + window[5];
    if (u > 65535U) {
      u = 65535U;
    }
    d_output[workItemGlobalOutputElemDimIdx + 1920 * workItemLocalId] =
        static_cast<unsigned short>(roundf(static_cast<float>(u) * 0.5F));
    u = static_cast<unsigned int>(window[1]) + window[7];
    if (u > 65535U) {
      u = 65535U;
    }
    e_output[workItemGlobalOutputElemDimIdx + 1920 * workItemLocalId] =
        static_cast<unsigned short>(roundf(static_cast<float>(u) * 0.5F));
  }
}

//
// Arguments    : unsigned int blockArg
//                unsigned int gridArg
//                const unsigned short input[2073600]
//                unsigned short paddingValue
//                unsigned short output[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(256, 1) void stencilKernel(
    const unsigned short input[2073600], unsigned short paddingValue,
    unsigned short output[2073600])
{
  int b_workItemGlobalOutputElemDimIdx;
  int workGroupIdTmp;
  int workItemGlobalOutputElemDimIdx;
  int workItemLocalId;
  workItemLocalId = mwGetThreadIndexWithinBlock();
  workGroupIdTmp = mwGetBlockIndex();
  workItemGlobalOutputElemDimIdx =
      workItemLocalId % 16 + ((workGroupIdTmp % 120) << 4);
  workGroupIdTmp /= 120;
  b_workItemGlobalOutputElemDimIdx =
      workItemLocalId / 16 + (workGroupIdTmp << 4);
  if (b_workItemGlobalOutputElemDimIdx < 1080) {
    int windowIdx;
    unsigned short window[9];
    boolean_T b;
    for (windowIdx = 0; windowIdx < 3; windowIdx++) {
      workItemLocalId = (b_workItemGlobalOutputElemDimIdx + windowIdx) - 1;
      for (int b_windowIdx{0}; b_windowIdx < 3; b_windowIdx++) {
        workGroupIdTmp = (workItemGlobalOutputElemDimIdx + b_windowIdx) - 1;
        if ((workItemLocalId >= 0) && (workItemLocalId < 1080) &&
            (workGroupIdTmp >= 0) && (workGroupIdTmp < 1920)) {
          window[b_windowIdx + 3 * windowIdx] =
              input[workGroupIdTmp + 1920 * workItemLocalId];
        } else {
          window[b_windowIdx + 3 * windowIdx] = paddingValue;
        }
      }
    }
    //  Median filter stencil kernel implementation.
    //  Apply median filter only when the mid-value is beyond sensitivity level.
    //  Sort values and replace mid-value with median
    b = true;
    workItemLocalId = 0;
    for (int b_windowIdx{0}; b_windowIdx < 9; b_windowIdx++) {
      if (b) {
        b = false;
        workItemLocalId = b_windowIdx % 3 * 3 + b_windowIdx / 3;
      } else {
        workItemLocalId += 3;
        if (workItemLocalId > 8) {
          workItemLocalId -= 8;
        }
      }
      workGroupIdTmp = 7 - b_windowIdx;
      for (int jter{0}; jter <= workGroupIdTmp; jter++) {
        windowIdx = (b_windowIdx + jter) + 1;
        if (window[windowIdx % 3 * 3 + windowIdx / 3] <
            window[workItemLocalId]) {
          unsigned short u;
          u = window[windowIdx % 3 * 3 + windowIdx / 3];
          window[windowIdx % 3 * 3 + windowIdx / 3] = window[workItemLocalId];
          //  Function to swap values
          window[workItemLocalId] = u;
        }
      }
    }
    output[workItemGlobalOutputElemDimIdx +
           1920 * b_workItemGlobalOutputElemDimIdx] = window[4];
  }
}

//
// Arguments    : int val
//                unsigned int lane
//                unsigned int mask
// Return Type  : int
//
static __device__ int threadGroupReduction(int val, unsigned int lane,
                                           unsigned int mask)
{
  unsigned int activeSize;
  unsigned int offset;
  activeSize = __popc(mask);
  offset = (activeSize + 1U) / 2U;
  while (activeSize > 1U) {
    int other;
    other = shflDown1(val, offset, mask);
    if (lane + offset < activeSize) {
      val += other;
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
      val += other;
    }
    activeSize = offset;
    offset = (offset + 1U) / 2U;
  }
  return val;
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short uv[19200]
//                int *i1
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void visionPipeline_kernel1(
    const unsigned short uv[19200], int *i1)
{
  unsigned long long threadId;
  int tmpIdx;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  tmpIdx = static_cast<int>(threadId);
  if (tmpIdx < 1) {
    *i1 = uv[0];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float rMat[129600]
//                float *b
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void visionPipeline_kernel10(
    const float rMat[129600], float *b)
{
  unsigned long long threadId;
  int indV;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  indV = static_cast<int>(threadId);
  if (indV < 1) {
    *b = rMat[129599];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float gMat[129600]
//                float *b
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void visionPipeline_kernel11(
    const float gMat[129600], float *b)
{
  unsigned long long threadId;
  int indV;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  indV = static_cast<int>(threadId);
  if (indV < 1) {
    *b = gMat[129599];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float bMat[129600]
//                float *b
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void visionPipeline_kernel12(
    const float bMat[129600], float *b)
{
  unsigned long long threadId;
  int indV;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  indV = static_cast<int>(threadId);
  if (indV < 1) {
    *b = bMat[129599];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float meanBChannel
//                const float meanGChannel
//                const float meanRChannel
//                float *gainBChannel
//                float *gainGChannel
//                float *gainRChannel
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void visionPipeline_kernel13(
    const float meanBChannel, const float meanGChannel,
    const float meanRChannel, float *gainBChannel, float *gainGChannel,
    float *gainRChannel)
{
  unsigned long long threadId;
  int i1;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  i1 = static_cast<int>(threadId);
  if (i1 < 2) {
    float pixVal;
    //  Create dummy kernel to keep the data on GPU
    pixVal = fmaxf(meanRChannel, fmaxf(meanGChannel, meanBChannel));
    *gainRChannel = pixVal / meanRChannel;
    *gainGChannel = pixVal / meanGChannel;
    *gainBChannel = pixVal / meanBChannel;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const float *gainBChannel
//                const float *gainGChannel
//                const float *gainRChannel
//                unsigned short stg3OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel14(
    const float *gainBChannel, const float *gainGChannel,
    const float *gainRChannel, unsigned short stg3OutFrame[6220800])
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
    float pixVal;
    unsigned short u;
    pixVal = static_cast<float>(stg3OutFrame[3 * colIter + 5760 * rowIter]) *
             *gainRChannel;
    pixVal = static_cast<float>(pixVal >= 4095.0F) * 4095.0F +
             static_cast<float>(pixVal < 4095.0F) * pixVal;
    pixVal = roundf(pixVal);
    if (pixVal < 65536.0F) {
      if (pixVal >= 0.0F) {
        u = static_cast<unsigned short>(pixVal);
      } else {
        u = 0U;
      }
    } else if (pixVal >= 65536.0F) {
      u = MAX_uint16_T;
    } else {
      u = 0U;
    }
    stg3OutFrame[3 * colIter + 5760 * rowIter] = u;
    pixVal =
        static_cast<float>(stg3OutFrame[(3 * colIter + 5760 * rowIter) + 1]) *
        *gainGChannel;
    pixVal = static_cast<float>(pixVal >= 4095.0F) * 4095.0F +
             static_cast<float>(pixVal < 4095.0F) * pixVal;
    pixVal = roundf(pixVal);
    if (pixVal < 65536.0F) {
      if (pixVal >= 0.0F) {
        u = static_cast<unsigned short>(pixVal);
      } else {
        u = 0U;
      }
    } else if (pixVal >= 65536.0F) {
      u = MAX_uint16_T;
    } else {
      u = 0U;
    }
    stg3OutFrame[(3 * colIter + 5760 * rowIter) + 1] = u;
    pixVal =
        static_cast<float>(stg3OutFrame[(3 * colIter + 5760 * rowIter) + 2]) *
        *gainBChannel;
    pixVal = static_cast<float>(pixVal >= 4095.0F) * 4095.0F +
             static_cast<float>(pixVal < 4095.0F) * pixVal;
    pixVal = roundf(pixVal);
    if (pixVal < 65536.0F) {
      if (pixVal >= 0.0F) {
        u = static_cast<unsigned short>(pixVal);
      } else {
        u = 0U;
      }
    } else if (pixVal >= 65536.0F) {
      u = MAX_uint16_T;
    } else {
      u = 0U;
    }
    stg3OutFrame[(3 * colIter + 5760 * rowIter) + 2] = u;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg3OutFrame[6220800]
//                unsigned short varargout_1[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel15(
    const unsigned short stg3OutFrame[6220800],
    unsigned short varargout_1[2073600])
{
  unsigned long long threadId;
  int pixVal;
  int tmpVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixVal = static_cast<int>(threadId % 1920ULL);
  tmpVal = static_cast<int>(
      (threadId - static_cast<unsigned long long>(pixVal)) / 1920ULL);
  if ((tmpVal < 1080) && (pixVal < 1920)) {
    varargout_1[pixVal + 1920 * tmpVal] = static_cast<unsigned short>(round(
        (0.2126 *
             static_cast<double>(stg3OutFrame[3 * pixVal + 5760 * tmpVal]) +
         0.7152 * static_cast<double>(
                      stg3OutFrame[(3 * pixVal + 5760 * tmpVal) + 1])) +
        0.0722 * static_cast<double>(
                     stg3OutFrame[(3 * pixVal + 5760 * tmpVal) + 2])));
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short varargout_1[2073600]
//                unsigned short frameLuma[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel16(
    const unsigned short varargout_1[2073600],
    unsigned short frameLuma[2073600])
{
  unsigned long long threadId;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixVal = static_cast<int>(threadId);
  if (pixVal < 2073600) {
    frameLuma[pixVal] = varargout_1[pixVal];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long localHistogram[16384]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel17(
    unsigned long long localHistogram[16384])
{
  unsigned long long threadId;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixVal = static_cast<int>(threadId);
  if (pixVal < 16384) {
    //  Histogram Computation
    //  GPU Codegen: Block-wise histogram computation
    //  Histogram per block is stored in the local histogram matrix
    localHistogram[pixVal] = 0ULL;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short frameLuma[2073600]
//                unsigned long long localHistogram[16384]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel18(
    const unsigned short frameLuma[2073600],
    unsigned long long localHistogram[16384])
{
  unsigned long long threadId;
  int colIter;
  int pixIter;
  int rowIter;
  int tmpVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  rowIter = static_cast<int>(threadId % 540ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowIter)) / 540ULL;
  colIter = static_cast<int>(threadId % 960ULL);
  threadId = (threadId - static_cast<unsigned long long>(colIter)) / 960ULL;
  pixIter = static_cast<int>(threadId % 2ULL);
  threadId = (threadId - static_cast<unsigned long long>(pixIter)) / 2ULL;
  tmpVal = static_cast<int>(threadId);
  if ((tmpVal < 2) && (pixIter < 2) && (colIter < 960) && (rowIter < 540)) {
    int pixVal;
    unsigned int u1;
    pixVal = tmpVal * 960 + 1;
    tmpVal = pixIter * 540 + 1;
    u1 = frameLuma[((pixVal + colIter) + 1920 * ((tmpVal + rowIter) - 1)) - 1] +
         1U;
    if (u1 > 65535U) {
      u1 = 65535U;
    }
    gpu_uint64_atomicAdd(
        &localHistogram
            [((static_cast<int>((static_cast<double>(pixVal) - 1.0) / 960.0 +
                                1.0) +
               ((static_cast<int>((static_cast<double>(tmpVal) - 1.0) / 540.0 +
                                  1.0) -
                 1)
                << 1)) +
              ((static_cast<int>(u1) - 1) << 2)) -
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
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel19(
    unsigned long long globalHistogram[4096])
{
  unsigned long long threadId;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixVal = static_cast<int>(threadId);
  if (pixVal < 4096) {
    //  Local histograms are added to create the final global histogram
    globalHistogram[pixVal] = 0ULL;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short uv[19200]
//                int *i1
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel2(
    const unsigned short uv[19200], int *i1)
{
  unsigned int blockStride;
  unsigned int m;
  unsigned int thBlkId;
  unsigned int threadId;
  unsigned int threadStride;
  int tmpRed0;
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
    tmpRed0 = uv[static_cast<int>(threadId) + 1];
  }
  m = __ballot_sync(MAX_uint32_T, threadId <= 19198U);
  for (unsigned int idx{threadId + threadStride}; idx <= 19198U;
       idx += threadStride) {
    tmpRed0 += uv[static_cast<int>(idx) + 1];
  }
  tmpRed0 = workGroupReduction(tmpRed0, m, blockStride);
  if ((threadId <= 19198U) && (thBlkId == 0U)) {
    atomicAdd(&i1[0], tmpRed0);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                unsigned long long localHistogram[16384]
//                unsigned long long globalHistogram[4096]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel20(
    unsigned long long localHistogram[16384],
    unsigned long long globalHistogram[4096])
{
  unsigned long long threadId;
  int pixIter;
  int rowBlockIter;
  int tmpVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixIter = static_cast<int>(threadId % 4096ULL);
  threadId = (threadId - static_cast<unsigned long long>(pixIter)) / 4096ULL;
  rowBlockIter = static_cast<int>(threadId % 2ULL);
  threadId = (threadId - static_cast<unsigned long long>(rowBlockIter)) / 2ULL;
  tmpVal = static_cast<int>(threadId);
  if ((tmpVal < 2) && (rowBlockIter < 2) && (pixIter < 4096)) {
    gpu_uint64_atomicAdd(
        &globalHistogram[pixIter],
        localHistogram[(tmpVal + (rowBlockIter << 1)) + (pixIter << 2)]);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned long long globalHistogram[4096]
//                int *bin1Percent
//                int *bin99Percent
//                int *binVal
// Return Type  : void
//
static __global__ __launch_bounds__(32, 1) void visionPipeline_kernel21(
    const unsigned long long globalHistogram[4096], int *bin1Percent,
    int *bin99Percent, int *binVal)
{
  unsigned long long threadId;
  int i1;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  i1 = static_cast<int>(threadId);
  if (i1 < 2) {
    //  Dummy kernel invocation: This is a technique to keep the data on GPU
    //  while processing the loop with a single CUDA thread. This is a GPU Coder
    //  artifact.
    //  Dummy Kernel call
    while ((globalHistogram[*binVal] < 207360ULL) && (*binVal < 4096)) {
      (*binVal)++;
      *bin1Percent = *binVal;
    }
    *binVal = 4096;
    while (globalHistogram[*binVal - 1] >= 2052864ULL) {
      *bin99Percent = *binVal;
      (*binVal)--;
    }
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const int *bin99Percent
//                const int *bin1Percent
//                double pixelGainLUT[4096]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel22(
    const int *bin99Percent, const int *bin1Percent, double pixelGainLUT[4096])
{
  unsigned long long threadId;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixVal = static_cast<int>(threadId);
  if (pixVal < 4096) {
    int tmpVal;
    //  Gain lookup table for 12-bit intensity image
    tmpVal = pixVal - *bin1Percent;
    if (tmpVal < 0) {
      tmpVal = 0;
    }
    pixelGainLUT[pixVal] = static_cast<double>(tmpVal) * 4095.0 /
                           static_cast<double>(*bin99Percent - *bin1Percent);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const double pixelGainLUT[4096]
//                const unsigned short stg3OutFrame[6220800]
//                unsigned short stg2OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel23(
    const double pixelGainLUT[4096], const unsigned short stg3OutFrame[6220800],
    unsigned short stg2OutFrame[6220800])
{
  unsigned long long threadId;
  int pixIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixIter = static_cast<int>(threadId);
  if (pixIter < 6220800) {
    double histCol;
    int pixVal;
    unsigned int u1;
    unsigned short u;
    //  Apply gain to all pixels of present frame
    //  Note: We can do an in-place operation instead of writing the output into
    //  new memory locations, but this destroys the original frame data, which
    //  could be later used to write to disk. This can be changed to in-place
    //  operation if needed.
    //  Note2: Conditional statements (if-else) create thread divergences. To
    //  avoid thread divergence, we transform the following if-else code
    //  patterns to addition statements Code:
    //    if (condition)
    //        outValue = statement_1;
    //    else
    //        outValue = statement_2;
    //    end
    //
    //  Optimization:
    //    outValue = (condition == true)*statement_1 + (condition ==
    //    false)*statement_2
    pixVal = stg3OutFrame[(pixIter % 1080 * 1920 + pixIter / 1080 % 1920) * 3 +
                          pixIter / 1080 / 1920];
    u1 = (pixVal == 0) + static_cast<unsigned int>((pixVal > 0) * pixVal);
    if (u1 > 65535U) {
      u1 = 65535U;
    }
    histCol = round(pixelGainLUT[static_cast<int>(u1) - 1]);
    if (histCol < 65536.0) {
      if (histCol >= 0.0) {
        u = static_cast<unsigned short>(histCol);
      } else {
        u = 0U;
      }
    } else if (histCol >= 65536.0) {
      u = MAX_uint16_T;
    } else {
      u = 0U;
    }
    stg2OutFrame[(pixIter % 1080 * 1920 + pixIter / 1080 % 1920) * 3 +
                 pixIter / 1080 / 1920] = u;
    u1 = static_cast<unsigned int>(
             (stg2OutFrame[(pixIter % 1080 * 1920 + pixIter / 1080 % 1920) * 3 +
                           pixIter / 1080 / 1920] >= 4095) *
             4095) +
         static_cast<unsigned int>(
             (stg2OutFrame[(pixIter % 1080 * 1920 + pixIter / 1080 % 1920) * 3 +
                           pixIter / 1080 / 1920] < 4095) *
             stg2OutFrame[(pixIter % 1080 * 1920 + pixIter / 1080 % 1920) * 3 +
                          pixIter / 1080 / 1920]);
    if (u1 > 65535U) {
      u1 = 65535U;
    }
    stg2OutFrame[(pixIter % 1080 * 1920 + pixIter / 1080 % 1920) * 3 +
                 pixIter / 1080 / 1920] = static_cast<unsigned short>(u1);
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg2OutFrame[6220800]
//                unsigned short stg5OutFrame_t[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel24(
    const unsigned short stg2OutFrame[6220800],
    unsigned short stg5OutFrame_t[6220800])
{
  unsigned long long threadId;
  int pixIter;
  int pixVal;
  int tmpVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixVal = static_cast<int>(threadId % 3ULL);
  threadId = (threadId - static_cast<unsigned long long>(pixVal)) / 3ULL;
  pixIter = static_cast<int>(threadId % 1920ULL);
  threadId = (threadId - static_cast<unsigned long long>(pixIter)) / 1920ULL;
  tmpVal = static_cast<int>(threadId);
  if ((tmpVal < 1080) && (pixIter < 1920) && (pixVal < 3)) {
    stg5OutFrame_t[(pixVal + 3 * tmpVal) + 3240 * pixIter] =
        stg2OutFrame[(pixVal + 3 * pixIter) + 5760 * tmpVal];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg5OutFrame_t[6220800]
//                unsigned short outFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel25(
    const unsigned short stg5OutFrame_t[6220800],
    unsigned short outFrame[6220800])
{
  unsigned long long threadId;
  int pixIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixIter = static_cast<int>(threadId);
  if (pixIter < 2073600) {
    //  Planar to packed
    //  Assuming input planar array pointer is row-major of size RowsxColsx3
    outFrame[3 * (pixIter + 1) - 1] =
        stg5OutFrame_t[(pixIter % 1920 * 1080 + pixIter / 1920 % 1080) * 3];
    outFrame[3 * (pixIter + 1) - 2] =
        stg5OutFrame_t[((pixIter + 2073600) % 1920 * 1080 +
                        (pixIter + 2073600) / 1920 % 1080) *
                           3 +
                       1];
    outFrame[3 * (pixIter + 1) - 3] =
        stg5OutFrame_t[((pixIter + 4147200) % 1920 * 1080 +
                        (pixIter + 4147200) / 1920 % 1080) *
                           3 +
                       2];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const double meanBlackValue
//                const unsigned short inputFrame[2108160]
//                unsigned short frameLuma[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel3(
    const double meanBlackValue, const unsigned short inputFrame[2108160],
    unsigned short frameLuma[2073600])
{
  unsigned long long threadId;
  int pixIter;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixIter = static_cast<int>(threadId % 1920ULL);
  pixVal = static_cast<int>(
      (threadId - static_cast<unsigned long long>(pixIter)) / 1920ULL);
  if ((pixVal < 1080) && (pixIter < 1920)) {
    int tmpVal;
    unsigned short u;
    tmpVal = static_cast<int>(
        round(static_cast<double>(inputFrame[pixIter + 1920 * (pixVal + 18)]) -
              meanBlackValue));
    if (tmpVal < 65536) {
      if (tmpVal >= 0) {
        u = static_cast<unsigned short>(tmpVal);
      } else {
        u = 0U;
      }
    } else {
      u = MAX_uint16_T;
    }
    frameLuma[pixIter + 1920 * pixVal] = u;
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short varargout_5[2073600]
//                const unsigned short varargout_4[2073600]
//                const unsigned short varargout_3[2073600]
//                const unsigned short varargout_2[2073600]
//                const unsigned short varargout_1[2073600]
//                unsigned short stg2OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel4(
    const unsigned short varargout_5[2073600],
    const unsigned short varargout_4[2073600],
    const unsigned short varargout_3[2073600],
    const unsigned short varargout_2[2073600],
    const unsigned short varargout_1[2073600],
    unsigned short stg2OutFrame[6220800])
{
  unsigned long long threadId;
  int colIter;
  int rowBlockIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  rowBlockIter = static_cast<int>(threadId % 540ULL);
  colIter = static_cast<int>(
      (threadId - static_cast<unsigned long long>(rowBlockIter)) / 540ULL);
  if ((colIter < 960) && (rowBlockIter < 540)) {
    int tmpVal;
    tmpVal = (colIter << 1) + 1;
    colIter = (rowBlockIter << 1) + 1;
    stg2OutFrame[3 * (tmpVal - 1) + 5760 * (colIter - 1)] =
        varargout_1[(tmpVal + 1920 * (colIter - 1)) - 1];
    stg2OutFrame[(3 * (tmpVal - 1) + 5760 * (colIter - 1)) + 1] =
        varargout_2[(tmpVal + 1920 * (colIter - 1)) - 1];
    stg2OutFrame[(3 * (tmpVal - 1) + 5760 * (colIter - 1)) + 2] =
        varargout_3[(tmpVal + 1920 * (colIter - 1)) - 1];
    stg2OutFrame[3 * tmpVal + 5760 * (colIter - 1)] =
        varargout_4[tmpVal + 1920 * (colIter - 1)];
    stg2OutFrame[(3 * tmpVal + 5760 * (colIter - 1)) + 1] =
        varargout_1[tmpVal + 1920 * (colIter - 1)];
    stg2OutFrame[(3 * tmpVal + 5760 * (colIter - 1)) + 2] =
        varargout_5[tmpVal + 1920 * (colIter - 1)];
    stg2OutFrame[3 * (tmpVal - 1) + 5760 * colIter] =
        varargout_5[(tmpVal + 1920 * colIter) - 1];
    stg2OutFrame[(3 * (tmpVal - 1) + 5760 * colIter) + 1] =
        varargout_1[(tmpVal + 1920 * colIter) - 1];
    stg2OutFrame[(3 * (tmpVal - 1) + 5760 * colIter) + 2] =
        varargout_4[(tmpVal + 1920 * colIter) - 1];
    stg2OutFrame[3 * tmpVal + 5760 * colIter] =
        varargout_3[tmpVal + 1920 * colIter];
    stg2OutFrame[(3 * tmpVal + 5760 * colIter) + 1] =
        varargout_2[tmpVal + 1920 * colIter];
    stg2OutFrame[(3 * tmpVal + 5760 * colIter) + 2] =
        varargout_1[tmpVal + 1920 * colIter];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg2OutFrame[6220800]
//                unsigned short frameLuma[2073600]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel5(
    const unsigned short stg2OutFrame[6220800],
    unsigned short frameLuma[2073600])
{
  unsigned long long threadId;
  int pixIter;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixIter = static_cast<int>(threadId % 1920ULL);
  pixVal = static_cast<int>(
      (threadId - static_cast<unsigned long long>(pixIter)) / 1920ULL);
  if ((pixVal < 1080) && (pixIter < 1920)) {
    frameLuma[pixIter + 1920 * pixVal] =
        stg2OutFrame[3 * pixIter + 5760 * pixVal];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg2OutFrame[6220800]
//                const unsigned short varargout_1[2073600]
//                unsigned short frameLuma[2073600]
//                unsigned short stg3OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel6(
    const unsigned short stg2OutFrame[6220800],
    const unsigned short varargout_1[2073600],
    unsigned short frameLuma[2073600], unsigned short stg3OutFrame[6220800])
{
  unsigned long long threadId;
  int pixIter;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixIter = static_cast<int>(threadId % 1920ULL);
  pixVal = static_cast<int>(
      (threadId - static_cast<unsigned long long>(pixIter)) / 1920ULL);
  if ((pixVal < 1080) && (pixIter < 1920)) {
    stg3OutFrame[3 * pixIter + 5760 * pixVal] =
        varargout_1[pixIter + 1920 * pixVal];
    frameLuma[pixIter + 1920 * pixVal] =
        stg2OutFrame[(3 * pixIter + 5760 * pixVal) + 1];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short stg2OutFrame[6220800]
//                const unsigned short varargout_1[2073600]
//                unsigned short frameLuma[2073600]
//                unsigned short stg3OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel7(
    const unsigned short stg2OutFrame[6220800],
    const unsigned short varargout_1[2073600],
    unsigned short frameLuma[2073600], unsigned short stg3OutFrame[6220800])
{
  unsigned long long threadId;
  int pixIter;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixIter = static_cast<int>(threadId % 1920ULL);
  pixVal = static_cast<int>(
      (threadId - static_cast<unsigned long long>(pixIter)) / 1920ULL);
  if ((pixVal < 1080) && (pixIter < 1920)) {
    stg3OutFrame[(3 * pixIter + 5760 * pixVal) + 1] =
        varargout_1[pixIter + 1920 * pixVal];
    frameLuma[pixIter + 1920 * pixVal] =
        stg2OutFrame[(3 * pixIter + 5760 * pixVal) + 2];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short varargout_1[2073600]
//                unsigned short stg3OutFrame[6220800]
// Return Type  : void
//
static __global__ __launch_bounds__(512, 1) void visionPipeline_kernel8(
    const unsigned short varargout_1[2073600],
    unsigned short stg3OutFrame[6220800])
{
  unsigned long long threadId;
  int pixIter;
  int pixVal;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  pixIter = static_cast<int>(threadId % 1920ULL);
  pixVal = static_cast<int>(
      (threadId - static_cast<unsigned long long>(pixIter)) / 1920ULL);
  if ((pixVal < 1080) && (pixIter < 1920)) {
    stg3OutFrame[(3 * pixIter + 5760 * pixVal) + 2] =
        varargout_1[pixIter + 1920 * pixVal];
  }
}

//
// Arguments    : dim3 blockArg
//                dim3 gridArg
//                const unsigned short whitePatch[518400]
//                float gMat[129600]
//                float bMat[129600]
//                float rMat[129600]
// Return Type  : void
//
static __global__ __launch_bounds__(480, 1) void visionPipeline_kernel9(
    const unsigned short whitePatch[518400], float gMat[129600],
    float bMat[129600], float rMat[129600])
{
  unsigned long long threadId;
  int colIter;
  threadId =
      static_cast<unsigned long long>(mwGetGlobalThreadIndexInXDimension());
  colIter = static_cast<int>(threadId);
  if (colIter < 480) {
    int pixVal;
    //  White Balance
    //  Compute the mean of RGB channels in the bayer patch
    colIter = (colIter << 1) + 1;
    pixVal = static_cast<int>(floor(static_cast<double>(colIter) / 2.0));
    for (int rowBlockIter{0}; rowBlockIter < 270; rowBlockIter++) {
      int pixIter;
      int rowIter;
      unsigned int u1;
      rowIter = (rowBlockIter << 1) + 1;
      pixIter = static_cast<int>(floor(static_cast<double>(rowIter) / 2.0));
      rMat[pixVal + 480 * pixIter] =
          whitePatch[(colIter + 960 * (rowIter - 1)) - 1];
      bMat[pixVal + 480 * pixIter] = whitePatch[colIter + 960 * rowIter];
      u1 =
          static_cast<unsigned int>(whitePatch[colIter + 960 * (rowIter - 1)]) +
          whitePatch[(colIter + 960 * rowIter) - 1];
      if (u1 > 65535U) {
        u1 = 65535U;
      }
      gMat[pixVal + 480 * pixIter] = static_cast<float>(u1);
    }
  }
}

//
// Arguments    : int val
//                unsigned int mask
//                unsigned int numActiveWarps
// Return Type  : int
//
static __device__ int workGroupReduction(int val, unsigned int mask,
                                         unsigned int numActiveWarps)
{
  __shared__ int shared[32];
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
// Arguments    : const unsigned short inputFrame[2108160]
//                const unsigned short whitePatch[518400]
//                const double *gainFactor
//                unsigned short outFrame[6220800]
// Return Type  : void
//
void visionPipeline(const unsigned short inputFrame[2108160],
                    const unsigned short whitePatch[518400], const double *,
                    unsigned short outFrame[6220800])
{
  double(*gpu_pixelGainLUT)[4096];
  unsigned long long(*gpu_localHistogram)[16384];
  unsigned long long(*gpu_globalHistogram)[4096];
  float(*gpu_bMat)[129600];
  float(*gpu_gMat)[129600];
  float(*gpu_rMat)[129600];
  float b;
  float c;
  float d;
  float *b_gpu_tmp;
  float *c_gpu_tmp;
  float *gpu_gainBChannel;
  float *gpu_gainGChannel;
  float *gpu_gainRChannel;
  float *gpu_tmp;
  int bin1Percent;
  int bin99Percent;
  int binVal;
  int *gpu_bin1Percent;
  int *gpu_bin99Percent;
  int *gpu_binVal;
  int *gpu_i1;
  unsigned short(*gpu_outFrame)[6220800];
  unsigned short(*gpu_stg2OutFrame)[6220800];
  unsigned short(*gpu_stg3OutFrame)[6220800];
  unsigned short(*gpu_stg5OutFrame_t)[6220800];
  unsigned short(*gpu_inputFrame)[2108160];
  unsigned short(*gpu_frameLuma)[2073600];
  unsigned short(*gpu_varargout_1)[2073600];
  unsigned short(*gpu_varargout_2)[2073600];
  unsigned short(*gpu_varargout_3)[2073600];
  unsigned short(*gpu_varargout_4)[2073600];
  unsigned short(*gpu_varargout_5)[2073600];
  unsigned short(*gpu_whitePatch)[518400];
  unsigned short uv[19200];
  unsigned short(*gpu_uv)[19200];
  boolean_T uv_dirtyOnCpu;
  if (!isInitialized_gpuMEX) {
    visionPipeline_initialize();
  }
  mwCudaMalloc(&gpu_outFrame, 12441600ULL);
  mwCudaMalloc(&gpu_stg5OutFrame_t, 12441600ULL);
  mwCudaMalloc(&gpu_pixelGainLUT, 32768ULL);
  mwCudaMalloc(&gpu_binVal, 4ULL);
  mwCudaMalloc(&gpu_bin99Percent, 4ULL);
  mwCudaMalloc(&gpu_bin1Percent, 4ULL);
  mwCudaMalloc(&gpu_globalHistogram, 32768ULL);
  mwCudaMalloc(&gpu_localHistogram, 131072ULL);
  mwCudaMalloc(&gpu_gainRChannel, 4ULL);
  mwCudaMalloc(&gpu_gainGChannel, 4ULL);
  mwCudaMalloc(&gpu_gainBChannel, 4ULL);
  mwCudaMalloc(&c_gpu_tmp, 4ULL);
  mwCudaMalloc(&b_gpu_tmp, 4ULL);
  mwCudaMalloc(&gpu_tmp, 4ULL);
  mwCudaMalloc(&gpu_rMat, 518400ULL);
  mwCudaMalloc(&gpu_bMat, 518400ULL);
  mwCudaMalloc(&gpu_gMat, 518400ULL);
  mwCudaMalloc(&gpu_whitePatch, 1036800ULL);
  mwCudaMalloc(&gpu_stg3OutFrame, 12441600ULL);
  mwCudaMalloc(&gpu_stg2OutFrame, 12441600ULL);
  mwCudaMalloc(&gpu_varargout_5, 4147200ULL);
  mwCudaMalloc(&gpu_varargout_4, 4147200ULL);
  mwCudaMalloc(&gpu_varargout_3, 4147200ULL);
  mwCudaMalloc(&gpu_varargout_2, 4147200ULL);
  mwCudaMalloc(&gpu_varargout_1, 4147200ULL);
  mwCudaMalloc(&gpu_frameLuma, 4147200ULL);
  mwCudaMalloc(&gpu_inputFrame, 4216320ULL);
  mwCudaMalloc(&gpu_i1, 4ULL);
  mwCudaMalloc(&gpu_uv, 38400ULL);
  uv_dirtyOnCpu = false;
  //  Split Frame and Black Correction
  //  Constants:
  //  Rows for black correction cropping
  //  Rows for black level estimation
  //  Estimating the black value in both the frames
  bin99Percent = 0;
  binVal = 0;
  for (bin1Percent = 0; bin1Percent < 19200; bin1Percent++) {
    uv[bin1Percent] = inputFrame[binVal + 1920 * bin99Percent];
    uv_dirtyOnCpu = true;
    bin99Percent++;
    if (bin99Percent > 9) {
      bin99Percent = 0;
      binVal++;
    }
  }
  if (uv_dirtyOnCpu) {
    cudaMemcpy(*gpu_uv, uv, 38400ULL, cudaMemcpyHostToDevice);
  }
  cudaMemcpy(gpu_i1, &bin99Percent, 4ULL, cudaMemcpyHostToDevice);
  visionPipeline_kernel1<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(*gpu_uv,
                                                                  gpu_i1);
  visionPipeline_kernel2<<<dim3(38U, 1U, 1U), dim3(512U, 1U, 1U)>>>(*gpu_uv,
                                                                    gpu_i1);
  cudaMemcpy(&bin99Percent, gpu_i1, 4ULL, cudaMemcpyDeviceToHost);
  //  Subtract mean black and remove the crop the blackCorrection rows
  //  Debayer
  //  Function to call debayer algorithm on input image.
  //     %% Sizes and constants
  //  Debayer Function
  //  Convolve image with masks
  cudaMemcpy(*gpu_inputFrame, inputFrame, 4216320ULL, cudaMemcpyHostToDevice);
  visionPipeline_kernel3<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      static_cast<double>(bin99Percent) / 19200.0, *gpu_inputFrame,
      *gpu_frameLuma);
  stencilKernel<<<8160U, 256U>>>(*gpu_frameLuma, 0U, *gpu_varargout_1,
                                 *gpu_varargout_2, *gpu_varargout_3,
                                 *gpu_varargout_4, *gpu_varargout_5);
  //  Plane Ordering
  //  Since stencil kernel performs
  //  BayerFormat = [(R-plane,G-plane,B-plane)->(Row coord, Col coord)]
  //  Following the RGGB bayer format
  visionPipeline_kernel4<<<dim3(1013U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_varargout_5, *gpu_varargout_4, *gpu_varargout_3, *gpu_varargout_2,
      *gpu_varargout_1, *gpu_stg2OutFrame);
  //  GRBG = [(4,1,5)->(1,1), (1,2,3)->(1,2); (3,2,1)->(2,1), (5,1,4)->(2,2)]
  //  outFrame = stg2OutFrame;
  //  Despeckle
  //  Despeckle Algorithm Caller
  //  Function handle to stencil kernel
  //  Despeckle Input Frame
  visionPipeline_kernel5<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg2OutFrame, *gpu_frameLuma);
  stencilKernel<<<8160U, 256U>>>(*gpu_frameLuma, 0U, *gpu_varargout_1);
  visionPipeline_kernel6<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg2OutFrame, *gpu_varargout_1, *gpu_frameLuma, *gpu_stg3OutFrame);
  stencilKernel<<<8160U, 256U>>>(*gpu_frameLuma, 0U, *gpu_varargout_1);
  visionPipeline_kernel7<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg2OutFrame, *gpu_varargout_1, *gpu_frameLuma, *gpu_stg3OutFrame);
  stencilKernel<<<8160U, 256U>>>(*gpu_frameLuma, 0U, *gpu_varargout_1);
  visionPipeline_kernel8<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_varargout_1, *gpu_stg3OutFrame);
  //  White Balance
  //  Compute the mean of RGB channels in the bayer patch
  cudaMemcpy(*gpu_whitePatch, whitePatch, 1036800ULL, cudaMemcpyHostToDevice);
  visionPipeline_kernel9<<<dim3(1U, 1U, 1U), dim3(480U, 1U, 1U)>>>(
      *gpu_whitePatch, *gpu_gMat, *gpu_bMat, *gpu_rMat);
  visionPipeline_kernel10<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(*gpu_rMat,
                                                                   gpu_tmp);
  coder_reduce0<<<dim3(254U, 1U, 1U), dim3(512U, 1U, 1U)>>>(*gpu_rMat, gpu_tmp);
  cudaMemcpy(&b, gpu_tmp, 4ULL, cudaMemcpyDeviceToHost);
  visionPipeline_kernel11<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(*gpu_gMat,
                                                                   b_gpu_tmp);
  coder_reduce1<<<dim3(254U, 1U, 1U), dim3(512U, 1U, 1U)>>>(*gpu_gMat,
                                                            b_gpu_tmp);
  cudaMemcpy(&c, b_gpu_tmp, 4ULL, cudaMemcpyDeviceToHost);
  visionPipeline_kernel12<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(*gpu_bMat,
                                                                   c_gpu_tmp);
  coder_reduce2<<<dim3(254U, 1U, 1U), dim3(512U, 1U, 1U)>>>(*gpu_bMat,
                                                            c_gpu_tmp);
  cudaMemcpy(&d, c_gpu_tmp, 4ULL, cudaMemcpyDeviceToHost);
  //  Create dummy kernel to keep the data on GPU
  visionPipeline_kernel13<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
      d / 518400.0F, 1.2F * c / 518400.0F, b / 518400.0F, gpu_gainBChannel,
      gpu_gainGChannel, gpu_gainRChannel);
  visionPipeline_kernel14<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      gpu_gainBChannel, gpu_gainGChannel, gpu_gainRChannel, *gpu_stg3OutFrame);
  //  Luma Gain
  //  [stg5OutFrame, gainFactor] = stg_lumaGain(stg4OutFrame, gainFactor);
  //  GPU Pragmas
  //  Compute sizes and declaring constants
  //  Compute Luminance
  visionPipeline_kernel15<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg3OutFrame, *gpu_varargout_1);
  visionPipeline_kernel16<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_varargout_1, *gpu_frameLuma);
  //  Histogram Computation
  //  GPU Codegen: Block-wise histogram computation
  //  Histogram per block is stored in the local histogram matrix
  visionPipeline_kernel17<<<dim3(32U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_localHistogram);
  visionPipeline_kernel18<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_frameLuma, *gpu_localHistogram);
  //  Local histograms are added to create the final global histogram
  visionPipeline_kernel19<<<dim3(8U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_globalHistogram);
  visionPipeline_kernel20<<<dim3(32U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_localHistogram, *gpu_globalHistogram);
  //  Histogram equalization
  //  Cumulative histogram values
  callThrustScan1D(&(*gpu_globalHistogram)[0], false, 4096);
  //  Identify 90-th percentile bin and computing the smoothing factor
  binVal = 0;
  bin1Percent = 0;
  bin99Percent = 0;
  //  Dummy kernel invocation: This is a technique to keep the data on GPU
  //  while processing the loop with a single CUDA thread. This is a GPU Coder
  //  artifact.
  cudaMemcpy(gpu_bin1Percent, &bin1Percent, 4ULL, cudaMemcpyHostToDevice);
  cudaMemcpy(gpu_bin99Percent, &bin99Percent, 4ULL, cudaMemcpyHostToDevice);
  cudaMemcpy(gpu_binVal, &binVal, 4ULL, cudaMemcpyHostToDevice);
  visionPipeline_kernel21<<<dim3(1U, 1U, 1U), dim3(32U, 1U, 1U)>>>(
      *gpu_globalHistogram, gpu_bin1Percent, gpu_bin99Percent, gpu_binVal);
  //  Gain lookup table for 12-bit intensity image
  visionPipeline_kernel22<<<dim3(8U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      gpu_bin99Percent, gpu_bin1Percent, *gpu_pixelGainLUT);
  //  Apply gain to all pixels of present frame
  //  Note: We can do an in-place operation instead of writing the output into
  //  new memory locations, but this destroys the original frame data, which
  //  could be later used to write to disk. This can be changed to in-place
  //  operation if needed.
  //  Note2: Conditional statements (if-else) create thread divergences. To
  //  avoid thread divergence, we transform the following if-else code patterns
  //  to addition statements
  //  Code:
  //    if (condition)
  //        outValue = statement_1;
  //    else
  //        outValue = statement_2;
  //    end
  //
  //  Optimization:
  //    outValue = (condition == true)*statement_1 + (condition ==
  //    false)*statement_2
  visionPipeline_kernel23<<<dim3(12150U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_pixelGainLUT, *gpu_stg3OutFrame, *gpu_stg2OutFrame);
  visionPipeline_kernel24<<<dim3(12150U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg2OutFrame, *gpu_stg5OutFrame_t);
  //  Planar to packed
  //  Assuming input planar array pointer is row-major of size RowsxColsx3
  visionPipeline_kernel25<<<dim3(4050U, 1U, 1U), dim3(512U, 1U, 1U)>>>(
      *gpu_stg5OutFrame_t, *gpu_outFrame);
  //  RGB to YCbCr
  //  stg6OutFrame = stg_rgbToYCbCrConversion(stg5OutFrame);
  //  Image Sharpening
  //  outFrame = stg_sharpenImage(stg6OutFrame);
  cudaMemcpy(outFrame, *gpu_outFrame, 12441600ULL, cudaMemcpyDeviceToHost);
  mwCudaFree(&(*gpu_uv)[0]);
  mwCudaFree(gpu_i1);
  mwCudaFree(&(*gpu_inputFrame)[0]);
  mwCudaFree(&(*gpu_frameLuma)[0]);
  mwCudaFree(&(*gpu_varargout_1)[0]);
  mwCudaFree(&(*gpu_varargout_2)[0]);
  mwCudaFree(&(*gpu_varargout_3)[0]);
  mwCudaFree(&(*gpu_varargout_4)[0]);
  mwCudaFree(&(*gpu_varargout_5)[0]);
  mwCudaFree(&(*gpu_stg2OutFrame)[0]);
  mwCudaFree(&(*gpu_stg3OutFrame)[0]);
  mwCudaFree(&(*gpu_whitePatch)[0]);
  mwCudaFree(&(*gpu_gMat)[0]);
  mwCudaFree(&(*gpu_bMat)[0]);
  mwCudaFree(&(*gpu_rMat)[0]);
  mwCudaFree(gpu_tmp);
  mwCudaFree(b_gpu_tmp);
  mwCudaFree(c_gpu_tmp);
  mwCudaFree(gpu_gainBChannel);
  mwCudaFree(gpu_gainGChannel);
  mwCudaFree(gpu_gainRChannel);
  mwCudaFree(&(*gpu_localHistogram)[0]);
  mwCudaFree(&(*gpu_globalHistogram)[0]);
  mwCudaFree(gpu_bin1Percent);
  mwCudaFree(gpu_bin99Percent);
  mwCudaFree(gpu_binVal);
  mwCudaFree(&(*gpu_pixelGainLUT)[0]);
  mwCudaFree(&(*gpu_stg5OutFrame_t)[0]);
  mwCudaFree(&(*gpu_outFrame)[0]);
}

//
// File trailer for visionPipeline.cu
//
// [EOF]
//
