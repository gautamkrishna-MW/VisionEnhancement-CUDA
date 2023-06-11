
#include "kayaUtility.hpp"

/* Aligned Memory allocation for faster reads/writes */
void* _aligned_malloc(size_t size, size_t alignment)
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

/* Ctrl+C handling */
volatile sig_atomic_t stopLoop = 0;
void inthand(int signum) {
    stopLoop = 1;
}
