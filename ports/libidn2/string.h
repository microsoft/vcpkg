#ifndef _GL_STRING_H
#define _GL_STRING_H

char * strchrnul (const char *s, int c_in);
int strverscmp (const char *s1, const char *s2);
void * rawmemchr (const void *s, int c_in);

#if defined(__MINGW32__)
#include <../include/string.h>
#elif defined(_WIN32)
#include <../ucrt/string.h>
#endif

#endif /* _GL_STRING_H */
