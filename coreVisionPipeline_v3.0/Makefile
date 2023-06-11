
CC=nvcc

WARN_FLAGS=
OBJ_FLAGS = -c
CC_FLAGS = -std=c++11
NVCC_FLAGS = -gencode arch=compute_75,code=sm_75
DEBUG_FLAGS = -g -G -O0 -rdc=true
# DEBUG_FLAGS = -O3
FLAGS = $(WARN_FLAGS) $(OBJ_FLAGS) $(CC_FLAGS) $(NVCC_FLAGS) $(DEBUG_FLAGS)

CFLAGS=-I/opt/KAYA_Instruments/include/ -I/usr/local/cuda-11.6/include/ -I/usr/local/include/opencv4 -I./include
LFLAGS=-L/opt/KAYA_Instruments/lib/ -L/usr/local/cuda-11.6/lib64/ -L/usr/local/lib/
LIBS= -lcudart -lKYFGLib -lopencv_highgui -lopencv_cudalegacy -lopencv_videoio -lopencv_cudawarping -lopencv_ximgproc -lopencv_video -lopencv_imgcodecs -lopencv_photo -lopencv_cudaimgproc -lopencv_cudafilters -lopencv_imgproc -lopencv_cudaarithm -lopencv_core -lopencv_cudev

IDIR=./include
ODIR=./obj
SDIR=./src
OUTPUT_EXEC=coreVisionPipeline

VISION_SRC = $(SDIR)/MWAtomicUtility.cpp $(SDIR)/coreVisionPipeline_data.cu $(SDIR)/coreVisionPipeline_terminate.cu $(SDIR)/MWMemoryManager.cpp $(SDIR)/coreVisionPipeline.cu $(SDIR)/coreVisionPipeline_initialize.cu $(SDIR)/isFrameSaturated_data.cu $(SDIR)/isFrameSaturated_initialize.cu $(SDIR)/isFrameSaturated_terminate.cu $(SDIR)/isFrameSaturated.cu $(SDIR)/main.cpp

VISION_INCLUDES = $(IDIR)/MWCudaDimUtility.hpp $(IDIR)/MWMemoryManager.hpp $(IDIR)/MWScanUtility.h $(IDIR)/tmwtypes.h $(IDIR)/coreVisionPipeline.h $(IDIR)/coreVisionPipeline_terminate.h $(IDIR)/MWAtomicUtility.hpp $(IDIR)/MWCudaMemoryFunctions.hpp $(IDIR)/MWScanFunctors.h $(IDIR)/MWShuffleUtility.h $(IDIR)/rtwtypes.h $(IDIR)/coreVisionPipeline_data.h $(IDIR)/coreVisionPipeline_initialize.h $(IDIR)/coreVisionPipeline_types.h $(IDIR)/isFrameSaturated_data.h $(IDIR)/isFrameSaturated_initialize.h $(IDIR)/isFrameSaturated_terminate.h $(IDIR)/isFrameSaturated.h

VISION_OBJS = $(ODIR)/kayaFrameGrab.o $(ODIR)/processImage.o $(ODIR)/coreVisionPipeline_data.o $(ODIR)/coreVisionPipeline_initialize.o $(ODIR)/coreVisionPipeline_terminate.o $(ODIR)/coreVisionPipeline.o $(ODIR)/MWMemoryManager.o $(ODIR)/MWAtomicUtility.o $(ODIR)/isFrameSaturated_data.o $(ODIR)/isFrameSaturated_initialize.o $(ODIR)/isFrameSaturated_terminate.o $(ODIR)/isFrameSaturated.o $(ODIR)/main.o


# Targets and compilations

$(OUTPUT_EXEC): $(VISION_OBJS)
	$(CC) $(WARN_FLAGS) $(CC_FLAGS) $(NVCC_FLAGS) $(DEBUG_FLAGS) $^ $(CFLAGS) $(LFLAGS) $(LIBS) -o $@
	
$(ODIR)/kayaFrameGrab.o: $(SDIR)/kayaFrameGrab.cpp $(IDIR)/kayaFrameGrab.hpp $(IDIR)/visionUtility.hpp $(IDIR)/processFrameAbstractClass.hpp
	$(CC) $(FLAGS) -c $(SDIR)/kayaFrameGrab.cpp $(CFLAGS) -o $(ODIR)/kayaFrameGrab.o

$(ODIR)/processImage.o: $(SDIR)/processImage.cpp $(IDIR)/processImage.hpp $(IDIR)/visionUtility.hpp $(IDIR)/processFrameAbstractClass.hpp
	$(CC) $(FLAGS) -c $(SDIR)/processImage.cpp $(CFLAGS) -o $(ODIR)/processImage.o

$(ODIR)/main.o: $(SDIR)/main.cpp $(IDIR)/kayaFrameGrab.hpp $(IDIR)/processImage.hpp
	$(CC) $(FLAGS) -c $(SDIR)/main.cpp $(CFLAGS) -o $(ODIR)/main.o

$(ODIR)/coreVisionPipeline_data.o: $(SDIR)/coreVisionPipeline_data.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/coreVisionPipeline_data.cu $(CFLAGS) -o $(ODIR)/coreVisionPipeline_data.o

$(ODIR)/coreVisionPipeline_initialize.o: $(SDIR)/coreVisionPipeline_initialize.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/coreVisionPipeline_initialize.cu $(CFLAGS) -o $(ODIR)/coreVisionPipeline_initialize.o

$(ODIR)/coreVisionPipeline_terminate.o: $(SDIR)/coreVisionPipeline_terminate.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/coreVisionPipeline_terminate.cu $(CFLAGS) -o $(ODIR)/coreVisionPipeline_terminate.o

$(ODIR)/coreVisionPipeline.o: $(SDIR)/coreVisionPipeline.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/coreVisionPipeline.cu $(CFLAGS) -o $(ODIR)/coreVisionPipeline.o

$(ODIR)/MWMemoryManager.o: $(SDIR)/MWMemoryManager.cpp $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/MWMemoryManager.cpp $(CFLAGS) -o $(ODIR)/MWMemoryManager.o

$(ODIR)/MWAtomicUtility.o: $(SDIR)/MWAtomicUtility.cpp $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/MWAtomicUtility.cpp $(CFLAGS) -o $(ODIR)/MWAtomicUtility.o

$(ODIR)/isFrameSaturated_data.o: $(SDIR)/isFrameSaturated_data.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/isFrameSaturated_data.cu $(CFLAGS) -o $(ODIR)/isFrameSaturated_data.o

$(ODIR)/isFrameSaturated_initialize.o: $(SDIR)/isFrameSaturated_initialize.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/isFrameSaturated_initialize.cu $(CFLAGS) -o $(ODIR)/isFrameSaturated_initialize.o

$(ODIR)/isFrameSaturated_terminate.o: $(SDIR)/isFrameSaturated_terminate.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/isFrameSaturated_terminate.cu $(CFLAGS) -o $(ODIR)/isFrameSaturated_terminate.o

$(ODIR)/isFrameSaturated.o: $(SDIR)/isFrameSaturated.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/isFrameSaturated.cu $(CFLAGS) -o $(ODIR)/isFrameSaturated.o

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o
	rm -f $(OUTPUT_EXEC)