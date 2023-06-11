
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
OUTPUT_EXEC=visionPipeline

VISION_SRC = $(SDIR)/MWAtomicUtility.cpp $(SDIR)/visionPipeline_data.cu $(SDIR)/visionPipeline_terminate.cu $(SDIR)/MWMemoryManager.cpp $(SDIR)/visionPipeline.cu $(SDIR)/visionPipeline_initialize.cu $(SDIR)/stg_chkImageSaturation_data.cu $(SDIR)/stg_chkImageSaturation_initialize.cu $(SDIR)/stg_chkImageSaturation_terminate.cu $(SDIR)/stg_chkImageSaturation.cu $(SDIR)/main.cpp

VISION_INCLUDES = $(IDIR)/MWCudaDimUtility.hpp $(IDIR)/MWMemoryManager.hpp $(IDIR)/MWScanUtility.h $(IDIR)/tmwtypes.h $(IDIR)/visionPipeline.h $(IDIR)/visionPipeline_terminate.h $(IDIR)/MWAtomicUtility.hpp $(IDIR)/MWCudaMemoryFunctions.hpp $(IDIR)/MWScanFunctors.h $(IDIR)/MWShuffleUtility.h $(IDIR)/rtwtypes.h $(IDIR)/visionPipeline_data.h $(IDIR)/visionPipeline_initialize.h $(IDIR)/visionPipeline_types.h $(IDIR)/stg_chkImageSaturation_data.h $(IDIR)/stg_chkImageSaturation_initialize.h $(IDIR)/stg_chkImageSaturation_terminate.h $(IDIR)/stg_chkImageSaturation.h

VISION_OBJS = $(ODIR)/kayaUtility.o $(ODIR)/kayaFrameGrab.o $(ODIR)/callbackFunctions.o $(ODIR)/processImage.o $(ODIR)/visionPipeline_data.o $(ODIR)/visionPipeline_initialize.o $(ODIR)/visionPipeline_terminate.o $(ODIR)/visionPipeline.o $(ODIR)/MWMemoryManager.o $(ODIR)/MWAtomicUtility.o $(ODIR)/stg_chkImageSaturation_data.o $(ODIR)/stg_chkImageSaturation_initialize.o $(ODIR)/stg_chkImageSaturation_terminate.o $(ODIR)/stg_chkImageSaturation.o $(ODIR)/main.o


# Targets and compilations

$(OUTPUT_EXEC): $(VISION_OBJS)
	$(CC) $(WARN_FLAGS) $(CC_FLAGS) $(NVCC_FLAGS) $(DEBUG_FLAGS) $^ $(CFLAGS) $(LFLAGS) $(LIBS) -o $@
	
$(ODIR)/kayaUtility.o: $(SDIR)/kayaUtility.cpp $(IDIR)/kayaUtility.hpp
	$(CC) $(FLAGS) -c $(SDIR)/kayaUtility.cpp $(CFLAGS) -o $(ODIR)/kayaUtility.o

$(ODIR)/kayaFrameGrab.o: $(SDIR)/kayaFrameGrab.cpp $(IDIR)/kayaFrameGrab.hpp
	$(CC) $(FLAGS) -c $(SDIR)/kayaFrameGrab.cpp $(CFLAGS) -o $(ODIR)/kayaFrameGrab.o

$(ODIR)/callbackFunctions.o: $(SDIR)/callbackFunctions.cpp $(IDIR)/callbackFunctions.hpp
	$(CC) $(FLAGS) -c $(SDIR)/callbackFunctions.cpp $(CFLAGS) -o $(ODIR)/callbackFunctions.o

$(ODIR)/processImage.o: $(SDIR)/processImage.cpp $(IDIR)/processImage.hpp
	$(CC) $(FLAGS) -c $(SDIR)/processImage.cpp $(CFLAGS) -o $(ODIR)/processImage.o

$(ODIR)/visionPipeline_data.o: $(SDIR)/visionPipeline_data.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/visionPipeline_data.cu $(CFLAGS) -o $(ODIR)/visionPipeline_data.o

$(ODIR)/visionPipeline_initialize.o: $(SDIR)/visionPipeline_initialize.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/visionPipeline_initialize.cu $(CFLAGS) -o $(ODIR)/visionPipeline_initialize.o

$(ODIR)/visionPipeline_terminate.o: $(SDIR)/visionPipeline_terminate.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/visionPipeline_terminate.cu $(CFLAGS) -o $(ODIR)/visionPipeline_terminate.o

$(ODIR)/visionPipeline.o: $(SDIR)/visionPipeline.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/visionPipeline.cu $(CFLAGS) -o $(ODIR)/visionPipeline.o

$(ODIR)/MWMemoryManager.o: $(SDIR)/MWMemoryManager.cpp $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/MWMemoryManager.cpp $(CFLAGS) -o $(ODIR)/MWMemoryManager.o

$(ODIR)/MWAtomicUtility.o: $(SDIR)/MWAtomicUtility.cpp $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/MWAtomicUtility.cpp $(CFLAGS) -o $(ODIR)/MWAtomicUtility.o

$(ODIR)/stg_chkImageSaturation_data.o: $(SDIR)/stg_chkImageSaturation_data.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/stg_chkImageSaturation_data.cu $(CFLAGS) -o $(ODIR)/stg_chkImageSaturation_data.o

$(ODIR)/stg_chkImageSaturation_initialize.o: $(SDIR)/stg_chkImageSaturation_initialize.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/stg_chkImageSaturation_initialize.cu $(CFLAGS) -o $(ODIR)/stg_chkImageSaturation_initialize.o

$(ODIR)/stg_chkImageSaturation_terminate.o: $(SDIR)/stg_chkImageSaturation_terminate.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/stg_chkImageSaturation_terminate.cu $(CFLAGS) -o $(ODIR)/stg_chkImageSaturation_terminate.o

$(ODIR)/stg_chkImageSaturation.o: $(SDIR)/stg_chkImageSaturation.cu $(VISION_INCLUDES)
	$(CC) $(FLAGS) -c $(SDIR)/stg_chkImageSaturation.cu $(CFLAGS) -o $(ODIR)/stg_chkImageSaturation.o

$(ODIR)/main.o: $(SDIR)/main.cpp
	$(CC) $(FLAGS) -c $(SDIR)/main.cpp $(CFLAGS) -o $(ODIR)/main.o

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o
	rm -f $(OUTPUT_EXEC)