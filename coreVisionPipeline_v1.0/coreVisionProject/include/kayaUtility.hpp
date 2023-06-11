
#ifndef UTILITY_DEFS
#define UTILITY_DEFS

#include <iostream>
#include <cstddef>
#include <cstdlib>
#include <ctype.h>
#include <assert.h>
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <vector>
#include <map>
#include <utility>

/* Frame statistics */
#define FRAME_HEIGHT 1080
#define FRAME_WIDTH  1920
#define FRAME_CHANNELS 3
#define BLACK_EST_ROWS 18

/* Debug Messages */
#define DEBUG_BUILD // Comment this line to stop debug message display
#ifdef DEBUG_BUILD
#  define DEBUG(x) std::cerr << x << std::endl
#else
#  define DEBUG(x) do {} while (0)
#endif

/* Assertion Checks and safe-exit checks */
#define assertChk(exprsn, msg) assert(msg && exprsn)

/* Count the objects in an array */
#define _countof(_Array) (sizeof(_Array) / sizeof(_Array[0]))

/* Aligned Memory allocation for faster reads/writes */
void* _aligned_malloc(size_t size, size_t alignment);

/* Big-endian <--> Little-endian */
inline uint32_t swap_uint32( uint32_t val )
{
    val = ((val << 8) & 0xFF00FF00 ) | ((val >> 8) & 0xFF00FF ); 
    return (val << 16) | (val >> 16);
}

/* Ctrl+C handling */
extern volatile sig_atomic_t stopLoop;
void inthand(int signum);
#endif