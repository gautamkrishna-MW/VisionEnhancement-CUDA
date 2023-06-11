/* Copyright 2020 The MathWorks, Inc. */
/********** AtomicAdd ***********/

#include <algorithm>
using std::min;
using std::max;

float cpu_float_atomicAdd(float* u1, float u2) {
    float oldValue = *u1;
    *u1 += u2;
    return oldValue;
}

double cpu_double_atomicAdd(double* u1, double u2) {
    double oldValue = *u1;
    *u1 += u2;
    return oldValue;
}

int cpu_int32_atomicAdd(int* u1, int u2) {
    int oldValue = *u1;
    *u1 += u2;
    return oldValue;
}

unsigned int cpu_uint32_atomicAdd(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    *u1 += u2;
    return oldValue;
}

unsigned long long int cpu_uint64_atomicAdd(unsigned long long int* u1, unsigned long long int u2) {
    unsigned long long int oldValue = *u1;
    *u1 += u2;
    return oldValue;
}

unsigned long int cpu_uint64_atomicAdd(unsigned long int* u1, unsigned long int u2) {
    unsigned long int oldValue = *u1;
    *u1 += u2;
    return oldValue;
}

/********** AtomicSub ***********/

int cpu_int32_atomicSub(int* u1, int u2) {
    int oldValue = *u1;
    *u1 -= u2;
    return oldValue;
}

unsigned int cpu_uint32_atomicSub(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    *u1 -= u2;
    return oldValue;
}

/********** AtomicExch ***********/

int cpu_int32_atomicExch(int* u1, int u2) {
    int oldValue = *u1;
    *u1 = u2;
    return oldValue;
}

unsigned int cpu_uint32_atomicExch(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    *u1 = u2;
    return oldValue;
}

unsigned long long int cpu_uint64_atomicExch(unsigned long long int* u1, unsigned long long int u2) {
    unsigned long long int oldValue = *u1;
    *u1 = u2;
    return oldValue;
}

unsigned long int cpu_uint64_atomicExch(unsigned long int* u1, unsigned long int u2) {
    unsigned long int oldValue = *u1;
    *u1 = u2;
    return oldValue;
}

float cpu_float_atomicExch(float* u1, float u2) {
    float oldValue = *u1;
    *u1 = u2;
    return oldValue;
}

/********** AtomicMin ***********/

int cpu_int32_atomicMin(int* u1, int u2) {
    int oldValue = *u1;
    *u1 = min(*u1, u2);
    return oldValue;
}

unsigned int cpu_uint32_atomicMin(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    *u1 = min(*u1, u2);
    return oldValue;
}

unsigned long long int cpu_uint64_atomicMin(unsigned long long int* u1, unsigned long long int u2) {
    unsigned long long int oldValue = *u1;
    *u1 = min(*u1, u2);
    return oldValue;
}

unsigned long int cpu_uint64_atomicMin(unsigned long int* u1, unsigned long int u2) {
    unsigned long int oldValue = *u1;
    *u1 = min(*u1, u2);
    return oldValue;
}

/********** AtomicMax ***********/

int cpu_int32_atomicMax(int* u1, int u2) {
    int oldValue = *u1;
    *u1 = max(*u1, u2);
    return oldValue;
}

unsigned int cpu_uint32_atomicMax(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    *u1 = max(*u1, u2);
    return oldValue;
}

unsigned long long int cpu_uint64_atomicMax(unsigned long long int* u1, unsigned long long int u2) {
    unsigned long long int oldValue = *u1;
    *u1 = max(*u1, u2);
    return oldValue;
}

unsigned long int cpu_uint64_atomicMax(unsigned long int* u1, unsigned long int u2) {
    unsigned long int oldValue = *u1;
    *u1 = max(*u1, u2);
    return oldValue;
}

/********** AtomicInc ***********/

unsigned int cpu_uint32_atomicInc(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    if(*u1 >= u2) {
        *u1 = 0;
    } else {
        *u1 += 1;
    }
    return oldValue;
}

/********** AtomicDec ***********/

unsigned int cpu_uint32_atomicDec(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    if((*u1 == 0) || (*u1 > u2)) {
        *u1 = u2;
    } else {
        *u1 -= 1;
    }
    return oldValue;
}

/********** AtomicAnd ***********/

int cpu_int32_atomicAnd(int* u1, int u2) {
    int oldValue = *u1;
    *u1 = *u1 & u2;
    return oldValue;
}

unsigned int cpu_uint32_atomicAnd(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    *u1 = *u1 & u2;
    return oldValue;
}

unsigned long long int cpu_uint64_atomicAnd(unsigned long long int* u1, unsigned long long int u2) {
    unsigned long long int oldValue = *u1;
    *u1 = *u1 & u2;
    return oldValue;
}

unsigned long int cpu_uint64_atomicAnd(unsigned long int* u1, unsigned long int u2) {
    unsigned long int oldValue = *u1;
    *u1 = *u1 & u2;
    return oldValue;
}

/********** AtomicOr ***********/

int cpu_int32_atomicOr(int* u1, int u2) {
    int oldValue = *u1;
    *u1 = *u1 | u2;
    return oldValue;
}

unsigned int cpu_uint32_atomicOr(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    *u1 = *u1 | u2;
    return oldValue;
}

unsigned long long int cpu_uint64_atomicOr(unsigned long long int* u1, unsigned long long int u2) {
    unsigned long long int oldValue = *u1;
    *u1 = *u1 | u2;
    return oldValue;
}

unsigned long int cpu_uint64_atomicOr(unsigned long int* u1, unsigned long int u2) {
    unsigned long int oldValue = *u1;
    *u1 = *u1 | u2;
    return oldValue;
}

/********** AtomicXor ***********/

int cpu_int32_atomicXor(int* u1, int u2) {
    int oldValue = *u1;
    *u1 = *u1 ^ u2;
    return oldValue;
}

unsigned int cpu_uint32_atomicXor(unsigned int* u1, unsigned int u2) {
    unsigned int oldValue = *u1;
    *u1 = *u1 ^ u2;
    return oldValue;
}

unsigned long long int cpu_uint64_atomicXor(unsigned long long int* u1, unsigned long long int u2) {
    unsigned long long int oldValue = *u1;
    *u1 = *u1 ^ u2;
    return oldValue;
}

unsigned long int cpu_uint64_atomicXor(unsigned long int* u1, unsigned long int u2) {
    unsigned long int oldValue = *u1;
    *u1 = *u1 ^ u2;
    return oldValue;
}

/********** AtomicCAS ***********/

int cpu_int32_atomicCAS(int* u1, int u2, int u3) {
    int oldValue = *u1;
    if(*u1 == u2) {
        *u1 = u3;
    }
    return oldValue;
}

unsigned int cpu_uint32_atomicCAS(unsigned int* u1, unsigned int u2, unsigned int u3) {
    unsigned int oldValue = *u1;
    if(*u1 == u2) {
        *u1 = u3;
    }
    return oldValue;
}

unsigned long long int cpu_uint64_atomicCAS(unsigned long long int* u1, unsigned long long int u2, unsigned long long int u3) {
    unsigned long long int oldValue = *u1;
    if(*u1 == u2) {
        *u1 = u3;
    }
    return oldValue;
}

unsigned long int cpu_uint64_atomicCAS(unsigned long int* u1, unsigned long int u2, unsigned long int u3) {
    unsigned long int oldValue = *u1;
    if(*u1 == u2) {
        *u1 = u3;
    }
    return oldValue;
}
