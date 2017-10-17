/*
 * timeval.h    1.0 01/12/19
 *
 * Defines gettimeofday, timeval, etc. for Win32
 *
 * By Wu Yongwei
 *
 */
#ifndef _TIMEVAL_H
#define _TIMEVAL_H

#include <winsock2.h>

#define EPOCHFILETIME (116444736000000000LL)

#if defined(__cplusplus)
extern "C"
{
#endif

struct timezone 
{
    int tz_minuteswest; /* minutes W of Greenwich */
    int tz_dsttime;     /* type of dst correction */
};

int gettimeofday(struct timeval *tv, struct timezone *tz);

#if defined(__cplusplus)
}
#endif

#endif /* _TIMEVAL_H */
