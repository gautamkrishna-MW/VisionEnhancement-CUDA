/* Sri Rama */

#ifndef UTILITY_DEFS
#define UTILITY_DEFS

#include <iostream>
#include <signal.h>
#include <unistd.h>
#include <utility>

/* Frame statistics */
#define FRAME_HEIGHT 1080
#define FRAME_WIDTH  1920
#define FRAME_CHANNELS 3
#define BLACK_EST_ROWS 18

/* KAYA Buffer Specific defines */
#define MAXSTREAMS 2
#define MAXBUFFERS 16

/* Debug Messages */
#define DEBUG_ERRLOG // Comment this line to stop error logging
#ifdef DEBUG_ERRLOG
    #define ERRLOG(x) std::cerr << x << std::endl
#else
    #define ERRLOG(x) do {} while (0)
#endif

#define DEBUG_STDLOG // Comment this line to stop stdout logging
#ifdef DEBUG_STDLOG
    #define LOG(x) std::cout << x << std::endl
#else
    #define LOG(x) do {} while (0)
#endif

/* Count the objects in an array */
#define _countof(_Array) (sizeof(_Array) / sizeof(_Array[0]))

/* Aligned Memory allocation for faster reads/writes */
inline void* _aligned_malloc(size_t size, size_t alignment)
{
    size_t pageAlign = size % 4096;
    if(pageAlign)
    {
        size += 4096 - pageAlign;
    }

#if(GCC_VERSION <= 40407)
    void * memptr = 0;
    posix_memalign(&memptr, alignment, size);
    return memptr;
#else
    return aligned_alloc(alignment, size);
#endif
}

/* Big-endian <--> Little-endian */
inline uint32_t swap_uint32( uint32_t val )
{
    val = ((val << 8) & 0xFF00FF00 ) | ((val >> 8) & 0xFF00FF ); 
    return (val << 16) | (val >> 16);
}

class outputLogger
{
public:
    FILE* stdOutFp = nullptr;
    FILE* errOutFp = nullptr;
    void logStdOut(const char* inpName)
    {
        const char* fileNameStr = (inpName != NULL)? inpName:"stdOutLog.txt";
        stdOutFp = freopen(fileNameStr, "w", stdout);
    }

    void logErrOut(const char* inpName)
    {
        const char* fileNameStr = (inpName != NULL)? inpName:"stdErrLog.txt";
        errOutFp = freopen(fileNameStr, "w", stderr);
    }

    ~outputLogger()
    {
        if (stdOutFp != NULL)
        {
            fclose(stdOutFp);
            stdOutFp = NULL;
        }

        if (errOutFp != NULL)
        {
            fclose(errOutFp);
            errOutFp = NULL;
        }
    }

};
#endif